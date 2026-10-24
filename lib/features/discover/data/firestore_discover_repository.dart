import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/discover_room.dart';
import '../models/discover_user.dart';
import '../models/friend_request.dart';
import '../services/discover_repository.dart';

/// Real Firestore implementation. Collections ka layout README mein hai.
class FirestoreDiscoverRepository implements DiscoverRepository {
  FirestoreDiscoverRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const _limit = 20;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _requests => _db.collection('friend_requests');
  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  @override
  String get currentUid {
    final user = _auth.currentUser;
    if (user == null) throw const DiscoverException('Login karein');
    return user.uid;
  }

  // ---------- users ----------

  @override
  Future<List<DiscoverUser>> searchUsers(String query) => _guard(() async {
        final q = query.trim();
        if (q.isEmpty) return <DiscoverUser>[];
        final me = currentUid;
        final results = <String, DiscoverUser>{};

        // User ID (sirf digits) par exact match
        if (RegExp(r'^\d{4,}$').hasMatch(q)) {
          final snap = await _users.where('shortId', isEqualTo: q).limit(_limit).get();
          for (final d in snap.docs) {
            results[d.id] = _userFrom(d.id, d.data());
          }
        }
        // Username prefix (nameLower field se)
        final lower = q.toLowerCase();
        final snap = await _users
            .where('nameLower', isGreaterThanOrEqualTo: lower)
            .where('nameLower', isLessThan: '$lower\uf8ff')
            .limit(_limit)
            .get();
        for (final d in snap.docs) {
          results[d.id] = _userFrom(d.id, d.data());
        }
        results.remove(me);
        return results.values.toList();
      });

  @override
  Future<List<DiscoverUser>> onlineUsers({int limit = 30}) => _guard(() async {
        final me = currentUid;
        final cutoff = DateTime.now().subtract(const Duration(minutes: 2));
        final snap = await _users
            .where('lastSeen', isGreaterThan: Timestamp.fromDate(cutoff))
            .orderBy('lastSeen', descending: true)
            .limit(limit)
            .get();
        return snap.docs
            .where((d) => d.id != me)
            .map((d) => _userFrom(d.id, d.data()))
            .toList();
      });

  @override
  Future<DiscoverUser?> userProfile(String uid) => _guard(() async {
        final doc = await _users.doc(uid).get();
        if (!doc.exists) return null;
        return _userFrom(doc.id, doc.data()!);
      });

  // ---------- friends & requests ----------

  @override
  Future<FriendshipStatus> friendshipStatus(String uid) => _guard(() async {
        final me = currentUid;
        final friendDoc = await _users.doc(me).collection('friends').doc(uid).get();
        if (friendDoc.exists) return FriendshipStatus.friends;
        final out = await _requests.doc('${me}_$uid').get();
        if (out.exists && out.data()?['status'] == 'pending') {
          return FriendshipStatus.outgoingPending;
        }
        final inc = await _requests.doc('${uid}_$me').get();
        if (inc.exists && inc.data()?['status'] == 'pending') {
          return FriendshipStatus.incomingPending;
        }
        return FriendshipStatus.none;
      });

