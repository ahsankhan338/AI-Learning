import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SearchBar(
              hintText: "Search",
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
              trailing: [Icon(Icons.search)],
            ),
            Text(
              "Home Screen",
              style: TextStyle(fontSize: 35, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
