import 'package:flutter/material.dart';
import 'webhook_config_dialog.dart';

class WebhookButton extends StatelessWidget {
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
  final String? title;
  final List<String>? instructions;

  const WebhookButton({
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
    this.title,
    this.instructions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => _showWebhookDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            (icon ?? const Icon(Icons.webhook)) as Widget,
            const SizedBox(width: 8),
            Text(buttonText ?? 'Cấu hình Webhook'),
          ],
        ),
      ),
    );
  }

  Future<void> _showWebhookDialog(BuildContext context) async {
    final result = await showWebhookConfigDialog(
      context,
      webhookUrl: webhookUrl,
      serviceName: serviceName,
      expirationDate: expirationDate,
      title: title,
      instructions: instructions,
    );

    if (result != null && onWebhookConfigured != null) {
      onWebhookConfigured!();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã cấu hình webhook thành công!'),
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

// FBS specific button
class FBSWebhookButton extends StatelessWidget {
  final String? webhookUrl;
  final DateTime? expirationDate;
  final VoidCallback? onWebhookConfigured;

  const FBSWebhookButton({
    Key? key,
    this.webhookUrl,
    this.expirationDate,
    this.onWebhookConfigured,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebhookButton(
      webhookUrl: webhookUrl,
      serviceName: 'FBS',
      expirationDate: expirationDate,
      onWebhookConfigured: onWebhookConfigured,
      buttonText: 'Cấu hình FBS Webhook',
      icon: Icons.psychology,
      backgroundColor: const Color(0xFF1976D2),
      instructions: [
        'Truy cập vào địa chỉ **FBS.AI**',
        'Bạn cần đăng nhập và chọn mua gói dịch vụ phù hợp với nhu cầu.',
        'Chọn "Quản lý thành viên nhóm"',
        'Nhấn vào mục "Webhook"',
        'Dán "Webhook Url" phía trên',
        'Giờ đây bạn đã có thể kết nối Coka với FBS, chúc bạn thành công.',
      ],
    );
  }
}

// TikTok specific button
class TikTokWebhookButton extends StatelessWidget {
  final String? webhookUrl;
  final DateTime? expirationDate;
  final VoidCallback? onWebhookConfigured;

  const TikTokWebhookButton({
    Key? key,
    this.webhookUrl,
    this.expirationDate,
    this.onWebhookConfigured,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebhookButton(
      webhookUrl: webhookUrl,
      serviceName: 'TikTok',
      expirationDate: expirationDate,
      onWebhookConfigured: onWebhookConfigured,
      buttonText: 'Cấu hình TikTok Webhook',
      icon: Icons.video_library,
      backgroundColor: const Color(0xFF000000),
      instructions: [
        'Truy cập vào địa chỉ **TIKTOK.COM** và đăng nhập vào tài khoản Business',
        'Vào phần "Cài đặt tài khoản" và chọn "Tích hợp"',
        'Tìm mục "Webhook" và nhấn "Thêm webhook mới"',
        'Dán "Webhook Url" phía trên vào trường URL',
        'Chọn các sự kiện cần theo dõi và nhấn "Lưu"',
        'Giờ đây bạn đã có thể kết nối Coka với TikTok, chúc bạn thành công!',
      ],
    );
  }
}

// Facebook specific button
class FacebookWebhookButton extends StatelessWidget {
  final String? webhookUrl;
  final DateTime? expirationDate;
  final VoidCallback? onWebhookConfigured;

  const FacebookWebhookButton({
    Key? key,
    this.webhookUrl,
    this.expirationDate,
    this.onWebhookConfigured,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebhookButton(
      webhookUrl: webhookUrl,
      serviceName: 'Facebook',
      expirationDate: expirationDate,
      onWebhookConfigured: onWebhookConfigured,
      buttonText: 'Cấu hình Facebook Webhook',
      icon: Icons.facebook,
      backgroundColor: const Color(0xFF1877F2),
      instructions: [
        'Truy cập vào **Facebook Developers**',
        'Tạo ứng dụng mới hoặc chọn ứng dụng hiện có',
        'Vào phần "Webhooks" trong menu bên trái',
        'Nhấn "Add Callback URL"',
        'Dán "Webhook Url" phía trên vào trường Callback URL',
        'Chọn các sự kiện cần theo dõi và nhấn "Verify and Save"',
        'Giờ đây bạn đã có thể kết nối Coka với Facebook, chúc bạn thành công!',
      ],
    );
  }
}
