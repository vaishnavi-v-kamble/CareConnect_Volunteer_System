import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_mark.dart';

class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({super.key});

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  static const _logoTapWindow = Duration(seconds: 2);
  static const _requiredLogoTaps = 5;

  Timer? _logoTapResetTimer;
  int _logoTapCount = 0;

  @override
  void dispose() {
    _logoTapResetTimer?.cancel();
    super.dispose();
  }

  void _handleLogoTap() {
    _logoTapResetTimer?.cancel();
    _logoTapCount++;

    if (_logoTapCount < _requiredLogoTaps) {
      _logoTapResetTimer = Timer(_logoTapWindow, () {
        _logoTapCount = 0;
        _logoTapResetTimer = null;
      });
      return;
    }

    _logoTapCount = 0;
    _logoTapResetTimer = null;
    unawaited(HapticFeedback.selectionClick());
    context.go(AppConstants.adminLoginRoute);
  }

  static const _modules = [
    _ModuleOption(
      role: AppConstants.ngo,
      title: 'NGO',
      description: 'Lead change',
      imagePath: 'assets/images/roles/ngo.png',
      icon: Icons.apartment_rounded,
    ),
    _ModuleOption(
      role: AppConstants.volunteer,
      title: 'Volunteer',
      description: 'Give your time',
      imagePath: 'assets/images/roles/volunteer.png',
      icon: Icons.volunteer_activism_rounded,
    ),
    _ModuleOption(
      role: AppConstants.beneficiary,
      title: 'Beneficiary',
      description: 'Find support',
      imagePath: 'assets/images/roles/beneficiary.png',
      icon: Icons.people_alt_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _SelectionBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: _handleLogoTap,
                              behavior: HitTestBehavior.opaque,
                              child: const BrandMark(
                                showTagline: false,
                                iconSize: 42,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                tooltip: 'Back',
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Choose how you’ll\nmake a difference.',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 32, height: 1.16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'There’s a place for everyone in a caring community.',
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(fontSize: 15, height: 1.55),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _modules.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final module = _modules[index];
                          return _ModuleCard(
                            module: module,
                            onTap: () => context.go(
                              '${AppConstants.loginRoute}/${module.role}',
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      const _CommunityFooter(
                        text: 'Good things happen when we show up for each other.',
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

class _SelectionBackground extends StatelessWidget {
  const _SelectionBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCBEDE4), Color(0xFFD8EEF2), Color(0xFFF9E6DA)],
          stops: [0, 0.56, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _BackgroundCircle(size: 300, color: Color(0x3389CFC0)),
          ),
          Positioned(
            bottom: 30,
            left: -175,
            child: _BackgroundCircle(size: 360, color: Color(0x22F1B8A0)),
          ),
        ],
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size, required this.color});

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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final _ModuleOption module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${module.title}: ${module.description}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                module.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: AppColors.teal,
                  child: Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x16000000), Color(0xCC071D20)],
                    stops: [0.2, 1],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54),
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 12,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(module.icon, color: Colors.white, size: 26),
                    const SizedBox(height: 10),
                    Text(
                      module.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

class _ModuleOption {
  const _ModuleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });

  final String role;
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
}
