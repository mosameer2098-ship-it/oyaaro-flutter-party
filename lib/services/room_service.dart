import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/core/catalog.dart';

class RoomService {
  static final _db = FirebaseFirestore.instance;
  static final _rooms = _db.collection('rooms');
  static User get _me => FirebaseAuth.instance.currentUser!;

  static Map<String, dynamic> _emptySeat() =>
      {'uid': null, 'name': null, 'muted': true};

  // ---------- Reads (streams) ----------
  static Stream<QuerySnapshot<Map<String, dynamic>>> roomList() =>
      _rooms.snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> roomStream(String id) =>
      _rooms.doc(id).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> myRooms() =>
      _rooms.where('hostUid', isEqualTo: _me.uid).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> messages(String roomId) =>
      _rooms
          .doc(roomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots();

  // Room mein kitne seats par log baithe hain
  static int occupiedCount(Map<String, dynamic> data) {
    final seats = (data['seats'] as List?) ?? [];
    return seats.where((s) => (s as Map)['uid'] != null).length;
  }

  // ---------- Writes ----------
  static Future<String> createRoom(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const AppException('Room ka naam khali nahi ho sakta');
    }
    final doc = await _rooms.add({
      'name': cleanName,
      'nameLower': cleanName.toLowerCase(),
      'hostUid': _me.uid,
      'hostName': _me.displayName ?? 'Host',
      'seatCount': Catalog.maxSeats,
      'seats': List.generate(
        Catalog.maxSeats,
        (i) => i == 0
            ? {'uid': _me.uid, 'name': _me.displayName ?? 'Host', 'muted': true}
            : _emptySeat(),
      ),
    });
    return doc.id;
  }

  static Future<void> sendMessage(String roomId, String name, String text,
      {String type = 'text'}) async {
    await _rooms.doc(roomId).collection('messages').add({
      'uid': _me.uid,
      'name': name,
      'type': type,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Seats ko transaction mein safely badalta hai
  static Future<void> _tx(
    String roomId,
    Map<String, dynamic> Function(
            List<Map<String, dynamic>> seats, int count, String hostUid)
        change,
  ) {
    final ref = _rooms.doc(roomId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) throw const AppException('Room nahi mila');
      final seats = (data['seats'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final updates =
          change(seats, data['seatCount'] as int, data['hostUid'] as String);
      tx.update(ref, updates);
    });
  }

  static void _requireHost(String hostUid) {
    if (hostUid != _me.uid) {
      throw const AppException('Ye kaam sirf host kar sakta hai');
    }
  }

  static Future<void> takeSeat(String roomId, int index) =>
      _tx(roomId, (seats, count, _) {
        if (index <= 0 || index >= count) {
          throw const AppException('Ye seat available nahi hai');
        }
        if (seats.any((s) => s['uid'] == _me.uid)) {
          throw const AppException('Aap pehle se seat par ho');
        }
        if (seats[index]['uid'] != null) {
          throw const AppException('Seat already bhari hai');
        }
        seats[index] = {
          'uid': _me.uid,
          'name': _me.displayName ?? 'User',
          'muted': true,
        };
        return {'seats': seats};
      });

  static Future<void> leaveSeat(String roomId) =>
      _tx(roomId, (seats, _, __) {
        for (var i = 1; i < seats.length; i++) {
          if (seats[i]['uid'] == _me.uid) seats[i] = _emptySeat();
        }
        return {'seats': seats};
      });

  static Future<void> setMuted(String roomId, bool muted) =>
      _tx(roomId, (seats, _, __) {
        for (var i = 0; i < seats.length; i++) {
          if (seats[i]['uid'] == _me.uid) {
            seats[i] = {...seats[i], 'muted': muted};
          }
        }
        return {'seats': seats};
      });

  static Future<void> setSeatMuted(String roomId, int index, bool muted) =>
      _tx(roomId, (seats, count, hostUid) {
        _requireHost(hostUid);
        if (index <= 0 || index >= count || seats[index]['uid'] == null) {
          throw const AppException('Is seat par koi nahi hai');
        }
        seats[index] = {...seats[index], 'muted': muted};
        return {'seats': seats};
      });

  static Future<void> kickFromSeat(String roomId, int index) =>
      _tx(roomId, (seats, count, hostUid) {
        _requireHost(hostUid);
        if (index <= 0 || index >= count) {
          throw const AppException('Invalid seat');
        }
        seats[index] = _emptySeat();
        return {'seats': seats};
      });

  static Future<void> setSeatCount(String roomId, int newCount) =>
      _tx(roomId, (seats, _, hostUid) {
        _requireHost(hostUid);
        for (var i = newCount; i < seats.length; i++) {
          seats[i] = _emptySeat();
        }
        return {'seatCount': newCount, 'seats': seats};
      });
}
