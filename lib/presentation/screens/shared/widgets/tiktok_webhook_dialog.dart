import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class TikTokWebhookDialog extends StatefulWidget {
  final String? webhookUrl;
  final String? serviceName;
  final DateTime? expirationDate;

  const TikTokWebhookDialog({
    Key? key,
    this.webhookUrl,
    this.serviceName = 'TikTok',
    this.expirationDate,
  }) : super(key: key);

  @override
  State<TikTokWebhookDialog> createState() => _TikTokWebhookDialogState();
}

class _TikTokWebhookDialogState extends State<TikTokWebhookDialog> {
  late TextEditingController _serviceController;
  late TextEditingController _webhookUrlController;
  late DateTime _selectedDate;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _serviceController =
        TextEditingController(text: widget.serviceName ?? 'TikTok');
    _webhookUrlController = TextEditingController(
      text: widget.webhookUrl ??
          'https://tracking.coka.ai/api/v1/webhook/tiktok?acc=...',
    );
    _selectedDate =
        widget.expirationDate ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _webhookUrlController.text));
    setState(() {
      _isCopied = true;
    });

    // Reset copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép Webhook URL'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cấu hình Webhook TikTok',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildServiceField(),
            const SizedBox(height: 16),
            _buildExpirationDateField(),
            const SizedBox(height: 16),
            _buildWebhookUrlField(),
            const SizedBox(height: 24),

            // Instructions
            _buildInstructions(),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save functionality
                    Navigator.of(context).pop({
                      'service': _serviceController.text,
                      'expirationDate': _selectedDate,
                      'webhookUrl': _webhookUrlController.text,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dịch vụ *',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _serviceController,
          decoration: InputDecoration(
            hintText: 'Chọn dịch vụ',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          readOnly: true,
          onTap: () {
            // TODO: Show service selection dialog
          },
        ),
      ],
    );
  }

  Widget _buildExpirationDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày hết hạn *',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebhookUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Webhook Url',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _webhookUrlController.text,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _copyToClipboard,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _isCopied ? Colors.green : Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _isCopied ? Icons.check : Icons.copy,
                    size: 16,
                    color: _isCopied ? Colors.white : Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Sao chép',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sử dụng Webhook Coka trên TikTok:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildInstructionItem(
          'Truy cập vào địa chỉ ',
          'TIKTOK.COM',
          ' và đăng nhập vào tài khoản Business',
        ),
        _buildInstructionItem(
          'Vào phần ',
          '"Cài đặt tài khoản"',
          ' và chọn "Tích hợp"',
        ),
        _buildInstructionItem(
          'Tìm mục ',
          '"Webhook"',
          ' và nhấn "Thêm webhook mới"',
        ),
        _buildInstructionItem(
          'Dán ',
          '"Webhook Url"',
          ' phía trên vào trường URL',
        ),
        _buildInstructionItem(
          'Chọn các sự kiện cần theo dõi và nhấn ',
          '"Lưu"',
          '',
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border.all(color: Colors.green[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Giờ đây bạn đã có thể kết nối Coka với TikTok, chúc bạn thành công!',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String prefix, String highlight, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                children: [
                  TextSpan(text: prefix),
                  TextSpan(
                    text: highlight,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  TextSpan(text: suffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog
Future<Map<String, dynamic>?> showTikTokWebhookDialog(
  BuildContext context, {
  String? webhookUrl,
  String? serviceName,
  DateTime? expirationDate,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => TikTokWebhookDialog(
      webhookUrl: webhookUrl,
      serviceName: serviceName,
      expirationDate: expirationDate,
    ),
  );
}
