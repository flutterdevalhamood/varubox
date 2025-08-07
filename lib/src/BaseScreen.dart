// // import 'package:flutter/material.dart';
// // import 'package:sample/src/repo/auth_repo.dart';
// // import 'package:sample/src/util/app_navigation.dart';
// // import 'package:sample/src/util/app_routes.dart';
// // import 'package:sample/src/util/app_theme.dart';
// //
// // import '../main.dart';
// //
// // class BaseScreen extends StatefulWidget {
// //   const BaseScreen({super.key});
// //
// //   @override
// //   State<BaseScreen> createState() => _BaseScreenState();
// // }
// //
// // GlobalKey<NavigatorState>? navigatorKey = GlobalKey();
// //
// // class _BaseScreenState extends State<BaseScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       scaffoldMessengerKey: scaffoldMessengerKey,
// //       debugShowCheckedModeBanner: false,
// //       theme: appTheme,
// //       onGenerateRoute: Screenroutes.routes,
// //       initialRoute:
// //           AuthRepo.isAuthenticated
// //               ? Screenroutes.dashboard
// //               : Screenroutes.signUp,
// //       navigatorObservers: [Screenroutes.routeobserver],
// //       navigatorKey: NavigationService().navigatorKey,
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:sample/src/repo/auth_repo.dart';
// import 'package:sample/src/util/app_navigation.dart';
// import 'package:sample/src/util/app_routes.dart';
// import 'package:sample/src/util/app_theme.dart'; // Add this import
//
// import '../main.dart';
// import 'screens/signup_screen.dart';
// import 'splash/splash_screen.dart';
//
// GlobalKey<NavigatorState>? navigatorKey = GlobalKey();
//
// class BaseScreen extends StatefulWidget {
//   const BaseScreen({super.key});
//
//   @override
//   State<BaseScreen> createState() => _BaseScreenState();
// }
//
// class _BaseScreenState extends State<BaseScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       scaffoldMessengerKey: scaffoldMessengerKey,
//       debugShowCheckedModeBanner: false,
//       theme: appTheme,
//       onGenerateRoute: Screenroutes.routes,
//       home:
//           const AppInitializer(), // Start with app initializer instead of direct routing
//       navigatorObservers: [Screenroutes.routeobserver],
//       navigatorKey: NavigationService().navigatorKey,
//     );
//   }
// }
//
// class AppInitializer extends StatefulWidget {
//   const AppInitializer({super.key});
//
//   @override
//   State<AppInitializer> createState() => _AppInitializerState();
// }
//
// class _AppInitializerState extends State<AppInitializer> {
//   AuthState _currentAuthState = AuthState.initialize;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }
//
//   Future<void> _initializeApp() async {
//     await AuthRepo.initAuth();
//
//     // Update the state to trigger navigation
//     if (mounted) {
//       setState(() {
//         _currentAuthState = AuthRepo.authState;
//       });
//
//       // Navigate based on authentication state
//       _navigateBasedOnAuthState();
//     }
//   }
//
//   void _navigateBasedOnAuthState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       switch (_currentAuthState) {
//         case AuthState.authenticated:
//           Navigator.of(context).pushReplacementNamed(Screenroutes.loginScreen);
//           break;
//         case AuthState.unauthenticated:
//           Navigator.of(context).pushReplacementNamed(Screenroutes.signUp);
//           break;
//         case AuthState.initialize:
//           // Still loading, stay on splash
//           break;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 300),
//       child: _getCurrentScreen(),
//     );
//   }
//
//   Widget _getCurrentScreen() {
//     switch (_currentAuthState) {
//       case AuthState.initialize:
//         return const SplashScreen();
//       case AuthState.authenticated:
//         return const SignupScreen();
//       case AuthState.unauthenticated:
//         return const SplashScreen();
//       default:
//         return const SplashScreen();
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:sample/src/repo/auth_repo.dart';
import 'package:sample/src/util/app_navigation.dart';
import 'package:sample/src/util/app_routes.dart';
import 'package:sample/src/util/app_theme.dart';

import '../main.dart';
import 'splash/splash_screen.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey();

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      onGenerateRoute: Screenroutes.routes,
      home: const AppInitializer(),
      navigatorObservers: [Screenroutes.routeobserver],
      navigatorKey: NavigationService().navigatorKey,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await AuthRepo.initAuth();

    // Mark as initialized
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF48BB78)),
        ),
      );
    }

    return const SplashScreen();
  }
}
