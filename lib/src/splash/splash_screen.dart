// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sample/src/repo/auth_repo.dart';
// import 'package:sample/src/util/app_routes.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   late PageController _pageController;
//   int _currentIndex = 0;
//
//   final List<OnboardingData> _pages = [
//     OnboardingData(
//       title: "Buy Grocery",
//       description:
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy",
//       imagePath: "assets/images/grocery.png", // You'll need to add this asset
//       backgroundColor: const Color(0xFFF8F9FA),
//     ),
//     OnboardingData(
//       title: "Fast Delivery",
//       description:
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy",
//       imagePath: "assets/images/delivery.png", // You'll need to add this asset
//       backgroundColor: const Color(0xFFF8F9FA),
//     ),
//     OnboardingData(
//       title: "Enjoy Quality Food",
//       description:
//           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonumy",
//       imagePath: "assets/images/food.png", // You'll need to add this asset
//       backgroundColor: const Color(0xFFF8F9FA),
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _onNextPressed() {
//     if (_currentIndex < _pages.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     } else {
//       _navigateToApp();
//     }
//   }
//
//   void _onSkipPressed() {
//     _navigateToApp();
//   }
//
//   void _navigateToApp() {
//     if (AuthRepo.isAuthenticated) {
//       // User is authenticated, go to dashboard
//       Navigator.of(
//         context,
//       ).pushNamedAndRemoveUntil(Screenroutes.dashboard, (route) => false);
//     } else {
//       // User is not authenticated, go to signup/login
//       Navigator.of(
//         context,
//       ).pushNamedAndRemoveUntil(Screenroutes.signUp, (route) => false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         systemNavigationBarColor: Colors.transparent,
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF8F9FA),
//         body: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: PageView.builder(
//                   controller: _pageController,
//                   itemCount: _pages.length,
//                   onPageChanged: (index) {
//                     setState(() {
//                       _currentIndex = index;
//                     });
//                   },
//                   itemBuilder: (context, index) {
//                     return _buildPage(_pages[index]);
//                   },
//                 ),
//               ),
//               _buildBottomSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPage(OnboardingData data) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 40.0),
//       child: Column(
//         children: [
//           const Spacer(flex: 1),
//           // Illustration Container
//           Container(
//             height: 300,
//             width: double.infinity,
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//             child: _buildIllustration(_currentIndex),
//           ),
//           const Spacer(flex: 1),
//           // Title
//           Text(
//             data.title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D3748),
//               height: 1.2,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Description
//           Text(
//             data.description,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Color(0xFF718096),
//               height: 1.5,
//             ),
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildIllustration(int index) {
//     switch (index) {
//       case 0:
//         return _buildGroceryIllustration();
//       case 1:
//         return _buildDeliveryIllustration();
//       case 2:
//         return _buildFoodIllustration();
//       default:
//         return Container();
//     }
//   }
//
//   Widget _buildGroceryIllustration() {
//     return Center(
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Phone mockup
//           Container(
//             width: 180,
//             height: 320,
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Container(
//               margin: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     height: 20,
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 60,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   Expanded(
//                     child: Container(
//                       margin: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF0F8F0),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Center(
//                         child: Icon(
//                           Icons.shopping_basket,
//                           size: 60,
//                           color: Color(0xFF48BB78),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Person illustration
//           Positioned(
//             right: 0,
//             child: Container(
//               width: 120,
//               height: 160,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF48BB78),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Center(
//                 child: Icon(Icons.person, size: 80, color: Colors.white),
//               ),
//             ),
//           ),
//           // Shopping cart
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: Container(
//               width: 60,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Center(
//                 child: Icon(Icons.shopping_cart, color: Colors.grey),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeliveryIllustration() {
//     return Center(
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Delivery scooter
//           Container(
//             width: 280,
//             height: 180,
//             child: Stack(
//               children: [
//                 // Scooter body
//                 Positioned(
//                   bottom: 40,
//                   left: 40,
//                   child: Container(
//                     width: 200,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF48BB78),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//                 // Front wheel
//                 Positioned(
//                   bottom: 0,
//                   left: 60,
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: const BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 // Back wheel
//                 Positioned(
//                   bottom: 0,
//                   right: 60,
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: const BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 // Delivery person
//                 Positioned(
//                   top: 0,
//                   left: 100,
//                   child: Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFDD835),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: const Center(
//                       child: Icon(Icons.person, size: 50, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Location pin
//           Positioned(
//             top: 20,
//             left: 60,
//             child: Container(
//               width: 40,
//               height: 50,
//               decoration: const BoxDecoration(color: Color(0xFF48BB78)),
//               child: const Icon(
//                 Icons.location_pin,
//                 color: Colors.white,
//                 size: 30,
//               ),
//             ),
//           ),
//           // Clock
//           Positioned(
//             top: 20,
//             right: 60,
//             child: Container(
//               width: 50,
//               height: 50,
//               decoration: const BoxDecoration(
//                 color: Colors.black,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.schedule, color: Colors.white, size: 30),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFoodIllustration() {
//     return Center(
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Chef character
//           Container(
//             width: 200,
//             height: 200,
//             child: Stack(
//               children: [
//                 // Chef body
//                 Positioned(
//                   bottom: 0,
//                   left: 50,
//                   child: Container(
//                     width: 100,
//                     height: 140,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Center(
//                       child: Icon(
//                         Icons.restaurant_menu,
//                         size: 40,
//                         color: Color(0xFF48BB78),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Chef hat
//                 Positioned(
//                   top: 0,
//                   left: 60,
//                   child: Container(
//                     width: 80,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(color: Colors.grey, width: 2),
//                     ),
//                     child: const Center(
//                       child: Icon(Icons.restaurant, color: Color(0xFF48BB78)),
//                     ),
//                   ),
//                 ),
//                 // Chef face
//                 Positioned(
//                   top: 40,
//                   left: 70,
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFD69E2E),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Food items
//           Positioned(
//             right: 20,
//             top: 50,
//             child: Container(
//               width: 60,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFED8936),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 0,
//             bottom: 80,
//             child: Container(
//               width: 50,
//               height: 35,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE53E3E),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           // Heart icon
//           Positioned(
//             top: 60,
//             right: 40,
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF48BB78),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.favorite, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBottomSection() {
//     return Padding(
//       padding: const EdgeInsets.all(40.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Skip button
//           TextButton(
//             onPressed: _onSkipPressed,
//             child: const Text(
//               "Skip",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF718096),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           // Page indicators
//           Row(
//             children: List.generate(
//               _pages.length,
//               (index) => Container(
//                 width: 8,
//                 height: 8,
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color:
//                       _currentIndex == index
//                           ? const Color(0xFF48BB78)
//                           : const Color(0xFFE2E8F0),
//                 ),
//               ),
//             ),
//           ),
//           // Next button
//           TextButton(
//             onPressed: _onNextPressed,
//             child: Text(
//               _currentIndex == _pages.length - 1 ? "Get Started" : "Next",
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF48BB78),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class OnboardingData {
//   final String title;
//   final String description;
//   final String imagePath;
//   final Color backgroundColor;
//
//   OnboardingData({
//     required this.title,
//     required this.description,
//     required this.imagePath,
//     required this.backgroundColor,
//   });
// }

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
