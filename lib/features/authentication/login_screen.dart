import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_mark.dart';
import '../../shared/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _fullNamePattern = RegExp(
    r"^\p{L}[\p{L}\p{M}]*(?:[ '’-][\p{L}\p{M}]+)*$",
    unicode: true,
  );
  static final _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$",
  );
  static final _phonePattern = RegExp(r'^\d{10}$');
  static final _passwordPattern = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d\s])\S{8,15}$',
  );

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegistering = false;
  bool _isPasswordVisible = false;

  String get _roleName {
    switch (widget.role.toLowerCase()) {
      case 'ngo':
        return 'NGO';
      case 'volunteer':
        return 'Volunteer';
      case 'beneficiary':
        return 'Beneficiary';
      case 'admin':
        return 'Admin';
      default:
        if (widget.role.isEmpty) return 'User';
        return '${widget.role[0].toUpperCase()}${widget.role.substring(1)}';
    }
  }

  String get _heroImage {
    switch (widget.role.toLowerCase()) {
      case 'ngo':
        return 'assets/images/roles/ngo.png';
      case 'volunteer':
        return 'assets/images/roles/volunteer.png';
      case 'beneficiary':
        return 'assets/images/roles/beneficiary.png';
      case 'admin':
        return 'assets/images/roles/admin.jpg';
      default:
        return 'assets/images/roles/volunteer.png';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name';
    if (name.length > 80 || !_fullNamePattern.hasMatch(name)) {
      return 'Use letters, spaces, hyphens, or apostrophes only';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || email.length > 254 || !_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (!_phonePattern.hasMatch(phone)) {
      return 'Enter exactly 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || !_passwordPattern.hasMatch(value)) {
      return 'Use 8–15 characters with at least one letter, digit, and special symbol';
    }
    return null;
  }

  String? _validateExistingPassword(String? value) {
    return value == null || value.isEmpty ? 'Enter your password' : null;
  }

  void _showPendingIntegration() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No request was sent. Supabase authentication is not integrated yet.',
        ),
      ),
    );
  }

  void _showPasswordRecoveryNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password recovery will be available after setup.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const BrandMark(showTagline: false, iconSize: 42),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  tooltip: 'Back',
                                  onPressed: () =>
                                      context.go('/module-selection'),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _WelcomeBanner(imagePath: _heroImage),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F8F3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: AppColors.teal,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_roleName.toUpperCase()} PORTAL',
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          _isRegistering
                              ? 'Join our community'
                              : 'Welcome back',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isRegistering
                              ? 'Create an account to make a difference.'
                              : 'Sign in to keep our community connected.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2F1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              _AuthModeButton(
                                label: 'Sign in',
                                selected: !_isRegistering,
                                onPressed: () =>
                                    setState(() => _isRegistering = false),
                              ),
                              _AuthModeButton(
                                label: 'Register',
                                selected: _isRegistering,
                                onPressed: () =>
                                    setState(() => _isRegistering = true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_isRegistering) ...[
                          TextFormField(
                            controller: _fullNameController,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.name],
                            decoration: const InputDecoration(
                              hintText: 'Full name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: _validateFullName,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: _validateEmail,
                        ),
                        if (_isRegistering) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            maxLength: 10,
                            decoration: const InputDecoration(
                              hintText: 'Mobile number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              counterText: '',
                            ),
                            validator: _validatePhone,
                          ),
                        ],
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          autofillHints: _isRegistering
                              ? const [AutofillHints.newPassword]
                              : const [AutofillHints.password],
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _isPasswordVisible
                                  ? 'Hide password'
                                  : 'Show password',
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          validator: _isRegistering
                              ? _validatePassword
                              : _validateExistingPassword,
                        ),
                        if (_isRegistering) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isPasswordVisible,
                            decoration: const InputDecoration(
                              hintText: 'Confirm password',
                              prefixIcon: Icon(Icons.lock_reset_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                        if (!_isRegistering)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPasswordRecoveryNotice,
                              child: const Text('Forgot password?'),
                            ),
                          )
                        else
                          const SizedBox(height: 10),
                        const SizedBox(height: 4),
                        PrimaryButton(
                          text: _isRegistering ? 'Create account' : 'Sign in',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _showPendingIntegration,
                        ),
                        const SizedBox(height: 18),
                        const _CommunityFooter(
                          text: 'A trusted space for the people behind the good work.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Supabase setup needed before account access.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCBEDE4), Color(0xFFD8EEF2), Color(0xFFF9E6DA)],
          stops: [0, 0.57, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 210,
            right: -130,
            child: _LoginBackgroundCircle(size: 350, color: Color(0x2889CFC0)),
          ),
          Positioned(
            bottom: 40,
            left: -180,
            child: _LoginBackgroundCircle(size: 420, color: Color(0x20F1B8A0)),
          ),
        ],
      ),
    );
  }
}

class _LoginBackgroundCircle extends StatelessWidget {
  const _LoginBackgroundCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: AppColors.teal,
                child: Center(
                  child: Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xB511292A), Color(0x2411292A)],
                ),
              ),
            ),
            const Positioned(
              left: 18,
              right: 56,
              bottom: 18,
              child: Text(
                'Many hands. One caring community.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityFooter extends StatelessWidget {
  const _CommunityFooter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.volunteer_activism_rounded,
          color: AppColors.teal,
          size: 22,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthModeButton extends StatelessWidget {
  const _AuthModeButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: selected ? AppColors.white : Colors.transparent,
          foregroundColor: selected ? AppColors.ink : AppColors.muted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
