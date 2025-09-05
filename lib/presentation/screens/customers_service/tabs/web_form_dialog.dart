import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart'; 
import 'package:source_base/presentation/blocs/customer_service/connection_channel/connection_channel_action.dart'; 

class WebFormDialog extends StatefulWidget {
  final bool showStep2;
  final String? id;
  final String? title;
  const WebFormDialog({
    super.key,
    this.showStep2 = false,
    this.id,
    this.title,
  });

  @override
  State<WebFormDialog> createState() => _WebFormDialogState();
}

class _WebFormDialogState extends State<WebFormDialog> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _showStep2 = false;
  bool _copied = false;
  String? _id;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.showStep2) {
      String url = widget.title ?? "";
      if (url.startsWith("https://")) {
        url = url.substring(8);
      }
      _urlController.text = url;
      _id = widget.id;
      setState(() => _showStep2 = true);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String get _generatedSnippet {
    // In a real app, token/content can be returned from API. For now, static placeholder.
    final token = _urlController.text;
    return '''
<meta name="coka-site-verification" content="$token">
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start': new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0], j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src='https://www.googletagmanager.com/gtm.js?id=GTM-NM778J2'+dl;f.parentNode!.insertBefore(j,f);})(window,document,'script','dataLayer','GTM-NM778J2');</script>
''';
  }

  void _goNext(String url) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ConnectionChannelBloc>().add(CreateWebFormEvent(
            url: url,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionChannelBloc, ConnectionChannelState>(
      listener: (context, state) {
        if (state.status == ConnectionChannelStatus.createWebFormSuccess) {
          setState(() {
            _showStep2 = true;
            _errorMessage = null;
            _id = state.idChannel;
          });
        }
        if (state.status == ConnectionChannelStatus.createWebFormError) {
          setState(() => _errorMessage = state.errorMessage);
        }
        if (state.status == ConnectionChannelStatus.verifyWebFormSuccess) {
          setState(() {
            _showStep2 = false;
            _errorMessage = null;
          });
        }
        if (state.status == ConnectionChannelStatus.verifyWebFormError) {
          setState(() => _errorMessage = state.errorMessage);
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _showStep2 ? _buildStep2(context) : _buildStep1(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('configure_web_form'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'website_url'.tr(),
              hintText: 'enter_website_url'.tr(),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'please_enter_website_url'.tr();
              final url = v.trim();
              final uri = Uri.tryParse(url);

              // if (uri == null ||
              //     (!uri.hasScheme ||
              //         !(uri.scheme == 'http' || uri.scheme == 'https'))) {
              //   return 'URL không hợp lệ. Ví dụ: https://example.com';
              // }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('close'.tr()),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _goNext(_urlController.text),
              child: Text('next'.tr()),
            )
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Center(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('configure_web_form'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text('copy_script'.tr()),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SelectableText(
              _generatedSnippet,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: _generatedSnippet));
                setState(() => _copied = true);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _copied = false);
                });
              },
              icon: const Icon(Icons.copy, size: 18),
              label: Text(_copied ? 'copied'.tr() : 'copy'.tr()),
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                // foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
              ),
              onPressed: () {
                if (widget.showStep2 == true) {
                  Navigator.of(context).pop();
                } else {
                  //set error

                  setState(() => _showStep2 = false);
                }
              },
              child: Text('back'.tr()),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Placeholder for verify action
                context.read<ConnectionChannelBloc>().add(VerifyWebFormEvent(
                      id: _id ?? '',
                    ));
                // if (emit.isDone) return;
              },
              child: Text('verify'.tr()),
            ),
          ],
        )
      ],
    );
  }
}
