import 'package:flutter/material.dart';

class Confirmation {
  static Future<void> showConfirmationDialog(BuildContext context,
      {String title = 'Confirm Action',
      String message = 'Are you sure you want to perform this action?',
      VoidCallback? callbackOnConfirm,
      VoidCallback? callbackOnCancel}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Dialog is not dismissible by clicking outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                if (callbackOnCancel != null) callbackOnCancel();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                callbackOnConfirm!();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
