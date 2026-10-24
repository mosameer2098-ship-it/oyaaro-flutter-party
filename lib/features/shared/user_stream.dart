import 'package:cloud_firestore/cloud_firestore.dart';

/// users/{uid} ka live data. Missing field par default values features khud dekhte hain.
class UserStream {
  UserStream({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<Map<String, dynamic>> watch(String uid) =>
      _db.collection('users').doc(uid).snapshots().map((d) => d.data() ?? <String, dynamic>{});
}
