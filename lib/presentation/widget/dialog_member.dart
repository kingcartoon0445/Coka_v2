import 'package:flutter/material.dart';

enum NotifyType { success, error }

Future<T?> ShowdialogNouti<T>(
  BuildContext context, {
  required NotifyType type,
  String title = '',
  String message = '',
  String actionText = 'OK',
  VoidCallback? onAction,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) {
      if (type == NotifyType.success) {
        return UploadCompleteDialog(
          title: title.isEmpty ? 'Upload complete' : title,
          message: message.isEmpty
              ? 'Congrats! Your upload successfully done'
              : message,
          actionText: actionText,
          onAction: onAction,
        );
      }
      return UploadErrorDialog(
        title: title.isEmpty ? 'Upload error' : title,
        message: message.isEmpty ? 'Sorry! Something went wrong' : message,
        actionText: actionText.isEmpty ? 'Try again' : actionText,
        onAction: onAction,
      );
    },
  );
}

/// ---- Dialogs nhận text từ ngoài vào ----

class UploadCompleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;
  final VoidCallback? onAction;

  const UploadCompleteDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionText = 'OK',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onAction?.call();
              },
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;
  final VoidCallback? onAction;

  const UploadErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actionText = 'Try again',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 48),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onAction?.call();
              },
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
