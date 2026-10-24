import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/discover_room.dart';
import '../models/discover_user.dart';
import '../models/friend_request.dart';
import '../models/load_state.dart';
import '../services/discover_repository.dart';

/// Discover page ka state. Har section ki apni loading / error / data state hai.
/// Action methods error message (String?) return karte hain: null = success.
class DiscoverController extends ChangeNotifier {
  DiscoverController(this.repository);

  final DiscoverRepository repository;

  LoadState<List<DiscoverUser>> people = const LoadIdle();
  LoadState<List<DiscoverUser>> online = const LoadIdle();
  LoadState<List<DiscoverRoom>> rooms = const LoadIdle();
  LoadState<List<FriendRequest>> requests = const LoadIdle();
  LoadState<List<DiscoverUser>> friends = const LoadIdle();

  StreamSubscription<List<FriendRequest>>? _requestSub;
  StreamSubscription<List<DiscoverUser>>? _friendSub;
  bool _disposed = false;

  void _emit(void Function() change) {
    if (_disposed) return;
    change();
    notifyListeners();
  }

  // ---------- searches ----------

  Future<void> searchPeople(String query) async {
    if (query.trim().isEmpty) {
      _emit(() => people = const LoadIdle());
      return;
    }
    _emit(() => people = const LoadLoading());
    try {
      final result = await repository.searchUsers(query);
      _emit(() => people = LoadData(result));
    } on DiscoverException catch (e) {
      _emit(() => people = LoadError(e.message));
    }
  }

  Future<void> loadOnline() async {
    _emit(() => online = const LoadLoading());
    try {
      final result = await repository.onlineUsers();
      _emit(() => online = LoadData(result));
    } on DiscoverException catch (e) {
      _emit(() => online = LoadError(e.message));
    }
  }

  Future<void> searchRooms(String query) async {
    if (query.trim().isEmpty) {
      _emit(() => rooms = const LoadIdle());
      return;
    }
    _emit(() => rooms = const LoadLoading());
    try {
      final result = await repository.searchRooms(query);
      _emit(() => rooms = LoadData(result));
    } on DiscoverException catch (e) {
      _emit(() => rooms = LoadError(e.message));
    }
  }

  // ---------- live streams ----------

  void watchRequests() {
    _requestSub?.cancel();
    _emit(() => requests = const LoadLoading());
    _requestSub = repository.incomingRequests().listen(
      (list) => _emit(() => requests = LoadData(list)),
      onError: (Object e) => _emit(() => requests = LoadError(_msg(e))),
    );
  }

  void watchFriends() {
    _friendSub?.cancel();
    _emit(() => friends = const LoadLoading());
    _friendSub = repository.friends().listen(
      (list) => _emit(() => friends = LoadData(list)),
      onError: (Object e) => _emit(() => friends = LoadError(_msg(e))),
    );
  }

  /// Retry / refresh ke liye: requests aur friends dono dobara subscribe.
  void refreshLive() {
    watchRequests();
    watchFriends();
  }

  // ---------- actions (null = success, warna error message) ----------

  Future<String?> sendRequest(String uid) => _act(() => repository.sendFriendRequest(uid));
  Future<String?> acceptRequest(String uid) => _act(() => repository.acceptFriendRequest(uid));
  Future<String?> rejectRequest(String uid) => _act(() => repository.rejectFriendRequest(uid));
  Future<String?> follow(String uid) => _act(() => repository.follow(uid));
  Future<String?> unfollow(String uid) => _act(() => repository.unfollow(uid));
  Future<String?> invite(String uid, DiscoverRoom room) =>
      _act(() => repository.inviteToRoom(toUid: uid, room: room));

  Future<String?> _act(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on DiscoverException catch (e) {
      return e.message;
    } catch (_) {
      return 'Kuch galat ho gaya. Dobara koshish karein';
    }
  }

  String _msg(Object e) => e is DiscoverException ? e.message : 'Load nahi ho saka';

  @override
  void dispose() {
    _disposed = true;
    _requestSub?.cancel();
    _friendSub?.cancel();
    super.dispose();
  }
}
