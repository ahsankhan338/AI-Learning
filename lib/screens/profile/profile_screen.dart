import 'package:aieducator/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(listen: false,context).logout();
            },
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 35),
            ),
          )
        ],
      ),
    );
  }
}
