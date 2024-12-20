import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Congratulations!"),
            subtitle: Text("You have completed Python Basics."),
          ),
          ListTile(
            title: Text("Hurry Up!"),
            subtitle: Text("Your subscription ends soon."),
          ),
        ],
      ),
    );
  }
}
