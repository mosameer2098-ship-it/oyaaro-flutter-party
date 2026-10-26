import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/core/catalog.dart';

class RoomService {
  static final _db = FirebaseFirestore.instance;
  static final _rooms = _db.collection('rooms');
  static User get _me => FirebaseAuth.instance.currentUser!;

  static Map<String, dynamic> _emptySeat() => {
    'uid': null,
    'name': null,
    'muted': true,
  };

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

  // ---------- Mine: recently visited rooms and live presence ----------

  static CollectionReference<Map<String, dynamic>> _recentRooms(String uid) =>
      _db.collection('users').doc(uid).collection('recent_rooms');

  static Future<void> recordRoomVisit(String roomId) async {
    final room = await _rooms.doc(roomId).get();
    final data = room.data();
    if (!room.exists || data == null) return;

    final roomName = (data['name'] as String?) ?? 'Room';
    await _recentRooms(_me.uid).doc(roomId).set({
      'roomId': roomId,
      'roomName': roomName,
      'hostUid': data['hostUid'] ?? '',
      'visitedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _db.collection('users').doc(_me.uid).set({
      'currentRoomId': roomId,
      'currentRoomName': roomName,
      'currentRoomAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> recentlyVisitedRooms() =>
      _recentRooms(_me.uid)
          .orderBy('visitedAt', descending: true)
          .limit(20)
          .snapshots();

  static Future<void> setCurrentRoom(String roomId, String roomName) async {
    await _db.collection('users').doc(_me.uid).set({
      'currentRoomId': roomId,
      'currentRoomName': roomName,
      'currentRoomAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> clearCurrentRoom(String roomId) async {
    final ref = _db.collection('users').doc(_me.uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.data()?['currentRoomId'] == roomId) {
        tx.update(ref, {
          'currentRoomId': FieldValue.delete(),
          'currentRoomName': FieldValue.delete(),
          'currentRoomAt': FieldValue.delete(),
        });
      }
    });
  }

  // Safely upgrade an existing room to the 14-position layout.
  // Only the room host performs this migration; existing occupied seats
  // are preserved and only missing empty seats are appended.
  static Future<void> ensureRoomCapacity(String roomId) async {
    final ref = _rooms.doc(roomId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null || data['hostUid'] != _me.uid) return;

      final seats = ((data['seats'] as List?) ?? const [])
          .map((seat) => Map<String, dynamic>.from(seat as Map))
          .toList();

      final count = (data['seatCount'] as num?)?.toInt() ?? seats.length;
      if (count == Catalog.maxSeats && seats.length >= Catalog.maxSeats) {
        return;
      }

      while (seats.length < Catalog.maxSeats) {
        seats.add(_emptySeat());
      }

      tx.update(ref, {'seatCount': Catalog.maxSeats, 'seats': seats});
    });
  }

  // ---------- Writes ----------
  static Future<String> createRoom(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw const AppException('Room ka naam khali nahi ho sakta');
    }

    final user = _me;
    final claimRef = _db.collection('room_claims').doc(user.uid);
    final hostName = user.displayName ?? 'Host';

    // Read existing rooms before the transaction; verify the selected room
    // again inside the transaction before permanently claiming it.
    final existingRooms = await _rooms
        .where('hostUid', isEqualTo: user.uid)
        .limit(1)
        .get();

    final existingRoomRef = existingRooms.docs.isEmpty
        ? null
        : existingRooms.docs.first.reference;
    final newRoomRef = _rooms.doc();

    return _db.runTransaction<String>((tx) async {
      final claim = await tx.get(claimRef);

      if (claim.exists) {
        final data = claim.data();
        final claimedRoomId = data?['roomId']?.toString();
        if (data?['ownerUid'] != user.uid ||
            claimedRoomId == null ||
            claimedRoomId.isEmpty) {
          throw const AppException(
            'Aapki permanent room entry mein problem hai. Support se sampark karein.',
          );
        }

        final claimedRoom = await tx.get(_rooms.doc(claimedRoomId));
        if (!claimedRoom.exists || claimedRoom.data()?['hostUid'] != user.uid) {
          throw const AppException(
            'Aapki permanent room verify nahi ho saki. Support se sampark karein.',
          );
        }
        return claimedRoomId;
      }

      String roomId;
      if (existingRoomRef != null) {
        final existingRoom = await tx.get(existingRoomRef);
        if (!existingRoom.exists ||
            existingRoom.data()?['hostUid'] != user.uid) {
          throw const AppException(
            'Existing room verify nahi ho saki. Dobara try karein.',
          );
        }
        roomId = existingRoom.id;
      } else {
        roomId = newRoomRef.id;
      }

      // Claim and new room are committed atomically.
      tx.set(claimRef, {
        'ownerUid': user.uid,
        'roomId': roomId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (existingRoomRef == null) {
        tx.set(newRoomRef, {
          'name': cleanName,
          'nameLower': cleanName.toLowerCase(),
          'hostUid': user.uid,
          'hostName': hostName,
          'seatCount': Catalog.maxSeats,
          'seats': List.generate(
            Catalog.maxSeats,
            (i) => i == 0
                ? {'uid': user.uid, 'name': hostName, 'muted': true}
                : _emptySeat(),
          ),
        });
      }

      return roomId;
    });
  }

  static Future<void> sendMessage(
    String roomId,
    String name,
    String text, {
    String type = 'text',
  }) async {
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
      List<Map<String, dynamic>> seats,
      int count,
      String hostUid,
    )
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
      final updates = change(
        seats,
        data['seatCount'] as int,
        data['hostUid'] as String,
      );
      tx.update(ref, updates);
    });
  }

  static void _requireHost(String hostUid) {
    if (hostUid != _me.uid) {
      throw const AppException('Ye kaam sirf host kar sakta hai');
    }
  }

  // Seat indexes: 0 = Owner, 1 = Super Mic, 2..13 = 12 regular seats.
  static Future<void> takeSeat(String roomId, int index) =>
      _tx(roomId, (seats, seatCount, _) {
        if (index < 1 || index >= seatCount || index >= seats.length) {
          throw const AppException('Ye seat available nahi hai');
        }
        if (seats.any((seat) => seat['uid'] == _me.uid)) {
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

  static Future<void> leaveSeat(String roomId) => _tx(roomId, (seats, _, __) {
    for (var i = 1; i < seats.length; i++) {
      if (seats[i]['uid'] == _me.uid) {
        seats[i] = _emptySeat();
      }
    }
    return {'seats': seats};
  });

  static Future<void> setMuted(String roomId, bool muted) =>
      _tx(roomId, (seats, _, __) {
        for (var i = 1; i < seats.length; i++) {
          if (seats[i]['uid'] == _me.uid) {
            seats[i] = {...seats[i], 'muted': muted};
          }
        }
        return {'seats': seats};
      });

  static Future<void> setSeatMuted(String roomId, int index, bool muted) =>
      _tx(roomId, (seats, seatCount, hostUid) {
        _requireHost(hostUid);
        if (index <= 0 ||
            index >= seatCount ||
            index >= seats.length ||
            seats[index]['uid'] == null) {
          throw const AppException('Is seat par koi nahi hai');
        }
        seats[index] = {...seats[index], 'muted': muted};
        return {'seats': seats};
      });

  static Future<void> kickFromSeat(String roomId, int index) =>
      _tx(roomId, (seats, seatCount, hostUid) {
        _requireHost(hostUid);
        if (index <= 0 || index >= seatCount || index >= seats.length) {
          throw const AppException('Invalid seat');
        }
        seats[index] = _emptySeat();
        return {'seats': seats};
      });

  static Future<void> setSeatCount(String roomId, int newCount) =>
      _tx(roomId, (seats, _, hostUid) {
        _requireHost(hostUid);
        if (newCount != Catalog.maxSeats) {
          throw const AppException('Room mein 14 positions fixed hain');
        }
        while (seats.length < Catalog.maxSeats) {
          seats.add(_emptySeat());
        }
        return {'seatCount': Catalog.maxSeats, 'seats': seats};
      });
}
