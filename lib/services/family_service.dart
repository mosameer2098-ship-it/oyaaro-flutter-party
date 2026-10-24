import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/services/user_service.dart';

class FamilyService {
  static const maxMembers = 50;
  static const createCost = 500;

  static final _db = FirebaseFirestore.instance;
  static final _fam = _db.collection('families');
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;
  static DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  static Stream<QuerySnapshot<Map<String, dynamic>>> allFamilies() =>
      _fam.orderBy('memberCount', descending: true).limit(50).snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> family(String id) =>
      _fam.doc(id).snapshots();

  static Future<void> create(String name) async {
    final myName = await UserService.myName();
    final famRef = _fam.doc();
    await _db.runTransaction((tx) async {
      final d = (await tx.get(_userRef)).data() ?? {};
      if (d['familyId'] != null) {
        throw const AppException('Aap pehle se family mein ho');
      }
      final coins = (d['coins'] ?? 0) as int;
      if (coins < createCost) {
        throw AppException('Family banane ke liye $createCost coins chahiye');
      }
      tx.update(_userRef, {'coins': coins - createCost, 'familyId': famRef.id});
      tx.set(famRef, {
        'name': name,
        'leaderUid': _uid,
        'memberCount': 1,
        'members': {_uid: myName},
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> join(String id) async {
    final myName = await UserService.myName();
    final famRef = _fam.doc(id);
    await _db.runTransaction((tx) async {
      final d = (await tx.get(_userRef)).data() ?? {};
      if (d['familyId'] != null) {
        throw const AppException('Aap pehle se family mein ho');
      }
      final f = await tx.get(famRef);
      if (!f.exists) throw const AppException('Family nahi mili');
      final count = (f.data()?['memberCount'] ?? 0) as int;
      if (count >= maxMembers) throw const AppException('Family full hai');
      tx.update(famRef, {'memberCount': count + 1, 'members.$_uid': myName});
      tx.update(_userRef, {'familyId': id});
    });
  }

  static Future<void> leave() async {
    await _db.runTransaction((tx) async {
      final d = (await tx.get(_userRef)).data() ?? {};
      final famId = d['familyId'] as String?;
      if (famId == null) throw const AppException('Aap kisi family mein nahi ho');
      final famRef = _fam.doc(famId);
      final f = (await tx.get(famRef)).data() ?? {};
      final count = (f['memberCount'] ?? 1) as int;
      if (f['leaderUid'] == _uid && count > 1) {
        throw const AppException('Leader tab tak family nahi chhod sakta jab tak members hain');
      }
      if (count <= 1) {
        tx.delete(famRef);
      } else {
        tx.update(famRef, {
          'memberCount': count - 1,
          'members.$_uid': FieldValue.delete(),
        });
      }
      tx.update(_userRef, {'familyId': null});
    });
  }
}
