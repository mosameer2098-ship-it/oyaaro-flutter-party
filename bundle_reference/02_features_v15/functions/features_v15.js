// Heloza features v15 server logic. Host functions/index.js mein:
//   Object.assign(exports, require('./features_v15'));
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const crypto = require('crypto');
const db = getFirestore();

function uidOf(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  return req.auth.uid;
}
const fail = (msg) => new HttpsError('failed-precondition', msg);
const deny = (msg) => new HttpsError('permission-denied', msg);
const bad = (msg) => new HttpsError('invalid-argument', msg);

// Level formula, client shared/level_math.dart se same
function levelFor(exp) {
  let l = 1;
  while (l < 200 && exp >= 100 * l * (l + 1)) l++;
  return l;
}

// ---------- Level milestone claim ----------
function milestoneFrame(i) {
  const index = Math.min((i - 1) * 50, 999);
  return `std_${String(index + 1).padStart(4, '0')}`;
}
exports.claimLevelMilestone = onCall(async (req) => {
  const uid = uidOf(req);
  const i = Number(req.data.index);
  if (!Number.isInteger(i) || i < 1 || i > 20) throw bad('Milestone galat hai');
  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data() || {};
    if (levelFor(d.exp || 0) < i * 10) throw fail(`Level ${i * 10} tak pahunchna hoga`);
    if ((d.claimedLevels || []).includes(i)) throw fail('Ye reward aap le chuke hain');
    tx.update(ref, {
      coins: (d.coins || 0) + 500 * i,
      claimedLevels: FieldValue.arrayUnion(i),
      frames: FieldValue.arrayUnion(i),
      ownedFrames: FieldValue.arrayUnion(milestoneFrame(i)),
    });
  });
  return { ok: true };
});

// ---------- VIP ----------
const VIP_POINTS = [1000, 5000, 20000, 60000, 150000, 400000, 900000, 1800000, 3500000];
const VIP_PRICE = [500, 1500, 3000, 6000, 12000, 25000, 50000, 90000, 150000];
exports.buyVip = onCall(async (req) => {
  const uid = uidOf(req);
  const level = Number(req.data.level);
  if (!Number.isInteger(level) || level < 1 || level > 9) throw bad('VIP level galat hai');
  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data() || {};
    const vip = d.vip || 0;
    if (vip >= level) throw fail(`VIP ${level} aap pehle le chuke hain`);
    if (vip !== level - 1) throw fail(`Pehle VIP ${level - 1} lo`);
    if ((d.exp || 0) < VIP_POINTS[level - 1]) throw fail('Points kam hain');
    if ((d.coins || 0) < VIP_PRICE[level - 1]) throw fail('Coins kam hain');
    tx.update(ref, { coins: d.coins - VIP_PRICE[level - 1], vip: level });
  });
  return { ok: true };
});

// ---------- Family ----------
const FAMILY_COST = 500;
const FAMILY_MAX = 50;
exports.createFamily = onCall(async (req) => {
  const uid = uidOf(req);
  const name = String(req.data.name || '').trim();
  if (name.length < 3 || name.length > 20) throw bad('Family naam 3 se 20 letters ka ho');
  const userRef = db.collection('users').doc(uid);
  const famRef = db.collection('families').doc();
  await db.runTransaction(async (tx) => {
    const u = (await tx.get(userRef)).data() || {};
    if (u.familyId) throw fail('Aap pehle se family mein ho');
    if ((u.coins || 0) < FAMILY_COST) throw fail(`Family banane ke liye ${FAMILY_COST} coins chahiye`);
    tx.update(userRef, { coins: u.coins - FAMILY_COST, familyId: famRef.id });
    tx.set(famRef, {
      name, leaderUid: uid, memberCount: 1,
      members: { [uid]: u.name || 'User' },
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { familyId: famRef.id };
});

exports.joinFamily = onCall(async (req) => {
  const uid = uidOf(req);
  const familyId = String(req.data.familyId || '');
  const userRef = db.collection('users').doc(uid);
  const famRef = db.collection('families').doc(familyId);
  await db.runTransaction(async (tx) => {
    const [u, f] = await tx.getAll(userRef, famRef);
    if ((u.data() || {}).familyId) throw fail('Aap pehle se family mein ho');
    if (!f.exists) throw fail('Family nahi mili');
    const count = f.data().memberCount || 0;
    if (count >= FAMILY_MAX) throw fail('Family full hai');
    tx.update(famRef, { memberCount: count + 1, [`members.${uid}`]: (u.data() || {}).name || 'User' });
    tx.update(userRef, { familyId });
  });
  return { ok: true };
});

exports.leaveFamily = onCall(async (req) => {
  const uid = uidOf(req);
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const u = (await tx.get(userRef)).data() || {};
    if (!u.familyId) throw fail('Aap kisi family mein nahi ho');
    const famRef = db.collection('families').doc(u.familyId);
    const f = (await tx.get(famRef)).data() || {};
    const count = f.memberCount || 1;
    if (f.leaderUid === uid && count > 1) throw fail('Leader tab tak nahi chhod sakta jab members hain');
    if (count <= 1) tx.delete(famRef);
    else tx.update(famRef, { memberCount: count - 1, [`members.${uid}`]: FieldValue.delete() });
    tx.update(userRef, { familyId: null });
  });
  return { ok: true };
});

// ---------- Themes ----------
function themeInfo(id) {
  const m = /^(room|couple)_(\d{2})$/.exec(id);
  if (!m) return null;
  const i = Number(m[2]) - 1;
  if (i < 0 || i > 11) return null;
  return { kind: m[1], price: m[1] === 'room' ? 300 + i * 150 : 500 + i * 200 };
}
exports.buyTheme = onCall(async (req) => {
  const uid = uidOf(req);
  const themeId = String(req.data.themeId || '');
  const info = themeInfo(themeId);
  if (!info) throw bad('Theme galat hai');
  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data() || {};
    if ((d.ownedThemes || []).includes(themeId)) throw fail('Ye theme pehle se hai');
    if ((d.coins || 0) < info.price) throw fail('Coins kam hain');
    tx.update(ref, { coins: d.coins - info.price, ownedThemes: FieldValue.arrayUnion(themeId) });
  });
  return { ok: true };
});

