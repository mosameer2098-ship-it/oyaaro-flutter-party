// Games v13: server par chalte hain. Random = crypto (har round alag, predictable nahi).
// Har game ka result server par bante hi user ke coin katte hain, jeet diamond mein jaati hai.
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const crypto = require('crypto');
const db = getFirestore();

const GIFT_DIAMOND_SHARE_PERCENT = 50;
const BAG_AMOUNTS = [1000, 5000, 10000, 50000];
const BAG_USERS = [2, 5, 10, 20];
const CRASH_TARGETS = [1.5, 2.0, 3.0, 5.0];
const FRUIT_POOL = [0, 0, 0, 0, 2, 2, 3, 5, 5, 10, 20, 50];

function rnd(n) { return crypto.randomInt(n); }
function pick(arr) { return arr[rnd(arr.length)]; }
function uidOf(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  return req.auth.uid;
}

const GAMES = {
  lucky_seven_pro: { kind: 'slot', symbols: ['7','BAR','CHERRY','BELL','LEMON'], mult: {'7':50,BAR:20,CHERRY:10,BELL:5,LEMON:3} },
  baby_fruits: { kind: 'slot', symbols: ['APPLE','GRAPE','MANGO','BANANA'], mult: {APPLE:8,GRAPE:6,MANGO:10,BANANA:4} },
  lucky_fruit: { kind: 'slot', symbols: ['ORANGE','CHERRY','GRAPE'], mult: {ORANGE:10,CHERRY:20,GRAPE:6} },
  jester_star: { kind: 'slot', symbols: ['HAT','BALL','STAR'], mult: {HAT:15,BALL:10,STAR:25} },
  super_gems: { kind: 'slot', symbols: ['RUBY','EMERALD','SAPPHIRE','DIAMOND'], mult: {RUBY:5,EMERALD:10,SAPPHIRE:20,DIAMOND:50} },
  classic_777: { kind: 'slot', symbols: ['7','BAR','BELL'], mult: {'7':100,BAR:25,BELL:8} },
  mega_jackpot: { kind: 'slot', symbols: ['STAR','CROWN','JACKPOT'], mult: {STAR:10,CROWN:30,JACKPOT:200} },
  lucky_reels: { kind: 'slot', symbols: ['LUCKY','SEVEN','BAR','CHERRY'], mult: {LUCKY:30,SEVEN:9,BAR:4,CHERRY:3} },
  crash_rocket: { kind: 'crash' },
  gift_wheel: { kind: 'wheel', prizes: [0,0,0,1,2,5,10,25,50] },
  fruit_garden: { kind: 'fruit' },
  lucky_spin: { kind: 'wheel', prizes: [0,0,1,2,5,10], fixedBet: 10 },
};

// ---- Game play ----
// opts: pick (fruit 1..12 | crash target), advanced (slot: 2x stake, extra chance), draws (wheel: 1 ya 10)
exports.playGame = onCall(async (req) => {
  const uid = uidOf(req);
  const game = GAMES[String(req.data.gameId || '')];
  if (!game) throw new HttpsError('not-found', 'Game nahi mila');
  let bet = Number(req.data.bet);
  if (game.fixedBet) bet = game.fixedBet;
  if (!Number.isInteger(bet) || bet < 1 || bet > 1000) {
    throw new HttpsError('invalid-argument', 'Bet 1 se 1000 ke beech ho');
  }
  const advanced = req.data.advanced === true;
  const draws = Number(req.data.draws || 1);
  const pickNo = Number(req.data.pick || 0);
  const target = Number(req.data.target || 2.0);

  let stakeMult = 1;
  if (game.kind === 'slot' && advanced) stakeMult = 2;
  if (game.kind === 'wheel' && !game.fixedBet) {
    if (draws !== 1 && draws !== 10) throw new HttpsError('invalid-argument', '1 ya 10 draws chunein');
    stakeMult = draws;
  }
  if (game.kind === 'fruit' && (!Number.isInteger(pickNo) || pickNo < 1 || pickNo > 12)) {
    throw new HttpsError('invalid-argument', 'Ek fruit cell chunein');
  }
  if (game.kind === 'crash' && !CRASH_TARGETS.includes(target)) {
    throw new HttpsError('invalid-argument', 'Target galat hai');
  }
  const total = bet * stakeMult;

  let payout = 0;
  let text = '';
  let cells = null;

  if (game.kind === 'slot') {
    const reels = [pick(game.symbols), pick(game.symbols), pick(game.symbols)];
    if (advanced && reels[0] === reels[1] && reels[2] !== reels[0]) {
      reels[2] = pick(game.symbols); // advanced: 2 same aaye to third reel ek baar aur ghoomti hai
    }
    const label = reels.join(' | ');
    if (new Set(reels).size === 1 && (game.mult[reels[0]] || 0) > 0) {
      payout = bet * game.mult[reels[0]];
      text = `${label}  ->  Teen ${reels[0]}! x${game.mult[reels[0]]}`;
    } else {
      text = `${label}  ->  Is baar haar gaye`;
    }
  } else if (game.kind === 'wheel') {
    const hits = [];
    for (let i = 0; i < stakeMult; i++) {
      const m = pick(game.prizes);
      hits.push(m);
      payout += bet * m;
    }
    text = `${stakeMult} draw: total ${payout} Diamond`;
  } else if (game.kind === 'fruit') {
    cells = Array.from({ length: 12 }, () => pick(FRUIT_POOL));
    payout = bet * cells[pickNo - 1];
    text = cells[pickNo - 1] > 0 ? `Cell ${pickNo}: x${cells[pickNo - 1]}!` : `Cell ${pickNo} khali nikla`;
  } else if (game.kind === 'crash') {
    const u = crypto.randomInt(1e9) / 1e9;
    const crash = Math.max(1.0, 0.97 / (1 - u));
    const cl = crash.toFixed(2);
    if (crash >= target) {
      payout = Math.floor(bet * target);
      text = `Rocket ${cl}x par phata. ${target}x par nikle!`;
    } else {
      text = `Rocket ${cl}x par phata. ${target}x tak nahi pahunche`;
    }
  }

  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'User nahi mila');
    const coins = snap.data().coins || 0;
    if (coins < total) throw new HttpsError('failed-precondition', 'Coins kam hain');
    tx.update(ref, {
      coins: coins - total,
      exp: FieldValue.increment(total),
      diamonds: FieldValue.increment(payout),
    });
  });
  return { payout, text, cells };
});

