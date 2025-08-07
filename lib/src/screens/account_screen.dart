// account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add your actual path
import 'package:sample/src/providers/login_controller.dart';
import 'package:sample/src/repo/auth_repo.dart';
import 'package:sample/src/util/app_navigation.dart';
import 'package:sample/src/util/app_routes.dart';
import 'package:sample/src/util/snack.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Account',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: const NetworkImage(''),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AuthRepo.user ?? 'User Name',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AuthRepo.contact ?? 'Contact Number',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Menu Items
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        Icons.person_outline,
                        'About me',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.shopping_bag_outlined,
                        'My Orders',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.favorite_border,
                        'My Favorites',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.location_on_outlined,
                        'My Address',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.credit_card,
                        'Credit Cards',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.account_balance_wallet_outlined,
                        'Transactions',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        Colors.green,
                        () {},
                      ),
                      _buildMenuItem(
                        Icons.logout,
                        'Sign out',
                        Colors.red,
                        () => _showLogoutDialog(context, authController),
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color iconColor,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 80,
            endIndent: 20,
          ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed:
                  authController.isLoading
                      ? null
                      : () async {
                        Navigator.of(context).pop(); // Close dialog first
                        await _handleLogout(context, authController);
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child:
                  authController.isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    AuthController authController,
  ) async {
    try {
      // Call the logout method from AuthController
      bool success = await authController.logout(AuthRepo.loginId);

      if (success) {
        // Navigate to login screen using your NavigationService
        NavigationService().pushNavigation(
          Screenroutes.loginScreen, // Replace with your actual login route
        );

        // Show success message using your existing snack utility
        showSuccessSnack('Successfully signed out');
      } else {
        // Show error message using your existing snack utility
        showErrorSnack('Failed to sign out. Please try again.');
      }
    } catch (e) {
      // Handle any unexpected errors
      showErrorSnack('An error occurred while signing out: ${e.toString()}');
    }
  }
}
