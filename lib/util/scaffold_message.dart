import 'package:flutter/material.dart';

enum MessageTypes { error, success, info }

class ScaffoldMessage {
  BuildContext context;
  ScaffoldMessage(this.context);
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showScaffoldMessage(
      String message,
      {MessageTypes type = MessageTypes.info,
      Duration duration = const Duration(seconds: 3)}) {
    Color textColor;
    Color backgroundColor;

    switch (type) {
      case MessageTypes.success:
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        break;
      case MessageTypes.info:
        textColor = Theme.of(context).colorScheme.onSecondaryContainer;
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        break;
      case MessageTypes.error:
        textColor = Colors.black;
        backgroundColor = Colors.red[200]!;
        break;
      default:
        textColor = Colors.black;
        backgroundColor = Colors.white;
    }

    var loadingController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message, style: TextStyle(color: textColor))),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );

    return loadingController;
  }
}
