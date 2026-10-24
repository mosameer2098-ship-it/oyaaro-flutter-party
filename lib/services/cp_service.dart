import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';

// CP ek DM conversation par lagta hai. Status: none -> pending -> active
class CpService {
  static final _convs = FirebaseFirestore.instance.collection('conversations');
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> request(String convId) {
    final ref = _convs.doc(convId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final cp = Map<String, dynamic>.from(d['cp'] ?? {});
      final status = cp['status'] ?? 'none';
      if (status == 'active') throw const AppException('CP already lagi hai');
      if (status == 'pending') throw const AppException('Request pending hai');
      tx.update(ref, {'cp': {'status': 'pending', 'by': _uid}});
    });
  }

  static Future<void> accept(String convId) {
    final ref = _convs.doc(convId);
    return FirebaseFirestore.instance.runTransaction((tx) async {
      final d = (await tx.get(ref)).data() ?? {};
      final cp = Map<String, dynamic>.from(d['cp'] ?? {});
      if (cp['status'] != 'pending') throw const AppException('Koi pending request nahi hai');
      if (cp['by'] == _uid) throw const AppException('Request aapne bheji hai, doosra user accept karega');
      tx.update(ref, {'cp': {'status': 'active', 'by': cp['by']}});
    });
  }
}
