import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/callable_helper.dart';
import '../models/family_info.dart';

/// Create, join, leave server par. Read (list, details) Firestore stream se.
class FamilyService {
  FamilyService({CallableHelper? callable, FirebaseFirestore? firestore})
      : _call = callable ?? CallableHelper(),
        _db = firestore ?? FirebaseFirestore.instance;

  final CallableHelper _call;
  final FirebaseFirestore _db;

  Future<void> create(String name) async {
    await _call.call('createFamily', {'name': name});
  }

  Future<void> join(String familyId) async {
    await _call.call('joinFamily', {'familyId': familyId});
  }

  Future<void> leave() async {
    await _call.call('leaveFamily');
  }

  Stream<FamilyInfo?> watchFamily(String id) => _db
      .collection('families')
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? FamilyInfo.fromMap(d.id, d.data()!) : null);

  Stream<List<FamilyInfo>> watchAll({int limit = 50}) => _db
      .collection('families')
      .orderBy('memberCount', descending: true)
      .limit(limit)
      .snapshots()
      .map((s) => s.docs.map((d) => FamilyInfo.fromMap(d.id, d.data())).toList());
}
