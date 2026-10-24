import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/services/user_service.dart';

class ChatService {
  static final _db = FirebaseFirestore.instance;
  static final _convs = _db.collection('conversations');
  static User get _me => FirebaseAuth.instance.currentUser!;

  static String convId(String a, String b) =>
      a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';

  static Stream<QuerySnapshot<Map<String, dynamic>>> myConversations() =>
      _convs.where('participants', arrayContains: _me.uid).snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> convStream(String id) =>
      _convs.doc(id).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> messages(String id) =>
      _convs
          .doc(id)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots();

  // Returns (convId, otherName)
  static Future<(String, String)> openConversation(String otherUid) async {
    if (otherUid == _me.uid) {
      throw const AppException('Apne aap se chat nahi ho sakti');
    }
    final userSnap = await _db.collection('users').doc(otherUid).get();
    if (!userSnap.exists) throw const AppException('User nahi mila');
    final otherName = (userSnap.data()?['name'] ?? 'User').toString();

    final id = convId(_me.uid, otherUid);
    final ref = _convs.doc(id);
    final snap = await ref.get();
    if (!snap.exists) {
      final myName = await UserService.myName();
      await ref.set({
        'participants': [_me.uid, otherUid],
        'names': {_me.uid: myName, otherUid: otherName},
        'lastText': '',
        'cpExp': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return (id, otherName);
  }

  // Gift message (CP / friend gift). Medal aur bond exp ke saath
  static Future<void> sendGift(String id, String giftName) async {
    final ref = _convs.doc(id);
    await ref.collection('messages').add({
      'uid': _me.uid,
      'text': giftName,
      'type': 'gift',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ref.update({
      'lastText': 'Gift: $giftName',
      'cpExp': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Har message = 1 bond exp (CP level ke liye)
  static Future<void> send(String id, String text) async {
    final ref = _convs.doc(id);
    await ref.collection('messages').add({
      'uid': _me.uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ref.update({
      'lastText': text,
      'cpExp': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
