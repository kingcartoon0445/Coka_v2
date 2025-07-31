import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  /// Nội dung thông báo lỗi
  final String message;

  /// Icon hiển thị (mặc định là lỗi)
  final IconData icon;

  /// Màu sắc cho icon và text (mặc định là đỏ)
  final Color color;

  /// Callback khi người dùng nhấn nút retry (nếu cần)
  final VoidCallback? onRetry;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
    this.icon = Icons.error_outline,
    this.color = Colors.red,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(
            message,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: color, // nút cùng tông màu
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
