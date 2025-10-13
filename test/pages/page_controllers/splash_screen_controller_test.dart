import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snadders/pages/page_controllers/splash_screen_controller.dart';
import 'package:snadders/providers/sign_in_state_provider.dart';

// Mock classes
class MockWidgetRef extends Mock implements WidgetRef {}

class MockSignInNotifier extends Mock implements SignInNotifier {}

class MockSignInState extends Mock implements SignInState {}

void main() {
  late SplashScreenController controller;
  late MockWidgetRef mockRef;
  late MockSignInNotifier mockNotifier;
  late MockSignInState mockState;

  setUp(() {
    mockRef = MockWidgetRef();
    mockNotifier = MockSignInNotifier();
    mockState = MockSignInState();

    // Mock provider read for notifier
    when(() => mockRef.read(signInProvider.notifier))
        .thenReturn(mockNotifier);

    // Mock provider read for state
    when(() => mockRef.read(signInProvider)).thenReturn(mockState);

    controller = SplashScreenController(mockRef);
  });

  test('InitializeApp calls Google and guest sign-in check', () async {
    when(() => mockState.signedIn).thenReturn(false);
    when(() => mockNotifier.checkSignInGoogle()).thenAnswer((_) async {});
    when(() => mockNotifier.checkSignInGuest()).thenAnswer((_) async {});

    // Run initializeApp
    await controller.initializeApp();

    // Verify methods called
    verify(() => mockNotifier.checkSignInGoogle()).called(1);
    verify(() => mockNotifier.checkSignInGuest()).called(1);
  });

  test('InitializeApp skips guest check if already signed in', () async {
    when(() => mockState.signedIn).thenReturn(true);
    when(() => mockNotifier.checkSignInGoogle()).thenAnswer((_) async {});
    when(() => mockNotifier.checkSignInGuest()).thenAnswer((_) async {});

    await controller.initializeApp();

    verify(() => mockNotifier.checkSignInGoogle()).called(1);
    verifyNever(() => mockNotifier.checkSignInGuest());
  });

  test('IsSignedIn returns correct state', () {
    when(() => mockState.signedIn).thenReturn(true);
    expect(controller.isSignedIn(), true);

    when(() => mockState.signedIn).thenReturn(false);
    expect(controller.isSignedIn(), false);
  });

  test('GetUsername returns correct username', () {
    when(() => mockState.username).thenReturn('test_user');
    expect(controller.getUsername(), 'test_user');
  });

  test('GetIsGuest returns correct guest flag', () {
    when(() => mockState.isGuest).thenReturn(true);
    expect(controller.getIsGuest(), true);

    when(() => mockState.isGuest).thenReturn(false);
    expect(controller.getIsGuest(), false);
  });
}
