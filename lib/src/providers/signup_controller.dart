import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/util/app_navigation.dart';
import 'package:sample/src/util/app_routes.dart';

import '../data/rest_client.dart';
import '../util/circle_progress.dart';
import '../util/snack.dart';

class SignUpController with ChangeNotifier {
  bool _isLoading = false;
  String? _currentEmail;
  String? _currentPassword;

  bool get isLoading => _isLoading;
  String? get currentEmail => _currentEmail;
  String? get currentPassword => _currentPassword;

  // Store user data for OTP verification
  void setUserData(String email, String password) {
    _currentEmail = email;
    _currentPassword = password;
    notifyListeners();
  }

  // Clear user data
  void clearUserData() {
    _currentEmail = null;
    _currentPassword = null;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    showCircle();

    try {
      final signUpResponse = await restApi.signUp(
        email: email,
        password: password,
      );

      log('SignUp Response: ${signUpResponse.toString()}');

      // Handle the response as a Map<String, dynamic>
      Map<String, dynamic> responseData;

      if (signUpResponse is Map<String, dynamic>) {
        responseData = signUpResponse;
      } else {
        // If it's a custom object, try to convert it
        responseData = {
          'StatusCode': signUpResponse.StatusCode ?? 0,
          'Message': signUpResponse.Message ?? '',
          'IsSuccess': signUpResponse.IsSuccess ?? false,
          'Data': signUpResponse.Data ?? '',
        };
      }

      // Check for success based on the API response structure
      bool isSuccess = responseData['IsSuccess'] == true;
      int statusCode = responseData['StatusCode'] ?? 0;

      if (isSuccess && statusCode == 200) {
        // Success: OTP sent to email
        String successMessage =
            responseData['Data']?.toString() ??
            responseData['Message']?.toString() ??
            'OTP sent to your email. Please verify within 15 minutes.';

        showSuccessSnack(successMessage);

        // Navigate to OTP verification screen after a short delay
        Future.delayed(const Duration(milliseconds: 1500), () {
          NavigationService().pushNavigation(
            Screenroutes.verifyOtp,
            arguments: {'email': _currentEmail, 'password': _currentPassword},
          );
        });

        return true;
      } else {
        // Handle failure cases
        String errorMessage =
            responseData['Message']?.toString() ?? 'Signup failed';

        // Handle specific status codes
        switch (statusCode) {
          case 400:
            // Bad request - validation errors
            errorMessage = signUpResponse.Message ?? 'Invalid input data';
            break;
          case 401:
            // Unauthorized - might indicate email already exists with pending verification
            if (errorMessage.toLowerCase().contains('otp') ||
                errorMessage.toLowerCase().contains('verify')) {
              // OTP already sent scenario
              showSuccessSnack(errorMessage);
              Future.delayed(const Duration(milliseconds: 1500), () {
                NavigationService().pushNavigation(Screenroutes.verifyOtp);
              });
              return true;
            }
            break;
          case 409:
            // Conflict - user already exists
            errorMessage =
                responseData['Message']?.toString() ?? 'User already exists';
            break;
          case 422:
            // Unprocessable entity - validation errors
            errorMessage =
                responseData['Message']?.toString() ??
                'Please check your input data';
            break;
          case 429:
            // Too many requests
            errorMessage =
                responseData['Message']?.toString() ??
                'Too many attempts. Please try again later.';
            break;
          default:
            errorMessage =
                responseData['Message']?.toString() ??
                'Signup failed. Please try again.';
        }

        showErrorSnack(errorMessage);
        return false;
      }
    } catch (e) {
      log("SignUp Error: $e", stackTrace: StackTrace.current);
      String errorMessage = 'An error occurred during signup';

      if (e is DioException) {
        log("DioException Details: ${e.toString()}", stackTrace: e.stackTrace);

        // Handle different types of Dio errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage =
                'Connection timeout. Please check your internet connection and try again.';
            break;

          case DioExceptionType.badResponse:
            // Try to extract error message from response
            if (e.response?.data != null) {
              try {
                final responseData = e.response!.data;
                if (responseData is Map<String, dynamic>) {
                  errorMessage =
                      responseData['Message'] ??
                      responseData['message'] ??
                      responseData['error'] ??
                      'Server error occurred';

                  // Check if it's actually a success response disguised as an error
                  if (responseData['IsSuccess'] == true ||
                      responseData['StatusCode'] == 200) {
                    String successMsg =
                        responseData['Data'] ??
                        responseData['Message'] ??
                        'OTP sent successfully';
                    showSuccessSnack(successMsg);
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      NavigationService().pushNavigation(
                        Screenroutes.verifyOtp,
                      );
                    });
                    return true;
                  }
                } else if (responseData is String) {
                  errorMessage = responseData;
                }
              } catch (parseError) {
                log("Error parsing response: $parseError");
                errorMessage =
                    'Server error occurred (${e.response?.statusCode})';
              }
            } else {
              errorMessage =
                  'Server error occurred (${e.response?.statusCode ?? 'Unknown'})';
            }
            break;

          case DioExceptionType.connectionError:
            errorMessage =
                'No internet connection. Please check your network and try again.';
            break;

          case DioExceptionType.badCertificate:
            errorMessage = 'Security certificate error. Please try again.';
            break;

          case DioExceptionType.cancel:
            errorMessage = 'Request was cancelled. Please try again.';
            break;

          default:
            errorMessage =
                e.message ?? 'Network error occurred. Please try again.';
        }
      } else {
        log("Non-Dio Error: $e", stackTrace: StackTrace.current);
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      showErrorSnack(errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      removeCircle();
    }
  }

  // Enhanced OTP verification method
  Future<bool> verifyOtp(String otp, {String? email, String? password}) async {
    _isLoading = true;
    notifyListeners();
    showCircle();

    try {
      // Use provided credentials or stored ones
      final verifyEmail = email ?? _currentEmail ?? '';
      final verifyPassword = password ?? _currentPassword ?? '';

      if (verifyEmail.isEmpty || verifyPassword.isEmpty) {
        showErrorSnack('Session expired. Please signup again.');
        NavigationService().pushNavigation(Screenroutes.signUp);
        return false;
      }

      final verifyResponse = await restApi.verifyOtp(
        email: verifyEmail,
        password: verifyPassword,
        otp: otp,
      );

      log('OTP Verify Response: ${verifyResponse.toString()}');

      // Handle the response as a Map<String, dynamic>
      Map<String, dynamic> responseData;

      if (verifyResponse is Map<String, dynamic>) {
        responseData = verifyResponse;
      } else {
        // If it's a custom object, try to convert it
        responseData = {
          'StatusCode': verifyResponse.StatusCode ?? 0,
          'Message': verifyResponse.Message ?? '',
          'IsSuccess': verifyResponse.IsSuccess ?? false,
          'Data': verifyResponse.Data ?? '',
        };
      }

      bool isSuccess = responseData['IsSuccess'] == true;
      int statusCode = responseData['StatusCode'] ?? 0;

      if (isSuccess && statusCode == 200) {
        // Clear stored user data after successful verification
        clearUserData();

        String successMessage =
            responseData['Message']?.toString() ??
            'User Registered successfully!';
        showSuccessSnack(successMessage);

        // Navigate to login screen
        Future.delayed(const Duration(milliseconds: 1500), () {
          NavigationService().navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(
                Screenroutes.loginScreen,
                (route) => false,
              );
        });

        return true;
      } else {
        String errorMessage =
            responseData['Message']?.toString() ?? 'OTP verification failed';

        // Handle specific OTP verification errors
        switch (statusCode) {
          case 400:
            errorMessage =
                responseData['Message']?.toString() ?? 'Invalid OTP format';
            break;
          case 401:
            errorMessage =
                responseData['Message']?.toString() ?? 'Invalid or expired OTP';
            break;
          case 404:
            errorMessage =
                responseData['Message']?.toString() ?? 'User not found';
            break;
          case 410:
            errorMessage =
                responseData['Message']?.toString() ??
                'OTP has expired. Please request a new one.';
            break;
          default:
            errorMessage =
                responseData['Message']?.toString() ??
                'OTP verification failed';
        }

        showErrorSnack(errorMessage);
        return false;
      }
    } catch (e) {
      log("OTP Verify Error: $e", stackTrace: StackTrace.current);
      String errorMessage = 'An error occurred during OTP verification';

      if (e is DioException) {
        log("DioException Details: ${e.toString()}", stackTrace: e.stackTrace);

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = 'Connection timeout. Please try again.';
            break;

          case DioExceptionType.badResponse:
            if (e.response?.data != null) {
              try {
                final responseData = e.response!.data;
                if (responseData is Map<String, dynamic>) {
                  errorMessage =
                      responseData['Message'] ??
                      responseData['message'] ??
                      responseData['error'] ??
                      'Server error occurred';
                }
              } catch (parseError) {
                errorMessage =
                    'Server error occurred (${e.response?.statusCode})';
              }
            }
            break;

          case DioExceptionType.connectionError:
            errorMessage = 'No internet connection. Please check your network.';
            break;

          default:
            errorMessage = e.message ?? 'Network error occurred';
        }
      }

      showErrorSnack(errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
      removeCircle();
    }
  }

  // Method to resend OTP
  Future<bool> resendOtp() async {
    if (_currentEmail == null || _currentPassword == null) {
      showErrorSnack('Session expired. Please signup again.');
      return false;
    }

    return await signUp(_currentEmail!, _currentPassword!);
  }
}
