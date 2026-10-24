import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js';
import {
  getAuth, GoogleAuthProvider, signInWithPopup, signOut, onAuthStateChanged,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js';
import {
  getFirestore, doc, getDoc, collection, getDocs, limit, query,
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import { getFunctions, httpsCallable } from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-functions.js';
import { firebaseConfig, REGION } from './config.js';

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const fns = getFunctions(app, REGION);

const call = (name, data = {}) => httpsCallable(fns, name)(data).then((r) => r.data);
const $ = (id) => document.getElementById(id);
const say = (text, bad = false) => { $('msg').textContent = text; $('msg').className = bad ? 'msg err' : 'msg'; };

function esc(s) {
  return String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

$('loginBtn').onclick = async () => {
  try {
    await signInWithPopup(auth, new GoogleAuthProvider());
  } catch (e) {
    $('loginMsg').textContent = e.message;
  }
};
$('logout').onclick = () => signOut(auth);

onAuthStateChanged(auth, async (user) => {
  if (!user) {
    $('login').hidden = false; $('app').hidden = true; $('logout').hidden = true;
    return;
  }
  // Role check: sirf admin ko panel dikhega (server bhi check karta hai)
  const snap = await getDoc(doc(db, 'users', user.uid));
  if (!snap.exists() || snap.data().role !== 'admin') {
    $('loginMsg').textContent = 'Ye account admin nahi hai.';
    await signOut(auth);
    return;
  }
  $('login').hidden = true; $('app').hidden = false; $('logout').hidden = false;
  loadBackups();
  loadUsers();
});

// ---------- Full backup ----------
async function loadBackups() {
  try {
    const list = await call('adminListBackups');
    $('backups').innerHTML = list.map((b) => {
      const t = b.createdAt && b.createdAt._seconds ? new Date(b.createdAt._seconds * 1000).toLocaleString() : 'abhi';
      return `<tr><td>${esc(t)}</td><td>${esc(b.label)}</td><td><small>${esc(b.path)}</small></td>
        <td><button class="danger" data-restore="${esc(b.id)}">Restore</button></td></tr>`;
    }).join('') || '<tr><td colspan="4">Abhi koi backup nahi</td></tr>';
  } catch (e) {
    say(e.message, true);
  }
}

$('backupNow').onclick = async () => {
  try {
    await call('adminBackupNow');
    say('Backup shuru ho gaya. Kuch minute baad list mein dikhega.');
    setTimeout(loadBackups, 3000);
  } catch (e) { say(e.message, true); }
};

$('backups').onclick = async (e) => {
  const id = e.target.dataset.restore;
  if (!id) return;
  const typed = prompt('DATABASE POORA BACKUP SE REPLACE HOGA. Confirm karne ke liye RESTORE likhein:');
  if (typed !== 'RESTORE') return say('Restore cancel ho gaya.', true);
  try {
    await call('adminRestoreFull', { backupId: id, confirm: 'RESTORE' });
    say('Restore shuru ho gaya. Ye kuch minute le sakta hai.');
  } catch (err) { say(err.message, true); }
};

// ---------- Users ----------
let allUsers = [];

async function loadUsers() {
  const snap = await getDocs(query(collection(db, 'users'), limit(300)));
  allUsers = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
  renderUsers();
}

function renderUsers() {
  const q = $('search').value.trim().toLowerCase();
  const rows = allUsers
    .filter((u) => !q || (u.name || '').toLowerCase().includes(q) || u.id.toLowerCase().includes(q))
    .map((u) => `<tr>
      <td>${esc(u.name)}</td>
      <td><small>${esc(u.id)}</small></td>
      <td>${esc(u.coins ?? 0)}</td>
      <td>${esc(u.role || 'user')}</td>
      <td>
        <button data-act="userbackup" data-uid="${esc(u.id)}">Backup</button>
        <button data-act="userrestore" data-uid="${esc(u.id)}">Restore</button>
        <button data-act="agent" data-uid="${esc(u.id)}">Agent banao</button>
      </td></tr>`);
  $('users').innerHTML = rows.join('') || '<tr><td colspan="5">Koi user nahi</td></tr>';
}

$('search').oninput = renderUsers;

$('users').onclick = async (e) => {
  const { act, uid } = e.target.dataset;
  if (!act) return;
  try {
    if (act === 'userbackup') {
      const r = await call('adminBackupUser', { uid });
      say(`User ka backup save ho gaya. Backup ID: ${r.backupId}`);
    } else if (act === 'userrestore') {
      const list = await call('adminListUserBackups', { uid });
      if (!list.length) return say('Is user ka koi backup nahi hai', true);
      const id = prompt('Backup ID chunein:\n' + list.map((b) => `${b.id}  ${b.createdAt || ''}`).join('\n'));
      if (!id) return;
      await call('adminRestoreUser', { uid, backupId: id.trim() });
      say('User ka data backup se wapas aa gaya.');
      loadUsers();
    } else if (act === 'agent') {
      await call('adminSetRole', { uid, role: 'agent' });
      say('Agent bana diya.');
      loadUsers();
    }
  } catch (err) { say(err.message, true); }
};

$('addStock').onclick = async () => {
  try {
    await call('adminAddStock', { agentUid: $('agentUid').value.trim(), coins: Number($('stock').value) });
    say('Stock badh gaya.');
  } catch (err) { say(err.message, true); }
};
