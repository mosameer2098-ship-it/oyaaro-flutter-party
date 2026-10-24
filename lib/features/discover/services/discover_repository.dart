import '../models/discover_room.dart';
import '../models/discover_user.dart';
import '../models/friend_request.dart';

/// Sab backend kaam is interface ke through. Host app Firestore impl ya apna impl de sakti hai.
abstract class DiscoverRepository {
  /// Logged-in user ka uid. Login nahi hai to [DiscoverException].
  String get currentUid;

  /// Username (prefix) ya User ID (exact) se users dhoondhna. Khud ko chhod kar.
  Future<List<DiscoverUser>> searchUsers(String query);

  /// Abhi online users (heartbeat ke hisaab se). Sirf real data.
  Future<List<DiscoverUser>> onlineUsers({int limit = 30});

  Future<DiscoverUser?> userProfile(String uid);

  Future<FriendshipStatus> friendshipStatus(String uid);
  Future<void> sendFriendRequest(String toUid);
  Future<void> acceptFriendRequest(String fromUid);
  Future<void> rejectFriendRequest(String fromUid);

  /// Mere pending incoming requests (live).
  Stream<List<FriendRequest>> incomingRequests();

  /// Meri friends list (live).
  Stream<List<DiscoverUser>> friends();

  Future<bool> isFollowing(String uid);
  Future<void> follow(String uid);
  Future<void> unfollow(String uid);

  /// Room naam (prefix) se real rooms dhoondhna.
  Future<List<DiscoverRoom>> searchRooms(String query);

  /// Sirf friend ko invite. Invite doc users/{toUid}/room_invites mein jata hai.
  Future<void> inviteToRoom({required String toUid, required DiscoverRoom room});
}

class DiscoverException implements Exception {
  final String message;
  const DiscoverException(this.message);
  @override
  String toString() => message;
}
