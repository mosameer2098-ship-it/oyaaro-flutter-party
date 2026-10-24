// Economy server par: gift, game aur diamond convert. Client sirf call karta hai.
// Coin khareedna: recharge (index.js). Yahan sirf in-app badlav hote hain.
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const db = getFirestore();

// ---- Wallet rules (client core/wallet_rules.dart se same) ----
const GIFT_DIAMOND_SHARE_PERCENT = 50; // gift ki price ka 50% receiver ko diamond
const CONVERT_DIAMONDS = 100;          // 100 diamond ...
const CONVERT_COINS = 80;              // ... = 80 coin
const FREE_GIFT_DAILY = 5;
const EVENT_START = new Date('2026-10-01T00:00:00');
const EVENT_END = new Date('2026-12-31T23:59:00');

// ---- Gift catalog (client core/gift_catalog.dart se same list) ----
const NORMAL_BASE = ['Rose','Heart','Teddy','Cake','Diamond','Sports Car','Private Jet','Castle','Crown','Galaxy','Lion','Tiger','Dragon','Phoenix','Unicorn','Star','Moon','Sun','Ring','Perfume','Guitar','Piano','Trophy','Medal','Yacht','Island','Palace','Bear','Dolphin','Fox'];
const VARIANTS = ['Mini','Classic','Premium','Deluxe'];
const VARIANT_PRICE = [10, 50, 300, 1000];
const CP_NAMES = ['Love Letter','Couple Ring','Heart Lock','Twin Hearts','Cupid Arrow','Love Bird','Love Tree','Moon Date','Sunset Date','Candle Dinner','Love Song','Promise Ring','Teddy Pair','Love Balloon','Rose Bouquet','Kiss Emoji','Sweet Heart','Forever Ring','Love Boat','Starry Night','Couple Crown','Love Cake','Love Wings','Infinity Band','Hug Bear','Love Castle','Heart Sparkle','Cute Pair','Paper Hearts','Cupid Gold'];
const FRIEND_NAMES = ['Hug','Handshake','Buddy Badge','High Five','Friend Bracelet','Best Friend Cup','Smile Pack','Team Flag','Thumbs Up','Party Hat','Friend Cake','Shared Ticket','Buddy Bear','Wave Hello','Friend Star','Chill Pack','Friend Rocket','Pizza Night','Coffee Date','Game Night'];
const VIP_NAMES = ['VIP Badge','VIP Crest','VIP Ticket','VIP Chair','VIP Champagne','VIP Limo','VIP Yacht','VIP Lounge','VIP Diamond Card','VIP Gold Pass','VIP Jet Ticket','VIP Mansion Key','VIP Spotlight','VIP Crown Seal','VIP Vault','VIP Star Ring','VIP Throne','VIP Aurora','VIP Empire','VIP Legend'];
const FREE_NAMES = ['Free Flower','Free Wave','Free Clap','Free Hi','Free Sparkle','Free Smile','Free Breeze','Free Echo','Free Bubble','Free Star'];
const EVENT_NAMES = ['Diwali Diya','Holi Color','New Year Fireworks','Eid Crescent','Christmas Tree','Independence Flag','Cricket Trophy','Festival Lamp','Summer Fest','Anniversary Cake'];

function buildGifts() {
  const list = [];
  const add = (name, price, category, minVip = 0) => list.push({ name, price, category, minVip });
  NORMAL_BASE.forEach((base, b) => VARIANTS.forEach((v, vi) => add(`${v} ${base}`, VARIANT_PRICE[vi] * (1 + (b % 5)), 'normal')));
  CP_NAMES.forEach((n, i) => add(n, 50 * (i + 1), 'cp'));
  FRIEND_NAMES.forEach((n, i) => add(n, 20 * (i + 1), 'friend'));
  VIP_NAMES.forEach((n, i) => add(n, 500 * (i + 1), 'vip', Math.min(9, Math.floor(i / 2) + 1)));
  FREE_NAMES.forEach((n) => add(n, 0, 'free'));
  EVENT_NAMES.forEach((n, i) => add(n, 100 * (i + 1), 'event'));
  return list;
}
const GIFTS = new Map(buildGifts().map((g) => [g.name, g]));

// ---- Games (client core/game_catalog.dart se same) ----
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
  lucky_bag: { kind: 'bag', prizes: [0,0,1,1,2,5,10] },
  lucky_spin: { kind: 'wheel', prizes: [0,0,1,2,5,10], fixedBet: 10 },
};
const CRASH_TARGETS = [1.5, 2.0, 3.0, 5.0];

function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

function playOutcome(game, bet, pickNo, target) {
  if (game.kind === 'slot') {
    const reels = [pick(game.symbols), pick(game.symbols), pick(game.symbols)];
    const label = reels.join(' | ');
    if (new Set(reels).size === 1) {
      const m = game.mult[reels[0]] || 0;
      if (m > 0) return { payout: bet * m, text: `${label}  ->  Teen ${reels[0]}! x${m}` };
    }
    return { payout: 0, text: `${label}  ->  Is baar haar gaye` };
  }
  if (game.kind === 'wheel') {
    const m = pick(game.prizes);
    return m === 0 ? { payout: 0, text: 'Wheel ruka: haar' } : { payout: bet * m, text: `Wheel ruka: x${m}!` };
  }
  if (game.kind === 'bag') {
    const m = pick(game.prizes);
    return m === 0 ? { payout: 0, text: `Envelope ${pickNo} khali nikla` } : { payout: bet * m, text: `Envelope ${pickNo}: x${m}!` };
  }
  // crash
  const u = Math.random();
  const crash = Math.max(1.0, 0.97 / (1 - u));
  const cl = crash.toFixed(2);
  if (crash >= target) return { payout: Math.floor(bet * target), text: `Rocket ${cl}x par phata. ${target}x par nikle!` };
  return { payout: 0, text: `Rocket ${cl}x par phata. ${target}x tak nahi pahunche` };
}

