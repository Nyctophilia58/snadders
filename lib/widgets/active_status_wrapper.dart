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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserIdAndSetActive();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setActiveStatus(false);
    super.dispose();
  }

  Future<void> _loadUserIdAndSetActive() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId != null) {
      await _setActiveStatus(true);
    }
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
      await _firestore.collection('googleUsers').doc(_userId).update({
        'isActive': isActive,
        'lastActive': FieldValue.serverTimestamp(),
      });
      print('User $_userId active status: $isActive');
    } catch (e) {
      print('Error updating active status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
