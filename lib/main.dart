import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample/src/providers/cart_controller.dart';
import 'package:sample/src/providers/dashboard_controller.dart';
import 'package:sample/src/providers/favourites_controller.dart';
import 'package:sample/src/providers/login_controller.dart';
import 'package:sample/src/providers/product_detail_controller.dart';
import 'package:sample/src/repo/auth_repo.dart';
import 'package:sample/src/util/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/BaseScreen.dart';
import 'src/providers/signup_controller.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthRepo.initAuth();
  prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => SignUpController()),
        ChangeNotifierProvider(create: (context) => DashboardController()),
        ChangeNotifierProvider(create: (context) => ProductDetailController()),
        ChangeNotifierProvider(create: (context) => CartController()),
        ChangeNotifierProvider(create: (context) => FavoritesController()),
      ],
      child: const BaseScreen(),
    ),
  );
}
