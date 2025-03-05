import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/constants/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MapErrorDialog extends StatefulWidget {
  const MapErrorDialog({Key? key}) : super(key: key);

  @override
  State<MapErrorDialog> createState() => _MapErrorDialogState();
}

class _MapErrorDialogState extends State<MapErrorDialog> {
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    // After 3 seconds, update the modal to show the error message.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundGradient.colors[1],
      content: SizedBox(
        height: 80,
        child: Center(
          child: _showError
              ? const Text(
                  "Could not open map",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                )
              : const SpinLoader(),
        ),
      ),
      actions: _showError
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ]
          : null,
    );
  }
}