// ---- Lucky Bag: sender coins bhejta hai, room mein bag aata hai, users Claim karte hain ----
exports.sendBag = onCall(async (req) => {
  const uid = uidOf(req);
  const roomId = String(req.data.roomId || '');
  const amount = Number(req.data.amount);
  const users = Number(req.data.users);
  if (!BAG_AMOUNTS.includes(amount) || !BAG_USERS.includes(users)) {
    throw new HttpsError('invalid-argument', 'Galat amount ya users');
  }
  const roomRef = db.collection('rooms').doc(roomId);
  const senderRef = db.collection('users').doc(uid);
  const bagRef = db.collection('bags').doc();
  const msgRef = roomRef.collection('messages').doc();

  await db.runTransaction(async (tx) => {
    const [room, sender] = await tx.getAll(roomRef, senderRef);
    if (!room.exists) throw new HttpsError('not-found', 'Room nahi mila');
    if (!sender.exists) throw new HttpsError('not-found', 'User nahi mila');
    const s = sender.data();
    if ((s.coins || 0) < amount) throw new HttpsError('failed-precondition', 'Coins kam hain');
    tx.update(senderRef, { coins: s.coins - amount, exp: FieldValue.increment(amount) });
    tx.set(bagRef, {
      roomId, senderUid: uid, amount, users, claimed: [], createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(msgRef, {
      uid, name: s.name || 'User', type: 'bag', text: bagRef.id, createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { bagId: bagRef.id };
});

exports.claimBag = onCall(async (req) => {
  const uid = uidOf(req);
  const bagId = String(req.data.bagId || '');
  const bagRef = db.collection('bags').doc(bagId);
  const userRef = db.collection('users').doc(uid);

  const share = await db.runTransaction(async (tx) => {
    const [bagSnap, userSnap] = await tx.getAll(bagRef, userRef);
    if (!bagSnap.exists) throw new HttpsError('not-found', 'Bag nahi mila');
    if (!userSnap.exists) throw new HttpsError('not-found', 'User nahi mila');
    const b = bagSnap.data();
    const claimed = b.claimed || [];
    if (b.senderUid === uid) throw new HttpsError('failed-precondition', 'Apna bag claim nahi kar sakte');
    if (claimed.includes(uid)) throw new HttpsError('already-exists', 'Aap ye bag le chuke hain');
    if (claimed.length >= b.users) throw new HttpsError('failed-precondition', 'Bag khatam ho gaya');
    const perUser = Math.floor((b.amount * GIFT_DIAMOND_SHARE_PERCENT) / 100 / b.users);
    tx.update(bagRef, { claimed: [...claimed, uid] });
    tx.update(userRef, { diamonds: FieldValue.increment(perUser) });
    return perUser;
  });
  return { diamonds: share };
});
