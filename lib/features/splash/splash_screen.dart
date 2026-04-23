import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/app_state_provider.dart';
import 'widgets/grid_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;

  late AnimationController _textController;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _taglineOpacityAnimation;

  late AnimationController _badgeController;
  late Animation<Offset> _badgeSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Icon animation: scale from 0.8 to 1.0 with elastic curve
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    // Text animations with staggered fade-ins
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _taglineOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    // Badge slide-up animation
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOut,
    ));

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start icon animation immediately
    _iconController.forward();

    // Start text animations after 200ms delay
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // Start badge animation after 600ms delay
    await Future.delayed(const Duration(milliseconds: 400));
    _badgeController.forward();

    // Navigate after minimum 1800ms total
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final farm = ref.read(currentFarmProvider);
    if (farm != null) {
      context.go('/home/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with subtle gradient and grid pattern
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAF4),
            ),
            child: CustomPaint(
              painter: GridPainter(
                gridColor: const Color(0xFF000000).withOpacity(0.03),
                gridSpacing: 32.0,
              ),
              size: Size.infinite,
            ),
          ),

          // Soft radial gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  AppColors.surfaceVariant.withOpacity(0.4),
                  AppColors.surface,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Spacer to push content slightly below center
                  const SizedBox(height: 64),

                  // Centered content
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Premium icon container
                          AnimatedBuilder(
                            animation: _iconScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _iconScaleAnimation.value,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF14532D)
                                            .withOpacity(0.12),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: AppColors.primaryContainer,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // App name with fade animation
                          AnimatedBuilder(
                            animation: _titleOpacityAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _titleOpacityAnimation.value,
                                child: Text(
                                  'AgroPrecision',
                                  style: GoogleFonts.manrope(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryContainer,
                                    letterSpacing: -1,
                                    height: 44 / 36,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          // Tagline with fade animation
                          AnimatedBuilder(
                            animation: _taglineOpacityAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _taglineOpacityAnimation.value,
                                child: Text(
                                  'Precision Farming. Maximum Yield.',
                                  style: AppTypography.bodyLg.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom badge with slide animation
                  AnimatedBuilder(
                    animation: _badgeSlideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _badgeSlideAnimation,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.outlineVariant.withOpacity(0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_done,
                                color: AppColors.primaryContainer,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'POWERED BY OFFLINE-FIRST TECHNOLOGY',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
