const admin = require('firebase-admin');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {setGlobalOptions} = require('firebase-functions');
const {AccessToken} = require('livekit-server-sdk');

admin.initializeApp();
setGlobalOptions({maxInstances: 10});

const LIVEKIT_URL = defineSecret('LIVEKIT_URL');
const LIVEKIT_API_KEY = defineSecret('LIVEKIT_API_KEY');
const LIVEKIT_API_SECRET = defineSecret('LIVEKIT_API_SECRET');

exports.getLiveKitToken = onCall({
  region: 'us-central1',
  timeoutSeconds: 30,
  maxInstances: 10,
  secrets: [LIVEKIT_URL, LIVEKIT_API_KEY, LIVEKIT_API_SECRET],
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Please sign in first.');
  }

  const roomId = request.data?.roomId;
  if (typeof roomId !== 'string' || !roomId.trim() ||
      roomId.length > 128 || roomId.includes('/')) {
    throw new HttpsError('invalid-argument', 'A valid roomId is required.');
  }

  let snapshot;
  try {
    snapshot = await admin.firestore().collection('rooms').doc(roomId).get();
  } catch (error) {
    console.error('Room membership lookup failed:', error);
    throw new HttpsError('internal', 'Could not verify room access.');
  }

  if (!snapshot.exists) {
    throw new HttpsError('not-found', 'Room does not exist.');
  }

  const room = snapshot.data() || {};
  const uid = request.auth.uid;
  const isHost = room.hostUid === uid;
  const seats = Array.isArray(room.seats) ? room.seats : [];
  const occupiedSeat = seats.find((seat) => seat && seat.uid === uid);

  if (!isHost && !occupiedSeat) {
    throw new HttpsError('permission-denied', 'Join a room seat first.');
  }

  const url = LIVEKIT_URL.value();
  const apiKey = LIVEKIT_API_KEY.value();
  const apiSecret = LIVEKIT_API_SECRET.value();

  if (!url || !/^(wss?|https?):\/\//i.test(url) || !apiKey || !apiSecret) {
    throw new HttpsError('failed-precondition', 'Voice service is not configured yet.');
  }

  const name = (request.auth.token.name ||
    (isHost ? room.hostName : occupiedSeat.name) || 'User').toString().slice(0, 80);

  const token = new AccessToken(apiKey, apiSecret, {
    identity: uid,
    name,
    ttl: '10m',
  });

  token.addGrant({
    roomJoin: true,
    room: roomId,
    canPublish: true,
    canSubscribe: true,
    canPublishData: true,
  });

  return {
    url,
    token: await token.toJwt(),
    roomId,
    identity: uid,
    expiresInSeconds: 600,
  };
});
