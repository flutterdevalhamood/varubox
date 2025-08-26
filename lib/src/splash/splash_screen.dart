import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/src/repo/auth_repo.dart';
import 'package:sample/src/util/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Buy Grocery",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy",
      imagePath: "assets/images/grocery_splash_1.jpg",
      backgroundColor: const Color(0xFFF8F9FA),
    ),
    OnboardingData(
      title: "Fast Delivery",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy",
      imagePath: "assets/images/grocery_splash_2.jpg",
      backgroundColor: const Color(0xFFF8F9FA),
    ),
    OnboardingData(
      title: "Enjoy Quality Food",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy",
      imagePath: "assets/images/grocery_splash_3.jpg",
      backgroundColor: const Color(0xFFF8F9FA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToApp();
    }
  }

  void _onSkipPressed() {
    _navigateToApp();
  }

  void _navigateToApp() {
    if (AuthRepo.isAuthenticated) {
      // User is authenticated, go to dashboard
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Screenroutes.dashboard, (route) => false);
    } else {
      // User is not authenticated, go to signup/login
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Screenroutes.signUp, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Image Container
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(data.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Spacer(flex: 1),
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip button
          TextButton(
            onPressed: _onSkipPressed,
            child: const Text(
              "Skip",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Page indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == index
                          ? const Color(0xFF48BB78)
                          : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),
          // Next button
          TextButton(
            onPressed: _onNextPressed,
            child: Text(
              _currentIndex == _pages.length - 1 ? "Get Started" : "Next",
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF48BB78),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}
