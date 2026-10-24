// Server par sab coin badlav. Client sirf call karta hai.
// Deploy: firebase deploy --only functions
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

const BONUS_PERCENT = 10;
// Client ke lib/core/recharge_packages.dart se same rakhein
const PACKAGES = {
  100: { coins: 4300000, frame: 1 },
  500: { coins: 21500000, frame: 10 },
  1000: { coins: 43000000, frame: 20 },
};
const ROLES = ['user', 'agent', 'admin'];

function uidOf(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  return req.auth.uid;
}

function packageOf(amount) {
  const p = PACKAGES[amount];
  if (!p) throw new HttpsError('invalid-argument', 'Package galat hai');
  return p;
}

// User ko coins + bonus + frame dene ka update (transaction ke andar)
function creditUser(tx, userRef, p) {
  const bonus = Math.floor((p.coins * BONUS_PERCENT) / 100);
  tx.update(userRef, {
    coins: FieldValue.increment(p.coins + bonus),
    frames: FieldValue.arrayUnion(p.frame),
  });
  return bonus;
}

// TODO(gateway): Razorpay / Cashfree / Stripe ka server-side verify yahan lagayein.
// Jab tak ye na lage, online recharge band rahega.
async function verifyWithGateway(paymentId, amount) {
  throw new HttpsError('failed-precondition', 'Payment gateway configure nahi hai');
}

exports.confirmOnlineRecharge = onCall(async (req) => {
  const uid = uidOf(req);
  const amount = Number(req.data.amount);
  const paymentId = String(req.data.paymentId || '');
  const p = packageOf(amount);
  if (!paymentId) throw new HttpsError('invalid-argument', 'paymentId chahiye');

  await verifyWithGateway(paymentId, amount);

  await db.runTransaction(async (tx) => {
    const logRef = db.collection('recharges').doc(paymentId);
    const userRef = db.collection('users').doc(uid);
    const log = await tx.get(logRef);
    if (log.exists) throw new HttpsError('already-exists', 'Ye payment pehle use ho chuka hai');
    const bonus = creditUser(tx, userRef, p);
    tx.set(logRef, {
      method: 'online', uid, amount, coins: p.coins, bonus, frame: p.frame,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

exports.agentTransfer = onCall(async (req) => {
  const agentUid = uidOf(req);
  const toUid = String(req.data.toUid || '');
  const amount = Number(req.data.amount);
  const p = packageOf(amount);
  if (!toUid) throw new HttpsError('invalid-argument', 'User ID chahiye');

  await db.runTransaction(async (tx) => {
    const agentUserRef = db.collection('users').doc(agentUid);
    const agentRef = db.collection('agents').doc(agentUid);
    const toRef = db.collection('users').doc(toUid);
    const logRef = db.collection('recharges').doc();
    const [agentUser, agent, to] = await tx.getAll(agentUserRef, agentRef, toRef);

    if (!agentUser.exists || agentUser.data().role !== 'agent') {
      throw new HttpsError('permission-denied', 'Aap agent nahi ho');
    }
    if (!to.exists) throw new HttpsError('not-found', 'User nahi mila');
    const stock = agent.exists ? agent.data().stock || 0 : 0;
    if (stock < p.coins) throw new HttpsError('failed-precondition', 'Aapke stock mein itne coins nahi hain');

    tx.update(agentRef, { stock: FieldValue.increment(-p.coins) });
    const bonus = creditUser(tx, toRef, p);
    tx.set(logRef, {
      method: 'agent', agentUid, toUid, amount, coins: p.coins, bonus, frame: p.frame,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

async function requireAdmin(callerUid) {
  const caller = await db.collection('users').doc(callerUid).get();
  if (!caller.exists || caller.data().role !== 'admin') {
    throw new HttpsError('permission-denied', 'Sirf admin ye kar sakta hai');
  }
}

exports.adminSetRole = onCall(async (req) => {
  const callerUid = uidOf(req);
  await requireAdmin(callerUid);
  const uid = String(req.data.uid || '');
  const role = String(req.data.role || '');
  if (!uid || !ROLES.includes(role)) throw new HttpsError('invalid-argument', 'Galat data');
  await db.collection('users').doc(uid).update({ role });
  if (role === 'agent') {
    await db.collection('agents').doc(uid).set({ stock: 0 }, { merge: true });
  }
  return { ok: true };
});

exports.adminAddStock = onCall(async (req) => {
  const callerUid = uidOf(req);
  await requireAdmin(callerUid);
  const agentUid = String(req.data.agentUid || '');
  const coins = Number(req.data.coins);
  if (!agentUid || !(coins > 0)) throw new HttpsError('invalid-argument', 'Galat data');
  await db.collection('agents').doc(agentUid).set(
    { stock: FieldValue.increment(coins) },
    { merge: true },
  );
  return { ok: true };
});

// Backup aur restore functions
Object.assign(exports, require('./backup'));

// Economy: gift, game, diamond convert
Object.assign(exports, require('./economy'));

// Games v13 (play, lucky bag)
Object.assign(exports, require('./games_v13'));
