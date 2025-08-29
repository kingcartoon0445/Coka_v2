import 'package:flutter/material.dart';
import 'tiktok_webhook_dialog.dart';

class TikTokButton extends StatelessWidget {
  final String? webhookUrl;
  final String? serviceName;
  final DateTime? expirationDate;
  final VoidCallback? onWebhookConfigured;
  final String? buttonText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const TikTokButton({
    Key? key,
    this.webhookUrl,
    this.serviceName,
    this.expirationDate,
    this.onWebhookConfigured,
    this.buttonText,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => _showWebhookDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? const Color(0xFF000000), // TikTok black
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            (icon ?? const Icon(Icons.video_library)) as Widget,
            const SizedBox(width: 8),
            Text(buttonText ?? 'Cấu hình TikTok'),
          ],
        ),
      ),
    );
  }

  Future<void> _showWebhookDialog(BuildContext context) async {
    final result = await showTikTokWebhookDialog(
      context,
      webhookUrl: webhookUrl,
      serviceName: serviceName,
      expirationDate: expirationDate,
    );

    if (result != null && onWebhookConfigured != null) {
      onWebhookConfigured!();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã cấu hình webhook TikTok thành công!'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Xem',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to webhook management page
              },
            ),
          ),
        );
      }
    }
  }
}

// TikTok Icon Button variant
class TikTokIconButton extends StatelessWidget {
  final String? webhookUrl;
  final String? serviceName;
  final DateTime? expirationDate;
  final VoidCallback? onWebhookConfigured;
  final double? size;
  final Color? backgroundColor;
  final Color? iconColor;

  const TikTokIconButton({
    Key? key,
    this.webhookUrl,
    this.serviceName,
    this.expirationDate,
    this.onWebhookConfigured,
    this.size,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 48,
      height: size ?? 48,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF000000),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWebhookDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Icon(
            Icons.video_library,
            color: iconColor ?? Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _showWebhookDialog(BuildContext context) async {
    final result = await showTikTokWebhookDialog(
      context,
      webhookUrl: webhookUrl,
      serviceName: serviceName,
      expirationDate: expirationDate,
    );

    if (result != null && onWebhookConfigured != null) {
      onWebhookConfigured!();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã cấu hình webhook TikTok thành công!'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// TikTok Card variant
class TikTokCard extends StatelessWidget {
  final String? webhookUrl;
  final String? serviceName;
  final DateTime? expirationDate;
  final VoidCallback? onWebhookConfigured;
  final String? title;
  final String? subtitle;
  final bool isConfigured;

  const TikTokCard({
    Key? key,
    this.webhookUrl,
    this.serviceName,
    this.expirationDate,
    this.onWebhookConfigured,
    this.title,
    this.subtitle,
    this.isConfigured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showWebhookDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? 'TikTok Integration',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          subtitle ?? 'Cấu hình webhook để kết nối với TikTok',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (isConfigured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Đã cấu hình',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Nhấn để cấu hình webhook TikTok',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showWebhookDialog(BuildContext context) async {
    final result = await showTikTokWebhookDialog(
      context,
      webhookUrl: webhookUrl,
      serviceName: serviceName,
      expirationDate: expirationDate,
    );

    if (result != null && onWebhookConfigured != null) {
      onWebhookConfigured!();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã cấu hình webhook TikTok thành công!'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