  @override
  Future<void> sendFriendRequest(String toUid) => _guard(() async {
        final me = currentUid;
        if (toUid == me) throw const DiscoverException('Khud ko request nahi bhej sakte');
        final status = await friendshipStatus(toUid);
        if (status == FriendshipStatus.friends) {
          throw const DiscoverException('Ye user pehle se aapka dost hai');
        }
        if (status == FriendshipStatus.outgoingPending) {
          throw const DiscoverException('Request pehle se bheji ja chuki hai');
        }
        if (status == FriendshipStatus.incomingPending) {
          throw const DiscoverException('Is user ki request aapke paas pending hai. Accept karein');
        }
        final me0 = await _users.doc(me).get();
        await _requests.doc('${me}_$toUid').set({
          'fromUid': me,
          'toUid': toUid,
          'fromName': (me0.data()?['name'] as String?) ?? 'User',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

  @override
  Future<void> acceptFriendRequest(String fromUid) => _guard(() async {
        final me = currentUid;
        final reqRef = _requests.doc('${fromUid}_$me');
        await _db.runTransaction((tx) async {
          final req = await tx.get(reqRef);
          if (!req.exists || req.data()?['status'] != 'pending' || req.data()?['toUid'] != me) {
            throw const DiscoverException('Request ab valid nahi hai');
          }
          final myDoc = await tx.get(_users.doc(me));
          final otherDoc = await tx.get(_users.doc(fromUid));
          tx.update(reqRef, {'status': 'accepted'});
          tx.set(_users.doc(me).collection('friends').doc(fromUid), {
            'uid': fromUid,
            'name': (otherDoc.data()?['name'] as String?) ?? 'User',
            'since': FieldValue.serverTimestamp(),
          });
          tx.set(_users.doc(fromUid).collection('friends').doc(me), {
            'uid': me,
            'name': (myDoc.data()?['name'] as String?) ?? 'User',
            'since': FieldValue.serverTimestamp(),
          });
        });
      });

  @override
  Future<void> rejectFriendRequest(String fromUid) => _guard(() async {
        final me = currentUid;
        final reqRef = _requests.doc('${fromUid}_$me');
        final req = await reqRef.get();
        if (!req.exists || req.data()?['toUid'] != me) {
          throw const DiscoverException('Request nahi mili');
        }
        await reqRef.update({'status': 'rejected'});
      });

  @override
  Stream<List<FriendRequest>> incomingRequests() {
    try {
      final me = currentUid;
      return _requests
          .where('toUid', isEqualTo: me)
          .where('status', isEqualTo: 'pending')
          .limit(50)
          .snapshots()
          .map((snap) => snap.docs.map((d) {
                final data = d.data();
                return FriendRequest(
                  id: d.id,
                  fromUid: data['fromUid'] as String? ?? '',
                  toUid: data['toUid'] as String? ?? '',
                  fromName: data['fromName'] as String? ?? 'User',
                  status: RequestStatus.pending,
                  createdAt: _time(data['createdAt']),
                );
              }).toList());
    } on DiscoverException catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Stream<List<DiscoverUser>> friends() {
    try {
      final me = currentUid;
      return _users.doc(me).collection('friends').limit(200).snapshots().map((snap) =>
          snap.docs
              .map((d) => DiscoverUser(uid: d.data()['uid'] as String? ?? d.id, name: d.data()['name'] as String? ?? 'User'))
              .toList());
    } on DiscoverException catch (e) {
      return Stream.error(e);
    }
  }

  // ---------- follow ----------

  @override
  Future<bool> isFollowing(String uid) => _guard(() async {
        final doc = await _users.doc(currentUid).collection('following').doc(uid).get();
        return doc.exists;
      });

  @override
  Future<void> follow(String uid) => _guard(() async {
        final me = currentUid;
        if (uid == me) throw const DiscoverException('Khud ko follow nahi kar sakte');
        final batch = _db.batch();
        batch.set(_users.doc(me).collection('following').doc(uid), {'since': FieldValue.serverTimestamp()});
        batch.set(_users.doc(uid).collection('followers').doc(me), {'since': FieldValue.serverTimestamp()});
        await batch.commit();
      });

  @override
  Future<void> unfollow(String uid) => _guard(() async {
        final me = currentUid;
        final batch = _db.batch();
        batch.delete(_users.doc(me).collection('following').doc(uid));
        batch.delete(_users.doc(uid).collection('followers').doc(me));
        await batch.commit();
      });

  // ---------- rooms ----------

  @override
  Future<List<DiscoverRoom>> searchRooms(String query) => _guard(() async {
        final q = query.trim().toLowerCase();
        if (q.isEmpty) return <DiscoverRoom>[];
        final snap = await _rooms
            .where('nameLower', isGreaterThanOrEqualTo: q)
            .where('nameLower', isLessThan: '$q\uf8ff')
            .limit(_limit)
            .get();
        return snap.docs.map((d) => _roomFrom(d.id, d.data())).toList();
      });

  @override
  Future<void> inviteToRoom({required String toUid, required DiscoverRoom room}) => _guard(() async {
        final me = currentUid;
        final friend = await _users.doc(me).collection('friends').doc(toUid).get();
        if (!friend.exists) throw const DiscoverException('Sirf dost ko invite kar sakte hain');
        final me0 = await _users.doc(me).get();
        await _users.doc(toUid).collection('room_invites').doc(room.id).set({
          'roomId': room.id,
          'roomName': room.name,
          'fromUid': me,
          'fromName': (me0.data()?['name'] as String?) ?? 'User',
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

  // ---------- helpers ----------

  DiscoverUser _userFrom(String uid, Map<String, dynamic> d) => DiscoverUser(
        uid: uid,
        name: (d['name'] as String?)?.trim().isNotEmpty == true ? (d['name'] as String).trim() : 'User',
        shortId: d['shortId']?.toString(),
        photoUrl: d['photoUrl'] as String?,
        level: (d['level'] as num?)?.toInt(),
        vip: (d['vip'] as num?)?.toInt() ?? 0,
        lastSeen: (d['lastSeen'] as Timestamp?)?.toDate(),
      );

  DiscoverRoom _roomFrom(String id, Map<String, dynamic> d) {
    final seats = (d['seats'] as List?) ?? const [];
    final live = seats.where((s) => s is Map && s['uid'] != null).length;
    return DiscoverRoom(
      id: id,
      name: d['name'] as String? ?? 'Room',
      hostUid: d['hostUid'] as String? ?? '',
      hostName: d['hostName'] as String? ?? 'Host',
      seatCount: (d['seatCount'] as num?)?.toInt() ?? seats.length,
      liveCount: live,
    );
  }

  DateTime _time(dynamic v) => v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DiscoverException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DiscoverException(_firebaseMessage(e));
    } catch (_) {
      throw const DiscoverException('Kuch galat ho gaya. Dobara koshish karein');
    }
  }

  String _firebaseMessage(FirebaseException e) => switch (e.code) {
        'permission-denied' => 'Aapko ye karne ki permission nahi hai',
        'unavailable' => 'Internet check karein aur dobara koshish karein',
        'failed-precondition' => 'Search ke liye index ki zarurat hai. Admin se contact karein',
        _ => 'Server se problem aayi. Dobara koshish karein',
      };
}
