import 'package:flutter/material.dart';
import 'package:sample/src/screens/about_me_screen.dart';
import 'package:sample/src/screens/category_screen.dart';
import 'package:sample/src/screens/dashboard_screen.dart';
import 'package:sample/src/screens/login_screen.dart';
import 'package:sample/src/screens/product_detail_screen.dart';
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

      case Screenroutes.productDetail:
        final args = settings.arguments as Map<String, dynamic>?;

        // Validate that product data is provided
        if (args == null || args['product'] == null) {
          // Return to dashboard if no product data is provided
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
                  ProductDetailScreen(product: args['product']),
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

  static void navigateToProductDetail(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    Navigator.pushNamed(
      context,
      Screenroutes.productDetail,
      arguments: {'product': product},
    );
  }
}