function uidOf(req) {
  if (!req.auth) throw new HttpsError('unauthenticated', 'Login karein');
  return req.auth.uid;
}

function todayKey() { return new Date().toISOString().slice(0, 10); }

// ---- Gift: sender ke coin kategein, receiver ko diamond milte hain ----
// type: 'room' (target = roomId) | 'dm' (target = convId)
exports.sendGift = onCall(async (req) => {
  const uid = uidOf(req);
  const type = String(req.data.type || '');
  const target = String(req.data.target || '');
  const gift = GIFTS.get(String(req.data.gift || ''));
  if (!gift) throw new HttpsError('not-found', 'Gift nahi mila');
  if (!target || (type !== 'room' && type !== 'dm')) throw new HttpsError('invalid-argument', 'Galat data');

  const isDmGift = gift.category === 'cp' || gift.category === 'friend';
  if (type === 'room' && isDmGift) throw new HttpsError('failed-precondition', 'Ye gift chat mein bhejein');
  if (type === 'dm' && !isDmGift) throw new HttpsError('failed-precondition', 'Ye gift room mein bhejein');
  const now = new Date();
  if (gift.category === 'event' && (now < EVENT_START || now > EVENT_END)) {
    throw new HttpsError('failed-precondition', 'Event abhi active nahi hai');
  }

  const senderRef = db.collection('users').doc(uid);
  const targetRef = type === 'room' ? db.collection('rooms').doc(target) : db.collection('conversations').doc(target);
  const msgRef = targetRef.collection('messages').doc();

  await db.runTransaction(async (tx) => {
    const [sender, t] = await tx.getAll(senderRef, targetRef);
    if (!sender.exists) throw new HttpsError('not-found', 'User nahi mila');
    if (!t.exists) throw new HttpsError('not-found', 'Room ya chat nahi mila');
    const s = sender.data();

    let receiverUid;
    if (type === 'room') {
      receiverUid = t.data().hostUid;
    } else {
      const parts = t.data().participants || [];
      if (!parts.includes(uid)) throw new HttpsError('permission-denied', 'Ye chat aapki nahi hai');
      receiverUid = parts.find((p) => p !== uid);
    }
    if (receiverUid === uid) throw new HttpsError('failed-precondition', 'Khud ko gift nahi bhej sakte');

    if (gift.minVip > 0 && (s.vip || 0) < gift.minVip) {
      throw new HttpsError('failed-precondition', `VIP ${gift.minVip} chahiye`);
    }

    const senderUpdate = {};
    if (gift.price > 0) {
      if ((s.coins || 0) < gift.price) throw new HttpsError('failed-precondition', 'Coins kam hain');
      senderUpdate.coins = (s.coins || 0) - gift.price;
      senderUpdate.exp = FieldValue.increment(gift.price);
    } else {
      const used = s.freeGiftDay === todayKey() ? (s.freeGiftCount || 0) : 0;
      if (used >= FREE_GIFT_DAILY) throw new HttpsError('resource-exhausted', `Aaj ke ${FREE_GIFT_DAILY} free gifts khatam`);
      senderUpdate.freeGiftDay = todayKey();
      senderUpdate.freeGiftCount = used + 1;
    }
    const medals = s.medals || {};
    senderUpdate[`medals.${gift.name}`] = undefined; // placeholder, replaced below
    delete senderUpdate[`medals.${gift.name}`];
    senderUpdate.medals = { ...medals, [gift.name]: (medals[gift.name] || 0) + 1 };

    // Receiver ko diamond (free gift par 0)
    const diamondShare = Math.floor((gift.price * GIFT_DIAMOND_SHARE_PERCENT) / 100);
    const receiverRef = db.collection('users').doc(receiverUid);
    const receiver = await tx.get(receiverRef);
    if (receiver.exists && diamondShare > 0) {
      tx.update(receiverRef, { diamonds: FieldValue.increment(diamondShare) });
    }

    tx.update(senderRef, senderUpdate);
    if (type === 'room') {
      tx.set(msgRef, { uid, name: s.name || 'User', type: 'gift', text: gift.name, createdAt: FieldValue.serverTimestamp() });
    } else {
      tx.set(msgRef, { uid, text: gift.name, type: 'gift', createdAt: FieldValue.serverTimestamp() });
      tx.update(targetRef, { lastText: `Gift: ${gift.name}`, cpExp: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp() });
    }
  });
  return { ok: true };
});

// ---- Diamond -> coin (cash nahi) ----
exports.convertDiamonds = onCall(async (req) => {
  const uid = uidOf(req);
  const amount = Number(req.data.amount);
  if (!Number.isInteger(amount) || amount < CONVERT_DIAMONDS || amount % CONVERT_DIAMONDS !== 0) {
    throw new HttpsError('invalid-argument', `${CONVERT_DIAMONDS} ke multiple mein convert karein`);
  }
  const coinsOut = (amount / CONVERT_DIAMONDS) * CONVERT_COINS;
  const ref = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const d = snap.data() || {};
    if ((d.diamonds || 0) < amount) throw new HttpsError('failed-precondition', 'Diamond kam hain');
    tx.update(ref, { diamonds: (d.diamonds || 0) - amount, coins: (d.coins || 0) + coinsOut });
  });
  return { coins: coinsOut };
});
