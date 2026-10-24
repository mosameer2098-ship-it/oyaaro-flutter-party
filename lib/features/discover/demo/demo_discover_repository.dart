import '../models/discover_room.dart';
import '../models/discover_user.dart';
import '../models/friend_request.dart';
import '../services/discover_repository.dart';

/// DEMO ONLY. Preview aur tests ke liye. Ye data real nahi hai.
/// Har naam [DEMO] se shuru hota hai. Production mein kabhi use na karein.
class DemoDiscoverRepository implements DiscoverRepository {
  DemoDiscoverRepository({this.failSearch = false});

  final bool failSearch;
  static const _me = 'demo_me';

  final _people = <DiscoverUser>[
    const DiscoverUser(uid: 'demo_1', name: '[DEMO] Aarav', shortId: '10000001', level: 12, vip: 2),
    const DiscoverUser(uid: 'demo_2', name: '[DEMO] Meera', shortId: '10000002', level: 5),
    const DiscoverUser(uid: 'demo_3', name: '[DEMO] Kabir', shortId: '10000003', vip: 4),
  ];

  @override
  String get currentUid => _me;

  @override
  Future<List<DiscoverUser>> searchUsers(String query) async {
    if (failSearch) throw const DiscoverException('[DEMO] Network error');
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _people
        .where((u) => u.name.toLowerCase().contains(q) || u.shortId == q)
        .toList();
  }

  @override
  Future<List<DiscoverUser>> onlineUsers({int limit = 30}) async => [];

  @override
  Future<DiscoverUser?> userProfile(String uid) async {
    for (final u in _people) {
      if (u.uid == uid) return u;
    }
    return null;
  }

  @override
  Future<FriendshipStatus> friendshipStatus(String uid) async => FriendshipStatus.none;

  @override
  Future<void> sendFriendRequest(String toUid) async {}

  @override
  Future<void> acceptFriendRequest(String fromUid) async {}

  @override
  Future<void> rejectFriendRequest(String fromUid) async {}

  @override
  Stream<List<FriendRequest>> incomingRequests() => Stream.value(const []);

  @override
  Stream<List<DiscoverUser>> friends() => Stream.value(const []);

  @override
  Future<bool> isFollowing(String uid) async => false;

  @override
  Future<void> follow(String uid) async {}

  @override
  Future<void> unfollow(String uid) async {}

  @override
  Future<List<DiscoverRoom>> searchRooms(String query) async => [];

  @override
  Future<void> inviteToRoom({required String toUid, required DiscoverRoom room}) async {}
}
