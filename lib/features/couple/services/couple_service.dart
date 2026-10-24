import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/callable_helper.dart';
import '../models/couple_bond.dart';

class CoupleService {
  CoupleService({CallableHelper? callable, FirebaseFirestore? firestore})
      : _call = callable ?? CallableHelper(),
        _db = firestore ?? FirebaseFirestore.instance;

  final CallableHelper _call;
  final FirebaseFirestore _db;

  Stream<CoupleBond> watch(String convId) => _db
      .collection('conversations')
      .doc(convId)
      .snapshots()
      .map((d) => CoupleBond.fromMap(convId, d.data() ?? const {}));

  Future<void> request(String convId) async {
    await _call.call('cpRequest', {'convId': convId});
  }

  Future<void> accept(String convId) async {
    await _call.call('cpAccept', {'convId': convId});
  }

  Future<void> setCoupleTheme(String convId, String themeId) async {
    await _call.call('setCoupleTheme', {'convId': convId, 'themeId': themeId});
  }
}
