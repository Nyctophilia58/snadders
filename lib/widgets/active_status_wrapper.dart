import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActiveStatusWrapper extends StatefulWidget {
  final Widget child;
  const ActiveStatusWrapper({super.key, required this.child});

  @override
  _ActiveStatusWrapperState createState() => _ActiveStatusWrapperState();
}

class _ActiveStatusWrapperState extends State<ActiveStatusWrapper>
    with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  SharedPreferences? _prefs;
  late ValueNotifier<String?> _userIdNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSharedPrefs();
  }

  Future<void> _initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs?.getString('userId');

    // ValueNotifier to detect changes in userId after sign-in
    _userIdNotifier = ValueNotifier<String?>(_userId);
    _userIdNotifier.addListener(() {
      final newUserId = _userIdNotifier.value;
      if (newUserId != null && newUserId != _userId) {
        _userId = newUserId;
        _setActiveStatus(true);
      }
    });

    _pollUserId();

    if (_userId != null) {
      await _setActiveStatus(true);
    }
  }

  void _pollUserId() async {
    while (mounted && _userId == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      final newUserId = _prefs?.getString('userId');
      if (newUserId != null) {
        _userIdNotifier.value = newUserId;
        break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setActiveStatus(false);
    _userIdNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_userId == null) return;
    if (state == AppLifecycleState.resumed) {
      _setActiveStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _setActiveStatus(false);
    }
  }

  Future<void> _setActiveStatus(bool isActive) async {
    if (_userId == null) return;
    try {
      await _firestore.collection('googleUsers').doc(_userId).set({
        'isActive': isActive,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // print('User $_userId active status: $isActive');
    } catch (e) {
      debugPrint('Error updating active status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
