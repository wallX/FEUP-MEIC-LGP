import 'package:flutter/material.dart';

class ErrorDialog {
  /// Shows an error dialog with the provided message.
  /// 
  /// [context] - The BuildContext for showing the dialog <br>
  /// [message] - The error message to display <br>
  /// [title] - Optional title for the error dialog (defaults to 'Error') <br>
  /// [buttonText] - Optional text for the dismiss button (defaults to 'OK') 
  static void show({
    required BuildContext context,
    required String message,
    String title = 'Error',
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }
}