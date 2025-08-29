import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/connection_channel_action.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';

class WebhookConfigDialog extends StatefulWidget {
  final String? webhookUrl;
  final String? serviceName;
  final DateTime? expirationDate;
  final String? title;
  final List<String> instructions;

  const WebhookConfigDialog({
    Key? key,
    this.webhookUrl,
    this.serviceName = 'FBS',
    this.expirationDate,
    this.title,
    this.instructions = const [],
  }) : super(key: key);

  @override
  State<WebhookConfigDialog> createState() => _WebhookConfigDialogState();
}

class _WebhookConfigDialogState extends State<WebhookConfigDialog> {
  static const List<String> _serviceOptions = ['FBS', 'Khác'];

  late TextEditingController _serviceController;
  late TextEditingController _webhookUrlController;
  late DateTime _selectedDate;
  String? _selectedService;
  bool _isCopied = false;
  bool _showStep2 = false;

  @override
  void initState() {
    super.initState();
    _serviceController =
        TextEditingController(text: widget.serviceName ?? 'FBS');
    _selectedService = _serviceOptions.contains(_serviceController.text)
        ? _serviceController.text
        : _serviceOptions.first;
    _webhookUrlController = TextEditingController(
      text: widget.webhookUrl ??
          'https://tracking.coka.ai/api/v1/webhook/bot?acc=...',
    );
    _selectedDate =
        widget.expirationDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_showStep2) return; // locked on step 2
    final DateTime? picked = await showOneTapDatePicker(
      context,
      initialDate: _selectedDate,
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  void _goNext() {
    if (_selectedService == null || _selectedService!.isEmpty) return;
    context.read<ConnectionChannelBloc>().add(CreateIntegrationEvent(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? '',
          source: _serviceController.text,
          expiryDate: _selectedDate.toIso8601String(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionChannelBloc, ConnectionChannelState>(
      listener: (context, state) {
        if (state.status == ConnectionChannelStatus.createIntegrationSuccess) {
          setState(() {
            _webhookUrlController.text = state.url ?? '';
          });
        }
      },
      child: BlocSelector<ConnectionChannelBloc, ConnectionChannelState,
              ConnectionChannelStatus>(
          selector: (state) => state.status ?? ConnectionChannelStatus.initial,
          builder: (context, status) {
            if (status == ConnectionChannelStatus.createIntegrationSuccess) {
              _showStep2 = true;
            }
            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? 'configure_webhook'.tr(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        _buildServiceField(),
                        const SizedBox(height: 16),
                        _buildExpirationDateField(),
                        if (_showStep2) ...[
                          const SizedBox(height: 16),
                          _buildWebhookUrlField(),
                          const SizedBox(height: 16),
                          _buildCopyActionRow(),
                          const SizedBox(height: 16),
                          _buildInstructions(),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!_showStep2)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _goNext,
                                child: Text('continue'.tr()),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context
                                      .read<ConnectionChannelBloc>()
                                      .add(const CancelBloc());
                                },
                                child: Text('done'.tr()),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _buildServiceField() {
    final bool disabled = _showStep2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'service'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: disabled,
          child: DropdownButtonFormField<String>(
            value: _serviceOptions.contains(_selectedService)
                ? _selectedService
                : null,
            items: _serviceOptions
                .map((s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(s),
                    ))
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _selectedService = val;
                _serviceController.text = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'select_service'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '*${'fbs_description'.tr()}:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationDateField() {
    final bool disabled = _showStep2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'expiration_date'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: disabled ? null : () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.grey[disabled ? 400 : 600], size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: disabled ? Colors.grey[600] : null,
                      ),
                ),
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
          'webhook_url'.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              _webhookUrlController.text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyActionRow() {
    return Row(
      children: [
        const Spacer(),
        TextButton.icon(
          onPressed: _copyToClipboard,
          icon: const Icon(Icons.copy, size: 18),
          label: Text(_isCopied ? 'copied'.tr() : 'copy'.tr()),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    final defaultInstructions = [
      'access_fbs_ai'.tr(),
      'need_to_login_and_choose_package'.tr(),
      'choose_manage_member_group'.tr(),
      'click_webhook'.tr(),
      'paste_webhook_url'.tr(),
      'now_you_can_connect_coka_with_fbs'.tr(),
    ];

    final instructions = widget.instructions.isNotEmpty
        ? widget.instructions
        : defaultInstructions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'use_webhook_coka_on'.tr(args: [_serviceController.text]),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...instructions
            .map((instruction) => _buildInstructionItem(instruction)),
      ],
    );
  }

  Widget _buildInstructionItem(String instruction) {
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
              text: _parseInstructionText(instruction),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _parseInstructionText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final RegExp quotePattern = RegExp(r'\"(.*?)\"');

    String remainingText = text;

    while (remainingText.isNotEmpty) {
      final boldMatch = boldPattern.firstMatch(remainingText);
      final quoteMatch = quotePattern.firstMatch(remainingText);

      if (boldMatch != null &&
          (quoteMatch == null || boldMatch.start < quoteMatch.start)) {
        if (boldMatch.start > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, boldMatch.start),
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ));
        }

        spans.add(TextSpan(
          text: boldMatch.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 14,
          ),
        ));

        remainingText = remainingText.substring(boldMatch.end);
      } else if (quoteMatch != null) {
        if (quoteMatch.start > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, quoteMatch.start),
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ));
        }

        spans.add(TextSpan(
          text: quoteMatch.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 14,
          ),
        ));

        remainingText = remainingText.substring(quoteMatch.end);
      } else {
        spans.add(TextSpan(
          text: remainingText,
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
        ));
        break;
      }
    }

    return TextSpan(children: spans);
  }
}

Future<Map<String, dynamic>?> showWebhookConfigDialog(
  BuildContext context, {
  String? webhookUrl,
  String? serviceName,
  DateTime? expirationDate,
  String? title,
  List<String>? instructions,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => WebhookConfigDialog(
      webhookUrl: webhookUrl,
      serviceName: serviceName,
      expirationDate: expirationDate,
      title: title,
      instructions: instructions ?? [],
    ),
  );
}

Future<DateTime?> showOneTapDatePicker(BuildContext context,
    {required DateTime initialDate}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: SizedBox(
          width: 340,
          height: 360,
          child: CalendarDatePicker(
            initialDate: initialDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              Navigator.of(context).pop(date);
            },
          ),
        ),
      );
    },
  );
}
