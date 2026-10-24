// Heloza base v16 server logic. Host functions/index.js mein:
//   Object.assign(exports, require('./base_v16'));
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const crypto = require('crypto');
const db = getFirestore();

const fail = (m) => new HttpsError('failed-precondition', m);
const deny = (m) => new HttpsError('permission-denied', m);
const bad = (m) => new HttpsError('invalid-argument', m);
function uidOf(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  return req.auth.uid;
}
async function isAdmin(uid) {
  const d = (await db.collection('users').doc(uid).get()).data() || {};
  return ['admin', 'superadmin'].includes(d.role);
}
const sha = (s) => crypto.createHash('sha256').update(s).digest('hex');

// ---------- Room roles: host, admin, moderator, member ----------
const ROLE_LEVELS = { host: 4, admin: 3, moderator: 2, member: 1 };
function roleOfIn(room, uid) {
  if (room.hostUid === uid) return 'host';
  return (room.roles || {})[uid] || 'member';
}

exports.setRoomRole = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const target = String(req.data.uid || '');
  const role = String(req.data.role || '');
  if (!['admin', 'moderator', 'member'].includes(role)) throw bad('Role galat hai');
  const ref = db.collection('rooms').doc(roomId);
  await db.runTransaction(async (tx) => {
    const room = (await tx.get(ref)).data();
    if (!room) throw fail('Room nahi mila');
    if (roleOfIn(room, uid) !== 'host') throw deny('Sirf host role badal sakta hai');
    if (target === room.hostUid) throw fail('Host ka role nahi badal sakte');
    tx.update(ref, { [`roles.${target}`]: role });
  });
  return { ok: true };
});

// Seat request: member request karta hai, host/admin approve karta hai
exports.requestSeat = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const seatIndex = Number(req.data.seatIndex);
  const ref = db.collection('rooms').doc(roomId);
  const room = (await ref.get()).data();
  if (!room) throw fail('Room nahi mila');
  if (!Number.isInteger(seatIndex) || seatIndex < 1 || seatIndex >= (room.seatCount || 0)) throw bad('Seat galat hai');
  await ref.collection('seatRequests').doc(uid).set({
    seatIndex, status: 'pending', createdAt: FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

exports.resolveSeatRequest = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const target = String(req.data.uid || '');
  const approve = req.data.approve === true;
  const roomRef = db.collection('rooms').doc(roomId);
  const reqRef = roomRef.collection('seatRequests').doc(target);
  await db.runTransaction(async (tx) => {
    const [room, sr, tu] = await tx.getAll(roomRef, reqRef, db.collection('users').doc(target));
    if (!room.exists || !sr.exists) throw fail('Request nahi mili');
    const rd = room.data();
    const role = roleOfIn(rd, uid);
    if (ROLE_LEVELS[role] < ROLE_LEVELS.moderator) throw deny('Sirf host, admin ya moderator approve kar sakta hai');
    if (sr.data().status !== 'pending') throw fail('Request already resolved');
    if (!approve) {
      tx.update(reqRef, { status: 'rejected' });
      return;
    }
    const idx = sr.data().seatIndex;
    const seats = (rd.seats || []).map((s) => ({ ...s }));
    if (seats[idx] && seats[idx].uid) throw fail('Seat bhari hai');
    seats[idx] = { uid: target, name: (tu.data() || {}).name || 'User', muted: true };
    tx.update(roomRef, { seats });
    tx.update(reqRef, { status: 'approved' });
  });
  return { ok: true };
});

// Room lock + password (hash save, verify)
exports.setRoomPassword = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const password = String(req.data.password || '');
  const ref = db.collection('rooms').doc(roomId);
  const room = (await ref.get()).data();
  if (!room) throw fail('Room nahi mila');
  if (roleOfIn(room, uid) !== 'host') throw deny('Sirf host password set kar sakta hai');
  if (password === '') {
    await ref.update({ passwordHash: FieldValue.delete() });
  } else {
    if (password.length < 4 || password.length > 12) throw bad('Password 4 se 12 characters ka ho');
    await ref.update({ passwordHash: sha(password) });
  }
  return { ok: true };
});

exports.verifyRoomPassword = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const room = (await db.collection('rooms').doc(roomId).get()).data();
  if (!room) throw fail('Room nahi mila');
  if (!room.passwordHash) return { ok: true };
  if (roleOfIn(room, uid) === 'host') return { ok: true };
  if (sha(String(req.data.password || '')) !== room.passwordHash) throw deny('Password galat hai');
  return { ok: true };
});

