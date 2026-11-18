
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../shared/widgets/primary_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  static final _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    return value == null || value.isEmpty
        ? 'Enter your password'
        : null;
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

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
    });
  }

  // Improved authentication error handling.
  // Supabase does not reveal whether email or password is incorrect.
  String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();
    final status = error.statusCode ?? '';

    // Debug information for VS Code Terminal.
    // Never print passwords, access tokens or recovery tokens.
    debugPrint('Admin authentication error: ${error.message}');
    debugPrint('Authentication status: $status');

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'Email or password is incorrect. '
          'Please verify your Supabase Admin credentials.';
    }

    if (message.contains('email not confirmed')) {
      return 'Your email is not confirmed. '
          'Please verify your email in Supabase.';
    }

    if (status == '429' ||
        message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many login attempts. '
          'Please wait and try again later.';
    }

    if (status.startsWith('5')) {
      return 'Supabase server error. Please try again later.';
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Connection problem. Please check your internet.';
    }

    return 'Authentication failed. Please try again. '
        'Check your Supabase Auth logs for details.';
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final client = SupabaseService.client;

    if (client == null) {
      _showError(
        'Admin sign-in is not configured. Please try again later.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var sessionStarted = false;

    try {
      // Step 1: Authenticate with Supabase.
      final response = await client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;

      if (user == null) {
        _showError(
          'Unable to sign in. Please check your credentials.',
        );
        return;
      }

      sessionStarted = true;

      debugPrint('Admin authentication successful.');
      debugPrint('Checking Admin profile authorization.');

      // Step 2: Verify the existing Admin profile.
      Map<String, dynamic>? profile;

      try {
        profile = await client
            .from('admin_profiles')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
      } on PostgrestException catch (error) {
        debugPrint(
          'Admin profile database error: ${error.message}',
        );

        final signedOut = await _trySignOut(client);
        sessionStarted = false;

        _showError(
          signedOut
              ? 'Unable to verify admin access. '
                  'Check your database configuration and try again.'
              : 'Unable to verify admin access. '
                  'Close and reopen the app before trying again.',
        );

        return;
      } on Exception catch (error) {
        debugPrint('Admin profile verification error: $error');

        final signedOut = await _trySignOut(client);
        sessionStarted = false;

        _showError(
          signedOut
              ? 'Unable to verify admin access. '
                  'Check your connection and try again.'
              : 'Unable to verify admin access. '
                  'Close and reopen the app before trying again.',
        );

        return;
      }

      // Step 3: Reject users without an Admin profile.
      if (profile == null) {
        debugPrint('Unauthorized user attempted Admin login.');

        final signedOut = await _trySignOut(client);
        sessionStarted = false;

        _showError(
          signedOut
              ? 'Unauthorized Admin Access.'
              : 'Unauthorized Admin Access. '
                  'Close and reopen the app before trying again.',
        );

        return;
      }

      // Step 4: Authorized Admin.
      debugPrint('Admin profile verified successfully.');
      debugPrint('Opening Admin Dashboard.');

      sessionStarted = false;

      if (mounted) {
        context.go(AppConstants.adminHomeRoute);
      }
    } on AuthException catch (error) {
      if (sessionStarted) {
        await _trySignOut(client);
      }

      _showError(_getAuthErrorMessage(error));
    } on Exception catch (error) {
      debugPrint('Unexpected Admin login error: $error');

      if (sessionStarted) {
        await _trySignOut(client);
      }

      _showError(
        'Sign-in failed. Check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: _AdminLoginBackground(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const BrandMark(
                              showTagline: false,
                              iconSize: 42,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                tooltip: 'Back',
                                onPressed: () => context.go(
                                  AppConstants.moduleSelectionRoute,
                                ),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16071D20),
                              blurRadius: 28,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppColors.teal,
                                  size: 34,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Admin sign in',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in with your authorized administrator account.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge,
                            ),
                            const SizedBox(height: 26),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.email,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Email address',
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                      ),
                                    ),
                                    validator: _validateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: !_isPasswordVisible,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onFieldSubmitted: (_) => _signIn(),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: _isPasswordVisible
                                            ? 'Hide password'
                                            : 'Show password',
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                  ),
                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF0ED),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: Color(0xFFB34332),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: Color(0xFF8F3024),
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 22),
                                  PrimaryButton(
                                    text: 'Sign in',
                                    icon: Icons.arrow_forward_rounded,
                                    isLoading: _isLoading,
                                    onPressed: _signIn,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Authorized administrators only',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminLoginBackground extends StatelessWidget {
  const _AdminLoginBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCBEDE4),
            Color(0xFFD8EEF2),
            Color(0xFFF9E6DA),
          ],
          stops: [0, 0.56, 1],
        ),
      ),
    );
  }
}
