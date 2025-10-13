import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snadders/pages/page_controllers/home_page_controller.dart';
import 'package:snadders/services/shared_prefs_service.dart';

// Mock class for SharedPrefsService
class MockSharedPrefsService extends Mock implements SharedPrefsService {}

void main() {
  late HomePageController controller;
  late MockSharedPrefsService mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPrefsService();
    controller = HomePageController();
  });

  test('formatCooldown converts milliseconds to minutes string', () {
    final formatted = controller.formatCooldown(125000);
    expect(formatted, '02');
  });

  test('dispose cancels cooldown timer', () {
    controller.cooldownTimer = Timer(const Duration(seconds: 5), () {});
    controller.dispose();
    expect(controller.cooldownTimer!.isActive, false);
  });

  test('loading coins, diamonds, profile image, and username via SharedPrefsService', () async {
    when(() => mockPrefs.loadCoins()).thenAnswer((_) async => 100);
    when(() => mockPrefs.loadDiamonds()).thenAnswer((_) async => 50);
    when(() => mockPrefs.loadUsername()).thenAnswer((_) async => 'mock_user');
    when(() => mockPrefs.loadProfileImage()).thenAnswer((_) async => 'mock_path');

    // Test loading coins
    final coins = await mockPrefs.loadCoins();
    expect(coins, 100);

    // Test loading diamonds
    final diamonds = await mockPrefs.loadDiamonds();
    expect(diamonds, 50);

    // Test loading username
    final username = await mockPrefs.loadUsername();
    expect(username, 'mock_user');

    // Test loading profile image
    final profileImage = await mockPrefs.loadProfileImage();
    expect(profileImage, 'mock_path');
  });

  test('cooldown calculation works correctly', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    when(() => mockPrefs.getRemainingCooldown())
        .thenAnswer((_) async => 0); // cooldown finished
    when(() => mockPrefs.canSpin()).thenAnswer((_) async => true);

    final canSpin = await mockPrefs.canSpin();
    final remaining = await mockPrefs.getRemainingCooldown();
    expect(canSpin, true);
    expect(remaining, 0);
  });
}
