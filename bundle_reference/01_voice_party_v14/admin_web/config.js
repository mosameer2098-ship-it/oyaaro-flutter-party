// Firebase Console > Project settings > Your apps > Web app se ye values copy karein.
// Ye public values hain (secret nahi). Security rules aur admin role se data protect hota hai.
export const firebaseConfig = {
  apiKey: 'PASTE_API_KEY',
  authDomain: 'PASTE_PROJECT.firebaseapp.com',
  projectId: 'PASTE_PROJECT_ID',
  storageBucket: 'PASTE_PROJECT.appspot.com',
  messagingSenderId: 'PASTE_SENDER_ID',
  appId: 'PASTE_APP_ID',
};
// Functions ka region (agar aapne asia-south1 par deploy kiya ho to yahan badlein)
export const REGION = 'us-central1';