// ---------- Moderation ----------
exports.reportUser = onCall(async (req) => {
  const uid = uidOf(req);
  const target = String(req.data.targetUid || '');
  const reason = String(req.data.reason || '').trim();
  const roomId = req.data.roomId ? String(req.data.roomId) : null;
  if (!target || target === uid) throw bad('Galat user');
  if (reason.length < 3 || reason.length > 300) throw bad('Reason 3 se 300 letters ka ho');
  // ek user same target ko ek hi baar report kar sakta hai (rate limit)
  const id = `${uid}_${target}`;
  await db.collection('reports').doc(id).set({
    reporterUid: uid, targetUid: target, reason, roomId, status: 'open',
    createdAt: FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

// Admin: report par action. dismiss | mute (minutes) | ban
exports.resolveReport = onCall(async (req) => {
  const uid = uidOf(req);
  if (!(await isAdmin(uid))) throw deny('Sirf admin');
  const id = String(req.data.reportId || '');
  const action = String(req.data.action || '');
  const ref = db.collection('reports').doc(id);
  const rep = (await ref.get()).data();
  if (!rep) throw fail('Report nahi mila');
  const userRef = db.collection('users').doc(rep.targetUid);
  if (action === 'dismiss') {
    await ref.update({ status: 'dismissed', resolvedBy: uid });
  } else if (action === 'mute') {
    const mins = Number(req.data.minutes || 60);
    if (!(mins > 0 && mins <= 60 * 24 * 7)) throw bad('Mute time galat hai');
    await userRef.update({ mutedUntil: Timestamp.fromMillis(Date.now() + mins * 60000) });
    await ref.update({ status: 'actioned', action: 'mute', resolvedBy: uid });
  } else if (action === 'ban') {
    await userRef.update({ banned: true });
    await ref.update({ status: 'actioned', action: 'ban', resolvedBy: uid });
  } else {
    throw bad('Action galat hai');
  }
  return { ok: true };
});

// ---------- Referral ----------
function randomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let out = '';
  for (let i = 0; i < 8; i++) out += chars[crypto.randomInt(chars.length)];
  return out;
}
exports.ensureReferralCode = onCall(async (req) => {
  const uid = uidOf(req);
  const userRef = db.collection('users').doc(uid);
  const existing = (await userRef.get()).data() || {};
  if (existing.referralCode) return { code: existing.referralCode };
  for (let attempt = 0; attempt < 5; attempt++) {
    const code = randomCode();
    const codeRef = db.collection('referralCodes').doc(code);
    const ok = await db.runTransaction(async (tx) => {
      if ((await tx.get(codeRef)).exists) return false;
      tx.set(codeRef, { uid, createdAt: FieldValue.serverTimestamp() });
      tx.update(userRef, { referralCode: code });
      return true;
    });
    if (ok) return { code };
  }
  throw fail('Code ban nahi paaya, dobara koshish karein');
});

const REFERRAL_REWARD = 200;
exports.redeemReferral = onCall(async (req) => {
  const uid = uidOf(req);
  const code = String(req.data.code || '').trim().toUpperCase();
  if (!/^[A-Z2-9]{8}$/.test(code)) throw bad('Code galat hai');
  const codeRef = db.collection('referralCodes').doc(code);
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const [c, u] = await tx.getAll(codeRef, userRef);
    if (!c.exists) throw fail('Code nahi mila');
    const ownerUid = c.data().uid;
    if (ownerUid === uid) throw fail('Apna code nahi use kar sakte');
    const ud = u.data() || {};
    if (ud.redeemedReferral) throw fail('Aap pehle hi referral use kar chuke hain');
    const ownerRef = db.collection('users').doc(ownerUid);
    const owner = (await tx.get(ownerRef)).data() || {};
    tx.update(userRef, { redeemedReferral: code, coins: (ud.coins || 0) + REFERRAL_REWARD });
    tx.update(ownerRef, { coins: (owner.coins || 0) + REFERRAL_REWARD });
  });
  return { ok: true, reward: REFERRAL_REWARD };
});

// ---------- Daily check-in ----------
const CHECKIN_BASE = 50;
exports.checkIn = onCall(async (req) => {
  const uid = uidOf(req);
  const ref = db.collection('users').doc(uid);
  const today = new Date().toISOString().slice(0, 10);
  let reward = 0;
  let streak = 0;
  await db.runTransaction(async (tx) => {
    const d = (await tx.get(ref)).data() || {};
    if (d.lastCheckIn === today) throw fail('Aaj ka check-in ho chuka hai');
    const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
    streak = d.lastCheckIn === yesterday ? (d.checkInStreak || 0) + 1 : 1;
    reward = CHECKIN_BASE * Math.min(streak, 7);
    tx.update(ref, { lastCheckIn: today, checkInStreak: streak, coins: (d.coins || 0) + reward });
  });
  return { reward, streak };
});

// ---------- Account deletion request (30 din baad admin/job delete karega) ----------
exports.requestAccountDeletion = onCall(async (req) => {
  const uid = uidOf(req);
  await db.collection('deletion_requests').doc(uid).set({
    uid, requestedAt: FieldValue.serverTimestamp(),
    executeAfter: Timestamp.fromMillis(Date.now() + 30 * 86400000), status: 'pending',
  });
  await db.collection('users').doc(uid).update({ deletionRequested: true });
  return { ok: true };
});

// ---------- Ledger helper: coin/diamond ka har badlav yahan se log ho ----------
// Use: writeLedger(tx, uid, { type, coins, diamonds, note })
function writeLedger(tx, uid, entry) {
  const ref = db.collection('users').doc(uid).collection('ledger').doc();
  tx.set(ref, { ...entry, createdAt: FieldValue.serverTimestamp() });
}
exports.writeLedger = writeLedger;
