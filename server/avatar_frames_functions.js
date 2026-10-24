// Host functions/index.js mein merge karein: Object.assign(exports, require('./avatar_frames_functions'));
// Ye file purane functions ko nahi todti. Sirf frame aur role logic add karti hai.
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const db = getFirestore();

// Staff roles: admin ke liye bhi. Client ke FrameCatalog se same rakhein.
const ROLES = ['user', 'agent', 'support', 'admin', 'superadmin', 'bd', 'superbd'];

// Standard frame price, client ke FrameCatalog.standardFrames se same formula
function standardPrice(index /* 0-based */) {
  return 500 + Math.floor(index / 100) * 500;
}

function uidOf(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  return req.auth.uid;
}

async function requireAdmin(uid) {
  const snap = await db.collection('users').doc(uid).get();
  if (!snap.exists || snap.data().role !== 'admin') {
    throw new HttpsError('permission-denied', 'Sirf admin');
  }
}

// Standard frame khareedna: coins server par katte hain
exports.buyFrame = onCall(async (req) => {
  const uid = uidOf(req);
  const frameId = String(req.data.frameId || '');
  const m = /^std_(\d{4})$/.exec(frameId);
  if (!m) throw new HttpsError('invalid-argument', 'Frame galat hai');
  const index = Number(m[1]) - 1;
  if (index < 0 || index >= 1000) throw new HttpsError('invalid-argument', 'Frame galat hai');
  const price = standardPrice(index);

  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const d = snap.data() || {};
    const owned = d.ownedFrames || [];
    if (owned.includes(frameId)) throw new HttpsError('already-exists', 'Ye frame pehle se hai');
    if ((d.coins || 0) < price) throw new HttpsError('failed-precondition', 'Coins kam hain');
    tx.update(ref, {
      coins: d.coins - price,
      ownedFrames: FieldValue.arrayUnion(frameId),
    });
  });
  return { ok: true, price };
});

// Equip: server bhi same rule check karta hai (client par bharosa nahi)
exports.setEquippedFrame = onCall(async (req) => {
  const uid = uidOf(req);
  const frameId = String(req.data.frameId || '');
  const ref = db.collection('users').doc(uid);
  const snap = await ref.get();
  const d = snap.data() || {};
  const role = d.role || 'user';
  const staff = ['support', 'admin', 'superadmin', 'bd', 'superbd'].includes(role);
  if (staff) throw new HttpsError('permission-denied', 'Staff frame locked hai');

  const vipMatch = /^vip_(\d)$/.exec(frameId);
  let allowed = false;
  if (vipMatch) {
    allowed = (d.vip || 0) >= Number(vipMatch[1]);
  } else if (/^std_\d{4}$/.test(frameId)) {
    allowed = (d.ownedFrames || []).includes(frameId);
  }
  if (!allowed) throw new HttpsError('permission-denied', 'Ye frame aapke liye available nahi hai');
  await ref.update({ equippedFrame: frameId });
  return { ok: true };
});

// adminSetRole: naye staff roles allow. Host ka purana adminSetRole isse replace karein.
exports.adminSetRoleV2 = onCall(async (req) => {
  const callerUid = uidOf(req);
  await requireAdmin(callerUid);
  const uid = String(req.data.uid || '');
  const role = String(req.data.role || '');
  if (!uid || !ROLES.includes(role)) throw new HttpsError('invalid-argument', 'Galat data');
  await db.collection('users').doc(uid).update({ role });
  return { ok: true };
});
