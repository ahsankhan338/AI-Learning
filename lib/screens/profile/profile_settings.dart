import 'package:aieducator/api/user_api.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: "Umair Shahid"); // default (replace later)
  bool _isSaving = false;

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        showToast(message: "Not authenticated", backgroundColor: Colors.red);
        setState(() => _isSaving = false);
        return;
      }

      Provider.of<AuthProvider>(context, listen: false)
          .updateUserNameLocally(_nameController.text.trim());

      final error =
          await UserApi.updateUserName(token, _nameController.text.trim());

      if (error == null) {
        showToast(message: "Name updated successfully!");
        Navigator.pop(context); // ⬅️ Optionally go back after saving
      } else {
        showToast(message: error, backgroundColor: Colors.red);
      }
    } catch (e) {
      showToast(
          message: "Error updating name: $e", backgroundColor: Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text(
            "Full Name",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0E2C56),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: "Enter your name",
              hintStyle: const TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveName,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D3CFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Changes",
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
    );
  }
}