exports.equipTheme = onCall(async (req) => {
  const uid = uidOf(req);
  const themeId = String(req.data.themeId || '');
  const kind = String(req.data.kind || '');
  const info = themeInfo(themeId);
  if (!info || info.kind !== kind) throw bad('Theme ya kind galat hai');
  const ref = db.collection('users').doc(uid);
  const d = (await ref.get()).data() || {};
  if (!(d.ownedThemes || []).includes(themeId)) throw deny('Ye theme aapke paas nahi hai');
  await ref.update(kind === 'room' ? { equippedRoomTheme: themeId } : { equippedCoupleTheme: themeId });
  return { ok: true };
});

// ---------- CP (couple) on conversation ----------
async function convFor(uid, convId) {
  const ref = db.collection('conversations').doc(convId);
  const snap = await ref.get();
  if (!snap.exists) throw fail('Chat nahi mili');
  const parts = snap.data().participants || [];
  if (!parts.includes(uid)) throw deny('Ye chat aapki nahi hai');
  return { ref, data: snap.data() };
}
exports.cpRequest = onCall(async (req) => {
  const uid = uidOf(req);
  const { ref } = await convFor(uid, String(req.data.convId || ''));
  await db.runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data() || {};
    const st = (d.cp || {}).status || 'none';
    if (st === 'active') throw fail('CP already lagi hai');
    if (st === 'pending') throw fail('Request pending hai');
    tx.update(ref, { cp: { status: 'pending', by: uid } });
  });
  return { ok: true };
});

exports.cpAccept = onCall(async (req) => {
  const uid = uidOf(req);
  const { ref } = await convFor(uid, String(req.data.convId || ''));
  await db.runTransaction(async (tx) => {
    const cp = (await tx.get(ref)).data().cp || {};
    if (cp.status !== 'pending') throw fail('Koi pending request nahi hai');
    if (cp.by === uid) throw fail('Request aapne bheji hai');
    tx.update(ref, { cp: { status: 'active', by: cp.by } });
  });
  return { ok: true };
});

exports.setCoupleTheme = onCall(async (req) => {
  const uid = uidOf(req);
  const themeId = String(req.data.themeId || '');
  const info = themeInfo(themeId);
  if (!info || info.kind !== 'couple') throw bad('Couple theme galat hai');
  const { ref, data } = await convFor(uid, String(req.data.convId || ''));
  if (!(data.cp && data.cp.status === 'active')) throw fail('Pehle CP lagao');
  const me = (await db.collection('users').doc(uid).get()).data() || {};
  if (!(me.ownedThemes || []).includes(themeId)) throw deny('Ye theme aapke paas nahi hai');
  await ref.update({ coupleTheme: themeId });
  return { ok: true };
});

