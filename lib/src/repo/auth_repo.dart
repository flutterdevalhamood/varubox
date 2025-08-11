import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sample/src/util/app_routes.dart';

import '../BaseScreen.dart';
import '../util/shared_pref.dart';

enum AuthState { initialize, authenticated, unauthenticated }

class AuthRepo extends ChangeNotifier {
  static const _prefUserKey = "userBase";
  static const _prefTokenKey = "token";
  static const _prefRoleKey = "role";
  static const _prefLoginIdKey = "Id";
  static const _prefContactKey = "contact";
  static const _prefEmailKey = "email"; // Add email key
  static const _prefTokenExpiryKey = "tokenExpiry";

  static AuthState _authState = AuthState.initialize;
  static AuthState get authState => _authState;

  // Initialize authentication state
  static Future<void> initAuth() async {
    debugPrint("Initializing authentication state");

    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final storedToken = prefs?.getString(_prefTokenKey);
      final storedLoginId = loginId;

      if (storedToken != null &&
          storedToken.isNotEmpty &&
          storedLoginId != null &&
          !isTokenExpired()) {
        _authState = AuthState.authenticated;
        debugPrint("User is authenticated");
      } else {
        if (storedToken != null && isTokenExpired()) {
          debugPrint("Token expired - clearing data");
          await _clearExpiredData();
        }
        _authState = AuthState.unauthenticated;
        debugPrint("User is not authenticated");
      }
    } catch (e) {
      debugPrint("Error during auth initialization: $e");
      _authState = AuthState.unauthenticated;
    }
  }

  // Authenticate user
  static Future<void> authenticate({
    required String token,
    required int userId,
    String? userRole,
    String? userContact,
    String? userData,
    String? userEmail, // Add email parameter
  }) async {
    AuthRepo.token = token;
    AuthRepo.loginId = userId;
    if (userRole != null) AuthRepo.role = userRole;
    if (userContact != null) AuthRepo.contact = userContact;
    if (userData != null) AuthRepo.user = userData;
    if (userEmail != null) AuthRepo.email = userEmail; // Store email

    _authState = AuthState.authenticated;
    debugPrint("User authenticated successfully");
  }

  // Clear expired data
  static Future<void> _clearExpiredData() async {
    prefs?.remove(_prefTokenKey);
    prefs?.remove(_prefTokenExpiryKey);
  }

  // Token setters and getters
  static set token(String? token) {
    if (token == null) {
      prefs?.remove(_prefTokenKey);
      prefs?.remove(_prefTokenExpiryKey);
      debugPrint("Token removed from storage");
    } else {
      prefs?.setString(_prefTokenKey, token);
      // Set token expiry to 24 hours from now (adjust as needed based on your server config)
      setTokenExpiry(
        DateTime.now().add(Duration(hours: 24)).millisecondsSinceEpoch,
      );
      debugPrint("Token stored: ${_tokenDebugString(token)}");
    }
  }

  static String? get token {
    final storedToken = prefs?.getString(_prefTokenKey);
    // Check if token is expired
    if (storedToken != null && isTokenExpired()) {
      debugPrint("Token is expired - consider refreshing");
    }
    return storedToken;
  }

  // Email setters and getters
  static set email(String? email) {
    if (email == null) {
      prefs?.remove(_prefEmailKey);
    } else {
      prefs?.setString(_prefEmailKey, email);
    }
  }

  static String? get email {
    return prefs?.getString(_prefEmailKey);
  }

  // Token expiry helpers
  static void setTokenExpiry(int expiryTimestamp) {
    prefs?.setInt(_prefTokenExpiryKey, expiryTimestamp);
  }

  static int? getTokenExpiry() {
    return prefs?.getInt(_prefTokenExpiryKey);
  }

  static bool isTokenExpired() {
    final expiry = getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  // Token validation and refresh
  static bool hasValidToken() {
    final storedToken = prefs?.getString(_prefTokenKey);
    return storedToken != null && storedToken.isNotEmpty && !isTokenExpired();
  }

  static Future<bool> refreshToken() async {
    // This is a placeholder. In a real app, you would call your refresh token API here
    // For now, we just check if the token exists
    final currentToken = token;
    debugPrint(
      "Token refresh check: ${currentToken != null && currentToken.isNotEmpty}",
    );
    return currentToken != null && currentToken.isNotEmpty;
  }

  // Role setters and getters
  static set role(String? role) {
    if (role == null) {
      prefs?.remove(_prefRoleKey);
    } else {
      prefs?.setString(_prefRoleKey, role);
    }
  }

  static String? get role {
    return prefs?.getString(_prefRoleKey);
  }

  // Contact setters and getters
  static set contact(String? contact) {
    if (contact == null) {
      prefs?.remove(_prefContactKey);
    } else {
      prefs?.setString(_prefContactKey, contact);
    }
  }

  static String? get contact {
    return prefs?.getString(_prefContactKey);
  }

  // User setters and getters
  static set user(String? user) {
    if (user == null) {
      prefs?.remove(_prefUserKey);
    } else {
      final userJson = jsonEncode(user);
      prefs?.setString(_prefUserKey, userJson);
    }
  }

  static String? get user {
    var value = prefs?.getString(_prefUserKey);
    if (value == null) return null;

    final userJson = jsonDecode(value);
    return userJson;
  }

  // Login ID setters and getters
  static set loginId(int? id) {
    if (id == null) {
      prefs?.remove(_prefLoginIdKey);
    } else {
      final userJson = jsonEncode(id);
      prefs?.setString(_prefLoginIdKey, userJson);
    }
  }

  static int? get loginId {
    var value = prefs?.getString(_prefLoginIdKey);
    if (value == null) return null;
    final customerIdJson = jsonDecode(value);
    return customerIdJson;
  }

  // Authentication state
  static bool get isAuthenticated {
    final hasToken = token != null && token!.isNotEmpty;
    final isLoggedIn = loginId != null;
    return hasToken && isLoggedIn && !isTokenExpired();
  }

  // Logout
  static Future<void> logOut() async {
    debugPrint("Logging out user");
    prefs?.clear();
    user = null;
    _authState = AuthState.unauthenticated;

    navigatorKey?.currentState?.pushNamedAndRemoveUntil(
      Screenroutes.loginScreen,
      (route) => false,
    );
  }

  // Handle auth errors
  static Future<void> handleAuthError() async {
    debugPrint("Authentication error detected - logging out");
    await logOut();
  }

  // Debug helper
  static String _tokenDebugString(String token) {
    if (token.isEmpty) {
      return "empty";
    }
    if (token.length > 20) {
      return "${token.substring(0, 20)}...";
    }
    return token;
  }
}
