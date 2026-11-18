import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_mark.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isCheckingAccess = true;
  String? _adminName;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyAdminAccess();
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppConstants.adminLoginRoute);
    });
  }

  Future<bool> _trySignOut(SupabaseClient client) async {
    try {
      await client.auth.signOut();
      return true;
    } on AuthException {
      return false;
    } on Exception {
      return false;
    }
  }

  Future<void> _verifyAdminAccess() async {
    final client = SupabaseService.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      _redirectToLogin();
      return;
    }

    try {
      final profile = await client
          .from('admin_profiles')
          .select('id, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;
      if (profile == null) {
        final signedOut = await _trySignOut(client);
        if (!mounted) return;
        if (signedOut) {
          context.go(AppConstants.adminLoginRoute);
        } else {
          setState(() {
            _isCheckingAccess = false;
            _errorMessage = 'Unauthorized Admin Access. Close and reopen the app before trying again.';
          });
        }
        return;
      }

      final fullName = profile['full_name'];
      setState(() {
        _adminName = fullName is String && fullName.trim().isNotEmpty
            ? fullName.trim()
            : 'Admin';
        _isCheckingAccess = false;
        _errorMessage = null;
      });
    } on PostgrestException {
      await _handleVerificationFailure(client);
    } on Exception {
      await _handleVerificationFailure(client);
    }
  }

  Future<void> _handleVerificationFailure(SupabaseClient client) async {
    final signedOut = await _trySignOut(client);
    if (!mounted) return;
    setState(() {
      _isCheckingAccess = false;
      _errorMessage = signedOut
          ? 'Admin access could not be verified. Check your connection and sign in again.'
          : 'Admin access could not be verified. Close and reopen the app before trying again.';
    });
  }

  Future<void> _signOut() async {
    final client = SupabaseService.client;
    if (client == null) {
      if (mounted) context.go(AppConstants.moduleSelectionRoute);
      return;
    }

    try {
      await client.auth.signOut();
      if (mounted) context.go(AppConstants.moduleSelectionRoute);
    } on AuthException {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to sign out. Please try again.');
    } on Exception {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Unable to sign out. Check your connection.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin access')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.teal,
                    size: 44,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _isCheckingAccess = true;
                        _errorMessage = null;
                      });
                      _verifyAdminAccess();
                    },
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppConstants.adminLoginRoute),
                    child: const Text('Back to Admin sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 28),
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.teal,
                      size: 42,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Welcome, ${_adminName ?? 'Admin'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are signed in with authorized administrator access.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