// ---------- PK ----------
exports.startPk = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const oppId = String(req.data.opponentRoomId || '');
  const minutes = Number(req.data.minutes);
  if (oppId === roomId) throw bad('Apne hi room se PK nahi');
  if (![1, 5, 10, 15].includes(minutes)) throw bad('Time galat hai');
  const roomRef = db.collection('rooms').doc(roomId);
  const oppRef = db.collection('rooms').doc(oppId);
  const pkRef = db.collection('pk').doc();
  await db.runTransaction(async (tx) => {
    const [a, b] = await tx.getAll(roomRef, oppRef);
    if (!a.exists || !b.exists) throw fail('Room nahi mila');
    if (a.data().hostUid !== uid) throw deny('Sirf host PK shuru kar sakta hai');
    if (a.data().pkSessionId || b.data().pkSessionId) throw fail('Ek room already PK mein hai');
    tx.set(pkRef, {
      roomA: roomId, roomB: oppId, scoreA: 0, scoreB: 0, active: true,
      endsAt: Timestamp.fromMillis(Date.now() + minutes * 60 * 1000),
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.update(roomRef, { pkSessionId: pkRef.id });
    tx.update(oppRef, { pkSessionId: pkRef.id });
  });
  return { pkId: pkRef.id };
});

exports.pkTick = onSchedule('every 1 minutes', async () => {
  const snap = await db.collection('pk').where('active', '==', true)
    .where('endsAt', '<=', Timestamp.now()).limit(50).get();
  for (const doc of snap.docs) {
    const p = doc.data();
    const batch = db.batch();
    batch.update(doc.ref, { active: false });
    batch.update(db.collection('rooms').doc(p.roomA), { pkSessionId: FieldValue.delete() });
    batch.update(db.collection('rooms').doc(p.roomB), { pkSessionId: FieldValue.delete() });
    await batch.commit();
  }
});

// ---------- Segment Wheel: shared rounds ----------
const WHEEL = [
  { id: 'apple', x: 5 }, { id: 'mango', x: 5 }, { id: 'melon', x: 2 }, { id: 'pizza', x: 25 },
  { id: 'burger', x: 15 }, { id: 'fish', x: 10 }, { id: 'berry', x: 5 }, { id: 'lemon', x: 5 },
];
const BETTING_MS = 45 * 1000;

exports.placeWheelBet = onCall(async (req) => {
  const uid = uidOf(req);
  const roundId = String(req.data.roundId || '');
  const segmentId = String(req.data.segmentId || '');
  const amount = Number(req.data.amount);
  if (!WHEEL.some((s) => s.id === segmentId)) throw bad('Segment galat hai');
  if (!Number.isInteger(amount) || amount < 1 || amount > 1000) throw bad('Bet 1 se 1000 ke beech ho');
  const roundRef = db.collection('wheel_rounds').doc(roundId);
  const betRef = roundRef.collection('bets').doc(uid);
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const [r, bet, u] = await tx.getAll(roundRef, betRef, userRef);
    if (!r.exists) throw fail('Round nahi mila');
    if (r.data().settled || Date.now() >= r.data().bettingEndsAt.toMillis()) throw fail('Betting band ho chuki hai');
    if (bet.exists) throw fail('Is round mein aap pehle bet laga chuke hain');
    const coins = (u.data() || {}).coins || 0;
    if (coins < amount) throw fail('Coins kam hain');
    tx.update(userRef, { coins: coins - amount });
    tx.set(betRef, { segmentId, amount, createdAt: FieldValue.serverTimestamp() });
  });
  return { ok: true };
});

// Har minute: pichla round settle, naya round shuru
exports.wheelRoundTick = onSchedule('every 1 minutes', async () => {
  const latest = await db.collection('wheel_rounds').orderBy('startAt', 'desc').limit(1).get();
  const now = Date.now();
  if (!latest.empty) {
    const r = latest.docs[0];
    const d = r.data();
    if (!d.settled) {
      if (now < d.bettingEndsAt.toMillis()) return; // betting chal rahi hai
      await settleRound(r.ref);
    }
  }
  await db.collection('wheel_rounds').add({
    startAt: Timestamp.fromMillis(now),
    bettingEndsAt: Timestamp.fromMillis(now + BETTING_MS),
    settled: false,
    resultSegmentId: null,
  });
});

async function settleRound(roundRef) {
  const pick = WHEEL[crypto.randomInt(WHEEL.length)];
  const claimed = await db.runTransaction(async (tx) => {
    const r = await tx.get(roundRef);
    if (r.data().settled) return false;
    tx.update(roundRef, { settled: true, resultSegmentId: pick.id });
    return true;
  });
  if (!claimed) return;
  const bets = await roundRef.collection('bets').get();
  for (const b of bets.docs) {
    const bd = b.data();
    if (bd.segmentId !== pick.id) continue;
    const payout = bd.amount * pick.x; // jeet diamond mein
    await db.collection('users').doc(b.id).update({ diamonds: FieldValue.increment(payout) });
  }
}
