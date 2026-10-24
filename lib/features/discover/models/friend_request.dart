enum RequestStatus { pending, accepted, rejected }

/// Dost bhejne ki request. Document id = "${fromUid}_$toUid".
class FriendRequest {
  final String id;
  final String fromUid;
  final String toUid;
  final String fromName;
  final RequestStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.fromName,
    required this.status,
    required this.createdAt,
  });
}

/// Mere aur kisi aur user ke beech ka current rishta.
enum FriendshipStatus { none, outgoingPending, incomingPending, friends }
