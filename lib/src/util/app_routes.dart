import 'package:flutter/material.dart';
import 'package:sample/src/screens/about_me_screen.dart';
import 'package:sample/src/screens/dashboard_screen.dart';
import 'package:sample/src/screens/login_screen.dart';
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
}
