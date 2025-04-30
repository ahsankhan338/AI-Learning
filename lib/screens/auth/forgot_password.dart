import 'package:aieducator/api/auth_api.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/constants/constants.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSending = false;

  final Authentication _authenticationApi = Authentication(); // 👈 Instance

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      showToast(
          message: "Please enter a valid email address",
          backgroundColor: Colors.red);
      return;
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      showToast(
          message: "New password must be at least 6 characters",
          backgroundColor: Colors.red);
      return;
    }

    if (newPassword != confirmPassword) {
      showToast(message: "Passwords do not match", backgroundColor: Colors.red);
      return;
    }

    setState(() => _isSending = true);

    try {
      await _authenticationApi.forgotPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      showToast(message: "Password updated successfully!");

      if (mounted) {
        Navigator.pop(context); // Go back to login
      }
    } catch (e) {
      print(e);
      showToast(
          message: "Error updating password: $e", backgroundColor: Colors.red);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent, // 👈 Must be transparent
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text("Reset Password"),
          ),
          extendBodyBehindAppBar: true, // 🔥 Let gradient go behind appbar too
          body: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                          height: 100), // To shift content below appbar
                      const Text(
                        "Enter your email and new password to reset.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(_emailController, "Email address"),
                      const SizedBox(height: 20),
                      _buildTextField(_newPasswordController, "New password",
                          obscureText: true),
                      const SizedBox(height: 20),
                      _buildTextField(
                          _confirmPasswordController, "Confirm password",
                          obscureText: true),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _handleForgotPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D3CFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isSending)
          const Center(
            child: SpinLoader()
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1A3A6C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
