import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveStatusWrapper extends StatefulWidget {
  final Widget child;
  const ActiveStatusWrapper({super.key, required this.child});

  static bool ignoreActiveStatus = false;
  static _ActiveStatusWrapperState? _instance;

  static void updateUser({
    required String userId,
    required bool isGuest,
  }) {
    _instance?._onUserChanged(userId: userId, isGuest: isGuest);
  }

  @override
  _ActiveStatusWrapperState createState() => _ActiveStatusWrapperState();
}

class _ActiveStatusWrapperState extends State<ActiveStatusWrapper>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  bool _isGuest = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    ActiveStatusWrapper._instance = this;
    WidgetsBinding.instance.addObserver(this);
    _initSharedPrefs();
  }

  Future<void> _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _userId = _prefs?.getString('userId');
    _isGuest = _prefs?.getBool('isGuest') ?? false;

    // Set active immediately if logged in
    if (_userId != null && !_isGuest) {
      _setActiveStatus(true);
    }
  }

  /// Called when login occurs & SharedPrefs updated
  void _onUserChanged({
    required String userId,
    required bool isGuest,
  }) {
    _userId = userId;
    _isGuest = isGuest;

    if (!isGuest) {
      _setActiveStatus(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_userId != null && !_isGuest) {
      _setActiveStatus(false);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isDeleted = _prefs?.getBool('accountDeleted') ?? false;
    if (_userId == null || _isGuest) return;
    if (state == AppLifecycleState.resumed) {
      if(isDeleted) return;
      _setActiveStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!isDeleted) {
        _setActiveStatus(false);
      }
    }
  }

  Future<void> _setActiveStatus(bool isActive) async {
    if (_userId == null || _isGuest) return;
    if (ActiveStatusWrapper.ignoreActiveStatus) return;
    try {
      await _firestore.collection('googleUsers').doc(_userId).set({
        'isActive': isActive,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating active status: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
