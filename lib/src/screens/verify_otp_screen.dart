import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sample/src/providers/signup_controller.dart';
import 'package:sample/src/util/app_routes.dart'; // Update with your actual path

class OtpVerificationScreen extends StatefulWidget {
  final String? email;
  final String? password;
  const OtpVerificationScreen({super.key, this.email, this.password});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  String get otpCode =>
      _otpControllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Auto focus on first field with delay to ensure keyboard shows
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        }
      });
    });

    // Add focus listeners to handle backspace
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {}); // Rebuild to update border colors
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index) {
    setState(() {}); // Rebuild to update UI

    String currentText = _otpControllers[index].text;

    // Handle multiple characters pasted
    if (currentText.length > 1) {
      _handlePastedText(currentText, index);
      return;
    }

    // Move to next field if current field is filled
    if (currentText.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when all fields are filled
    if (otpCode.length == 6) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (otpCode.length == 6) {
          // Uncomment when ready to implement verification
          final signUpController = Provider.of<SignUpController>(
            context,
            listen: false,
          );
          _verifyOtp(signUpController);
        }
      });
    }
  }

  void _handlePastedText(String pastedText, int startIndex) {
    // Extract only digits from pasted text
    String digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');

    // Clear current field first
    _otpControllers[startIndex].text = '';

    // Fill the OTP fields with the pasted digits
    for (int i = 0; i < digits.length && (startIndex + i) < 6; i++) {
      _otpControllers[startIndex + i].text = digits[i];
    }

    // Focus on the next empty field or the last field
    int nextFocusIndex = (startIndex + digits.length).clamp(0, 5);
    if (nextFocusIndex < 6 && _otpControllers[nextFocusIndex].text.isEmpty) {
      _focusNodes[nextFocusIndex].requestFocus();
    } else {
      _focusNodes[5].requestFocus();
    }
  }

  void _onKeyPressed(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      // Handle backspace
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_otpControllers[index].text.isEmpty && index > 0) {
          // Move to previous field if current is empty
          _focusNodes[index - 1].requestFocus();
          _otpControllers[index - 1].text = '';
        }
      }
    }
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final signUpController = Provider.of<SignUpController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verify Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter your OTP code below',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 60),

                // OTP Input Fields with better keyboard handling
                GestureDetector(
                  onTap: () {
                    // Find first empty field or focus on first field
                    int emptyIndex = 0;
                    for (int i = 0; i < _otpControllers.length; i++) {
                      if (_otpControllers[i].text.isEmpty) {
                        emptyIndex = i;
                        break;
                      }
                    }
                    FocusScope.of(
                      context,
                    ).requestFocus(_focusNodes[emptyIndex]);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => _buildOtpField(index),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Next Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8BC34A).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed:
                        (signUpController.isLoading || otpCode.length != 6)
                            ? null
                            : () {
                              // Uncomment when ready to implement verification
                              _verifyOtp(signUpController);

                              // For now, just show the entered OTP and dismiss keyboard
                              FocusScope.of(context).unfocus();
                              _showSnackBar(
                                'Entered OTP: $otpCode',
                                isError: false,
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BC34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        signUpController.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 40),

                // Resend Code Section
                Column(
                  children: [
                    Text(
                      "Didn't receive the code ?",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    if (!_canResend) ...[
                      Text(
                        'Resend code in $_timerText',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap:
                            signUpController.isLoading
                                ? null
                                : () {
                                  // Uncomment when ready to implement resend
                                  _resendOtp(signUpController);

                                  // For now, just restart timer, clear fields and focus first field
                                  _startTimer();
                                  _clearOtpFields();
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      if (mounted) {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(_focusNodes[0]);
                                      }
                                    },
                                  );
                                  _showSnackBar(
                                    'New OTP sent!',
                                    isError: false,
                                  );
                                },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8BC34A),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Resend a new code',
                            style: TextStyle(
                              color:
                                  signUpController.isLoading
                                      ? Colors.grey
                                      : const Color(0xFF8BC34A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _focusNodes[index].hasFocus
                  ? const Color(0xFF8BC34A)
                  : _otpControllers[index].text.isNotEmpty
                  ? const Color(0xFF8BC34A)
                  : Colors.grey[300]!,
          width: _focusNodes[index].hasFocus ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          counterText: "",
          hintText: '',
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next field
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              // Last field, remove focus
              _focusNodes[index].unfocus();
            }
          }
          setState(() {}); // Rebuild to update border colors
        },
        onTap: () {
          // Select all text when tapped
          _otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index].text.length,
          );
        },
      ),
    );
  }

  Future<void> _verifyOtp(SignUpController signUpController) async {
    if (otpCode.length != 6) {
      _showSnackBar('Please enter complete OTP code', isError: true);
      return;
    }

    // Use widget email/password or fallback to controller stored values
    final email = signUpController.currentEmail;
    final password = signUpController.currentPassword;

    if (email == null || password == null) {
      _showSnackBar('Session expired. Please signup again.', isError: true);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Screenroutes.signUp, (route) => false);
      return;
    }

    final success = await signUpController.verifyOtp(
      otpCode,
      email: email,
      password: password,
    );

    if (success && mounted) {
      _showSnackBar('OTP verified successfully!', isError: false);
      // Navigation will be handled in the controller
    }
  }

  Future<void> _resendOtp(SignUpController signUpController) async {
    // Use widget email/password or fallback to controller stored values
    final email = widget.email ?? signUpController.currentEmail;
    final password = widget.password ?? signUpController.currentPassword;

    if (email == null || password == null) {
      _showSnackBar('Session expired. Please signup again.', isError: true);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Screenroutes.signUp, (route) => false);
      return;
    }

    // Call signUp again with stored credentials to resend OTP
    final success = await signUpController.signUp(email, password);

    if (success) {
      _startTimer();
      _clearOtpFields();
      _showSnackBar('New OTP sent successfully!', isError: false);
      // Focus on first field after clearing
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        }
      });
    }
  }

  void _clearOtpFields() {
    setState(() {
      for (var controller in _otpControllers) {
        controller.clear();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF8BC34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
