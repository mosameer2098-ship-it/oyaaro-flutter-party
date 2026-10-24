/// Ek real voice room. liveCount = seats par baithe log (real seats data se).
class DiscoverRoom {
  final String id;
  final String name;
  final String hostUid;
  final String hostName;
  final int seatCount;
  final int liveCount;

  const DiscoverRoom({
    required this.id,
    required this.name,
    required this.hostUid,
    required this.hostName,
    required this.seatCount,
    required this.liveCount,
  });

  bool get isLive => liveCount > 0;
}
