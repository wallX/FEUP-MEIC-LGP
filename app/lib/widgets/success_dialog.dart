import 'package:flutter/material.dart';

class SuccessDialog {
  /// Shows a success dialog with the provided message.
  /// 
  /// [context] - The BuildContext for showing the dialog <br>
  /// [message] - The success message to display <br>
  /// [title] - Optional title for the dialog (defaults to 'Success') <br>
  /// [buttonText] - Optional text for the dismiss button (defaults to 'OK')
  /// [onPressed] - Optional callback when button is pressed
  static void show({
    required BuildContext context,
    required String message,
    String title = 'Success',
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}

