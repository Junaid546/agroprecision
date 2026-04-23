import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
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
            // Top Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Container
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(32),
                          child: OnboardingIllustrationWidget(
                            type: page.illustration,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: AppTypography.headlineLg.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (dotIndex) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: dotIndex == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dotIndex == _currentPage
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: AppTypography.labelBold.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
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

