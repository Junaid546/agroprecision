import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../core/constants/app_strings.dart';
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
  late Animation<double> _badgeOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Icon animation (0ms start, 300ms duration, elastic)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );

    // 2. Text animations (Title fades at 200ms, Tagline at 400ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600), // Covering both intervals
      vsync: this,
    );
    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.66, curve: Curves.easeIn),
      ),
    );
    _taglineOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.33, 1.0, curve: Curves.easeIn),
      ),
    );

    // 3. Badge animation (600ms start, 300ms duration)
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _badgeController, curve: Curves.easeOut));
    _badgeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeIn),
    );

    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    // 0ms: Start icon
    _iconController.forward();

    // 200ms: Start name fade (textController handles both name and tagline)
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // 600ms total (200 + 400): Start badge
    await Future.delayed(const Duration(milliseconds: 400));
    _badgeController.forward();

    // Total sequence time: ~900ms animations + delays.
    // Requirement: Show minimum 1800ms total.
    await Future.delayed(const Duration(milliseconds: 1200));
    _completeSplash();
  }

  void _completeSplash() {
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
      backgroundColor: const Color(0xFFF8FAF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Grid pattern background
          CustomPaint(
            painter: GridPainter(
              gridColor: const Color(0xFF000000).withOpacity(0.03),
              gridSpacing: 32.0,
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon Card
                ScaleTransition(
                  scale: _iconScaleAnimation,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/app logo.png',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                FadeTransition(
                  opacity: _titleOpacityAnimation,
                  child: Text(
                    AppStrings.appName,
                    style: GoogleFonts.manrope(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                FadeTransition(
                  opacity: _taglineOpacityAnimation,
                  child: Text(
                    'Precision Farming. Maximum Yield.',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Badge
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _badgeOpacityAnimation,
              child: SlideTransition(
                position: _badgeSlideAnimation,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_done,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'POWERED BY OFFLINE-FIRST TECHNOLOGY',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                            fontSize: 10, // Adjusted to fit nicely
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
