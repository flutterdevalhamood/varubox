import 'package:flutter/material.dart';
import 'package:sample/src/screens/about_me_screen.dart';
import 'package:sample/src/screens/category_screen.dart';
import 'package:sample/src/screens/dashboard_screen.dart';
import 'package:sample/src/screens/filter_screen.dart';
import 'package:sample/src/screens/login_screen.dart';
import 'package:sample/src/screens/product_detail_screen.dart';
import 'package:sample/src/screens/search_screen.dart';
import 'package:sample/src/screens/verify_otp_screen.dart';
import 'package:sample/src/splash/splash_screen.dart';

import '../constants/string_constants.dart';
import '../screens/signup_screen.dart';

class Screenroutes {
  static final RouteObserver<PageRoute> routeobserver =
      RouteObserver<PageRoute>();
  static const String splash = "splash";
  static const String signUp = "signUp";
  static const String verifyOtp = "verifyOtp";
  static const String loginScreen = "login";
  static const String dashboard = "DashBoard";
  static const String productDetail = "productDetail";
  static const String categoryScreen = "categoryScreen";
  static const String aboutMe = "aboutMe";
  static const String filterScreen = "filterScreen";
  static const String searchScreen = "searchScreen";

  static Route<dynamic>? routes(RouteSettings settings) {
    StringConstants.currentRoute = settings.name ?? "";

    switch (settings.name) {
      case Screenroutes.splash:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.splash),
          builder: (BuildContext context) {
            return SplashScreen();
          },
        );
      case Screenroutes.signUp:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.signUp),
          builder: (BuildContext context) {
            return SignupScreen();
          },
        );

      case Screenroutes.verifyOtp:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.verifyOtp),
          builder: (BuildContext context) {
            return OtpVerificationScreen(
              email: args?['email'],
              password: args?['password'],
            );
          },
        );

      case Screenroutes.loginScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.loginScreen),
          builder: (BuildContext context) {
            return LoginScreen();
          },
        );
      case Screenroutes.dashboard:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.dashboard),
          builder: (BuildContext context) {
            return DashboardScreen();
          },
        );

      case Screenroutes.filterScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.filterScreen),
          builder: (BuildContext context) {
            return FilterScreen();
          },
        );

      case Screenroutes.searchScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.searchScreen),
          builder: (BuildContext context) {
            return SearchScreen();
          },
        );

      case Screenroutes.productDetail:
        final args = settings.arguments as Map<String, dynamic>?;

        // Validate that productId is provided
        if (args == null || args['productId'] == null) {
          // Return to dashboard if no product ID is provided
          return MaterialPageRoute(
            settings: const RouteSettings(name: Screenroutes.dashboard),
            builder: (BuildContext context) {
              return const DashboardScreen();
            },
          );
        }

        // Validate that productId is a valid integer
        int? productId;
        if (args['productId'] is int) {
          productId = args['productId'] as int;
        } else if (args['productId'] is String) {
          productId = int.tryParse(args['productId'] as String);
        }

        if (productId == null || productId <= 0) {
          // Return to dashboard if invalid product ID
          return MaterialPageRoute(
            settings: const RouteSettings(name: Screenroutes.dashboard),
            builder: (BuildContext context) {
              return const DashboardScreen();
            },
          );
        }

        return PageRouteBuilder(
          settings: const RouteSettings(name: Screenroutes.productDetail),
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  ProductDetailScreen(productId: productId!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Custom slide transition from right to left
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );

      case Screenroutes.categoryScreen:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.categoryScreen),
          builder: (BuildContext context) {
            return CategoriesScreen();
          },
        );

      case Screenroutes.aboutMe:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Screenroutes.aboutMe),
          builder: (BuildContext context) {
            return AboutMeScreen();
          },
        );
    }
    return null;
  }

  // Updated navigation method for product detail
  static void navigateToProductDetail(BuildContext context, int productId) {
    Navigator.pushNamed(
      context,
      Screenroutes.productDetail,
      arguments: {'productId': productId},
    );
  }

  // Alternative navigation method that accepts both int and string
  static void navigateToProductDetailById(
    BuildContext context,
    dynamic productId, // Can be int or String
  ) {
    int? validProductId;

    if (productId is int) {
      validProductId = productId;
    } else if (productId is String) {
      validProductId = int.tryParse(productId);
    }

    if (validProductId != null && validProductId > 0) {
      Navigator.pushNamed(
        context,
        Screenroutes.productDetail,
        arguments: {'productId': validProductId},
      );
    } else {
      // Handle invalid product ID - could show error or return to previous screen
      debugPrint('Invalid product ID: $productId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid product ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
