import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';

// Kisi bhi error ko user-friendly message mein badalta hai (ek hi jagah)
String friendlyMessage(Object e) {
  if (e is AppException) return e.message;
  if (e is FirebaseFunctionsException) return e.message ?? 'Server par problem aayi';
  if (e is FirebaseAuthException) return e.message ?? 'Login mein problem aayi';
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        return 'Aapko ye karne ki permission nahi hai.';
      case 'unavailable':
        return 'Internet check karein aur dobara koshish karein.';
      default:
        return 'Server se problem aayi. Dobara koshish karein.';
    }
  }
  return 'Kuch galat ho gaya. Dobara koshish karein.';
}
