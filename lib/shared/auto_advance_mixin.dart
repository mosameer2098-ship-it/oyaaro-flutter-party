import 'dart:async';

import 'package:flutter/material.dart';

/// Shared auto-advance behaviour for carousels.
///
/// The timer runs only while the widget is visible in its tab (TickerMode),
/// the app is in the foreground, and the user is not dragging. It is cancelled
/// on dispose. Carousel states must call [onUserDragStart] and [onUserDragEnd]
/// from their scroll notifications, and mix in WidgetsBindingObserver.
mixin AutoAdvanceMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _autoTimer;
  bool _appInForeground = true;
  bool _tickerEnabled = true;
  bool _userDragging = false;

  /// Time between automatic advances.
  Duration get autoAdvanceInterval;

  /// False when there is nothing to advance to.
  bool get canAutoAdvance;

  /// Moves to the next page. Called only by the timer.
  void advanceOnce();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerEnabled = TickerMode.of(context);
    _syncAutoAdvance();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appInForeground = state == AppLifecycleState.resumed;
    _syncAutoAdvance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    _autoTimer = null;
    super.dispose();
  }

  void onUserDragStart() {
    _userDragging = true;
    _syncAutoAdvance();
  }

  /// Restarts the interval so the next automatic move waits a full period
  /// after the user lets go.
  void onUserDragEnd() {
    _userDragging = false;
    _restartAutoAdvance();
  }

  void _syncAutoAdvance() {
    final shouldRun =
        _appInForeground && _tickerEnabled && !_userDragging && canAutoAdvance;
    if (shouldRun) {
      _autoTimer ??= Timer.periodic(autoAdvanceInterval, (_) => advanceOnce());
    } else {
      _autoTimer?.cancel();
      _autoTimer = null;
    }
  }

  void _restartAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = null;
    _syncAutoAdvance();
  }
}
