// Backup aur restore. Sirf admin (role == 'admin') ye chala sakta hai.
// Full backup: Firestore managed export -> Cloud Storage bucket (daily auto + admin ke liye on-demand)
// User backup: ek user ka doc JSON ki tarah 'user_backups' mein save.
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const firestoreAdmin = require('@google-cloud/firestore');

const db = getFirestore();
const adminClient = new firestoreAdmin.v1.FirestoreAdminClient();

// Bucket ka naam: env BACKUP_BUCKET, nahi to <project-id>-backups
function bucketName() {
  return process.env.BACKUP_BUCKET || `${process.env.GCLOUD_PROJECT}-backups`;
}

async function requireAdmin(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  const snap = await db.collection('users').doc(req.auth.uid).get();
  if (!snap.exists || snap.data().role !== 'admin') {
    throw new HttpsError('permission-denied', 'Sirf admin ye kar sakta hai');
  }
  return req.auth.uid;
}

// Poore database ka export shuru karta hai (background mein chalta hai)
async function startExport(label) {
  const projectId = process.env.GCLOUD_PROJECT;
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const path = `gs://${bucketName()}/backups/${stamp}_${label}`;
  const name = adminClient.databasePath(projectId, '(default)');
  const [operation] = await adminClient.exportDocuments({
    name,
    outputUriPrefix: path,
    collectionIds: [],
  });
  const ref = await db.collection('backups').add({
    path,
    label,
    operation: operation.name,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { backupId: ref.id, path };
}

// Har din raat 3 baje (India time) automatic backup
exports.dailyBackup = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Asia/Kolkata' },
  async () => {
    await startExport('auto');
  },
);

exports.adminBackupNow = onCall(async (req) => {
  await requireAdmin(req);
  return startExport('manual');
});

exports.adminListBackups = onCall(async (req) => {
  await requireAdmin(req);
  const snap = await db.collection('backups').orderBy('createdAt', 'desc').limit(50).get();
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
});

// DANGER: database ko backup se wapas bharta hai. confirm mein 'RESTORE' likhna zaroori hai.
exports.adminRestoreFull = onCall(async (req) => {
  const callerUid = await requireAdmin(req);
  const backupId = String(req.data.backupId || '');
  if (req.data.confirm !== 'RESTORE') {
    throw new HttpsError('failed-precondition', 'Confirm ke liye RESTORE likhein');
  }
  const b = await db.collection('backups').doc(backupId).get();
  if (!b.exists) throw new HttpsError('not-found', 'Backup nahi mila');

  const projectId = process.env.GCLOUD_PROJECT;
  const name = adminClient.databasePath(projectId, '(default)');
  await adminClient.importDocuments({
    name,
    inputUriPrefix: b.data().path,
    collectionIds: [],
  });
  await db.collection('restores').add({
    backupId,
    by: callerUid,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

// Ek user ka backup (doc + role/coins/exp/vip/frames sab usi doc mein hain)
exports.adminBackupUser = onCall(async (req) => {
  const callerUid = await requireAdmin(req);
  const uid = String(req.data.uid || '');
  const snap = await db.collection('users').doc(uid).get();
  if (!snap.exists) throw new HttpsError('not-found', 'User nahi mila');
  const ref = await db.collection('user_backups').add({
    uid,
    data: snap.data(),
    by: callerUid,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { backupId: ref.id };
});

exports.adminListUserBackups = onCall(async (req) => {
  await requireAdmin(req);
  const uid = String(req.data.uid || '');
  const snap = await db.collection('user_backups').where('uid', '==', uid).limit(50).get();
  return snap.docs.map((d) => ({ id: d.id, createdAt: d.data().createdAt ? d.data().createdAt.toDate().toISOString() : null }));
});

// User ka data backup se wapas: users/{uid} ko backup ke data se replace karta hai
exports.adminRestoreUser = onCall(async (req) => {
  await requireAdmin(req);
  const uid = String(req.data.uid || '');
  const backupId = String(req.data.backupId || '');
  const b = await db.collection('user_backups').doc(backupId).get();
  if (!b.exists || b.data().uid !== uid) throw new HttpsError('not-found', 'Backup nahi mila');
  const data = { ...b.data().data };
  // role admin backup se change na ho, uske liye current role rakhein
  const current = await db.collection('users').doc(uid).get();
  if (current.exists) data.role = current.data().role || 'user';
  await db.collection('users').doc(uid).set(data);
  return { ok: true };
});
