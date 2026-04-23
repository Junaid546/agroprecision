import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import 'widgets/onboarding_illustrations.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final OnboardingIllustration illustration;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      title: 'Your Farm, Digitized',
      description:
          'Track every detail of your poultry operation with precision. Monitor growth, health, and productivity in real-time.',
      illustration: OnboardingIllustration.farmDigitized,
    ),
    OnboardingPageData(
      title: '100% Offline',
      description:
          'Work anywhere, anytime. Your data stays secure and accessible even without internet connection.',
      illustration: OnboardingIllustration.offline,
    ),
    OnboardingPageData(
      title: 'Smart Insights',
      description:
          'Get actionable insights and predictions to optimize your farm\'s performance and maximize profits.',
      illustration: OnboardingIllustration.smartInsights,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToFarmSetup();
    }
  }

  void _skipOnboarding() {
    _goToFarmSetup();
  }

  void _goToFarmSetup() {
    context.go('/onboarding/setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration
                        OnboardingIllustrationWidget(
                          type: page.illustration,
                          size: MediaQuery.of(context).size.width * 0.7,
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: AppTypography.headlineLg,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 48),

                        // Page indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (dotIndex) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: dotIndex == _currentPage ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: dotIndex == _currentPage
                                    ? AppColors.primaryContainer
                                    : AppColors.outlineVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Page indicator text
                  Text(
                    '${_currentPage + 1} of ${_pages.length}',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  // Next/Continue button
                  FilledButton(
                    onPressed: _nextPage,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
