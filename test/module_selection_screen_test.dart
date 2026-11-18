import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:careconnect_volunteer_system/features/admin/admin_home_screen.dart';
import 'package:careconnect_volunteer_system/features/authentication/admin_login_screen.dart';
import 'package:careconnect_volunteer_system/features/authentication/login_screen.dart';
import 'package:careconnect_volunteer_system/features/module_selection/module_selection_screen.dart';
import 'package:careconnect_volunteer_system/features/welcome/welcome_screen.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/module-selection',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
        GoRoute(
          path: '/module-selection',
          builder: (context, state) => const ModuleSelectionScreen(),
        ),
        GoRoute(
          path: '/login/:role',
          redirect: (context, state) =>
              state.pathParameters['role'] == 'admin' ? '/admin-login' : null,
          builder: (context, state) =>
              LoginScreen(role: state.pathParameters['role']!),
        ),
        GoRoute(
          path: '/admin-login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin-home',
          builder: (context, state) => const AdminHomeScreen(),
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  Future<void> openPublicRegistration(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.go('/login/ngo');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
  }

  Future<void> openModuleSelection(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('public modules open their matching login screens', (
    tester,
  ) async {
    await openModuleSelection(tester);
    const roles = ['NGO', 'Volunteer', 'Beneficiary'];
    for (final role in roles) {
      expect(find.text(role), findsOneWidget);
    }
    expect(find.text('Admin'), findsNothing);

    expect(tester.takeException(), isNull);

    for (final role in roles) {
      await tester.tap(find.text(role));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('${role.toUpperCase()} PORTAL'), findsOneWidget);
      router.go('/module-selection');
      await tester.pumpAndSettle();
    }
  });

  testWidgets('five CareConnect logo taps open hidden Admin sign in', (
    tester,
  ) async {
    await openModuleSelection(tester);

    await tester.tap(find.text('CareConnect'));
    await tester.pump();
    expect(find.byType(AdminLoginScreen), findsNothing);

    for (var tap = 0; tap < 3; tap++) {
      await tester.tap(find.text('CareConnect'));
      await tester.pump();
    }
    expect(find.byType(AdminLoginScreen), findsNothing);

    await tester.tap(find.text('CareConnect'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminLoginScreen), findsOneWidget);
    expect(find.text('Register'), findsNothing);
  });

  testWidgets('logo tap count resets after two seconds of inactivity', (
    tester,
  ) async {
    await openModuleSelection(tester);

    for (var tap = 0; tap < 4; tap++) {
      await tester.tap(find.text('CareConnect'));
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('CareConnect'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminLoginScreen), findsNothing);
  });

  testWidgets('admin login route has no registration option', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.go('/login/admin');
    await tester.pumpAndSettle();

    expect(find.byType(AdminLoginScreen), findsOneWidget);
    expect(find.text('Admin sign in'), findsOneWidget);
    expect(find.text('Register'), findsNothing);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('public registration remains available on the login screen', (
    tester,
  ) async {
    await openPublicRegistration(tester);
    expect(find.text('Join our community'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Mobile number'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });

  testWidgets('registration validates all fields and matching passwords', (
    tester,
  ) async {
    await openPublicRegistration(tester);
    final fields = find.byType(TextFormField);

    const invalidValues = [
      'Alex2',
      'not-an-email',
      '12345',
      'weak',
      'different',
    ];
    for (var index = 0; index < invalidValues.length; index++) {
      await tester.ensureVisible(fields.at(index));
      await tester.enterText(fields.at(index), invalidValues[index]);
    }

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text('Use letters, spaces, hyphens, or apostrophes only'),
      findsOneWidget,
    );
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter exactly 10 digits'), findsOneWidget);
    expect(
      find.text(
        'Use 8–15 characters with at least one letter, digit, and special symbol',
      ),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('registration accepts valid profile details', (tester) async {
    await openPublicRegistration(tester);
    final fields = find.byType(TextFormField);
    const validValues = [
      "Jane O'Connor",
      'jane+care@example.org',
      '9876543210',
      'Strong@Pass1',
      'Strong@Pass1',
    ];
    for (var index = 0; index < validValues.length; index++) {
      await tester.ensureVisible(fields.at(index));
      await tester.enterText(fields.at(index), validValues[index]);
    }

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No request was sent. Supabase authentication is not integrated yet.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('registration rejects passwords longer than 15 characters', (
    tester,
  ) async {
    await openPublicRegistration(tester);
    final fields = find.byType(TextFormField);
    const values = [
      'Jane Doe',
      'jane@example.org',
      '9876543210',
      'Abcdefghi1!XYZWQ',
      'Abcdefghi1!XYZWQ',
    ];
    for (var index = 0; index < values.length; index++) {
      await tester.ensureVisible(fields.at(index));
      await tester.enterText(fields.at(index), values[index]);
    }

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Use 8–15 characters with at least one letter, digit, and special symbol',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile number input is limited to 10 digits', (tester) async {
    await openPublicRegistration(tester);
    final phoneField = find.byType(TextFormField).at(2);
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '12345678901');

    expect(
      tester.widget<TextFormField>(phoneField).controller!.text,
      '1234567890',
    );
  });

  testWidgets('Get Started opens the module selection screen', (tester) async {
    router.go('/');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Choose how you’ll\nmake a difference.'), findsOneWidget);
  });
}
