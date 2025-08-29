import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/helper.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/customers_service/tabs/web_form_dialog.dart';
import 'package:source_base/presentation/screens/shared/widgets/webhook_config_dialog.dart';
import '../../../blocs/customer_service/connection_channel/connection_channel_action.dart';

/// DÙNG NGAY:
/// runApp(MaterialApp(
///   theme: ThemeData(useMaterial3: true),
///   home: ConnectionChannelsScreen(
///     data: jsonDecode(sampleJson) as Map<String, dynamic>, // hoặc map từ API của bạn
///   ),
/// ));
///
/// Hoặc nếu đã có Map từ API:
/// ConnectionChannelsScreen(data: yourMap)

class ConnectionChannelScreen extends StatefulWidget {
  const ConnectionChannelScreen({
    super.key,
  });

  @override
  State<ConnectionChannelScreen> createState() =>
      _ConnectionChannelScreenState();
}

class _ConnectionChannelScreenState extends State<ConnectionChannelScreen> {
  @override
  void initState() {
    context.read<ConnectionChannelBloc>().add(GetChannelListEvent(
        organizationId:
            context.read<OrganizationBloc>().state.organizationId ?? ""));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ConnectionChannelBloc, ConnectionChannelState>(
        listener: (context, state) {
      if (state.status == ConnectionChannelStatus.createWebFormSuccess) {
        context.read<ConnectionChannelBloc>().add(GetChannelListEvent(
            organizationId:
                context.read<OrganizationBloc>().state.organizationId ?? ""));
      }

      if (state.status == ConnectionChannelStatus.createWebFormError) {
        Helpers.showSnackBar(context, state.errorMessage ?? "Lỗi");
      }
    }, builder: (context, state) {
      List<Channel> _channels = state.channels ?? [];
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _channels.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == _channels.length) {
              return const _Hint();
            }
            final ch = _channels[index];
            final ui = _tileFor(ch);

            return _SwitchCard(
              channel: ch,
              icon: ui.icon,
              title: ui.title,
              subtitle: ui.subtitle,
              value: ch.isOn,
              onChanged: (v) {
                setState(() {
                  _channels[index] = ch.copyWithStatus(v);
                });
                context.read<ConnectionChannelBloc>().add(ConnectChannelEvent(
                    id: ch.id, status: v ? 1 : 0, provider: ch.provider));
              },
              showStatusBadge: ch.hasState,
              badgeTone: ch.badgeTone,
              badgeText: ch.badgeText,
            );
          },
        ),
      );
    });
  }

  _Tile _tileFor(Channel ch) {
    String title;
    String? subtitle;
    switch (ch.providerLower) {
      case 'website':
        title = 'Web Form';
        subtitle = ch.title; // URL
        break;
      case 'facebook':
        title = 'Facebook Form';
        subtitle = ch.title; // Lead Form
        break;
      case 'tiktok':
        title = ch.title;
        subtitle = ch.title; // giống thiết kế
        break;
      default:
        title = ch.title; // Webhook/khác
        subtitle = ch.provider;
    }
    return _Tile(icon: ch.icon, title: title, subtitle: subtitle);
  }
}

class _Tile {
  final IconData icon;
  final String title;
  final String? subtitle;
  _Tile({required this.icon, required this.title, this.subtitle});
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.channel,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.showStatusBadge = false,
    this.badgeTone = BadgeTone.green,
    this.badgeText = 'connecting',
  });
  final Channel channel;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showStatusBadge;
  final BadgeTone badgeTone;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleColor = theme.colorScheme.outline;

    return InkWell(
      onTap: () {
        if (channel.provider == "Website") {
          showDialog(
            context: context,
            builder: (_) => WebFormDialog(
              showStep2: true,
              id: channel.id,
              title: channel.title,
            ),
          );
        }
        if (channel.provider == "Webhook") {
          showDialog(
            context: context,
            builder: (_) =>  WebhookConfigDialog(
              title: channel.title,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[500]!),
        ),
        // elevation: 1,
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment,
          children: [
            // icon
            Container(
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon,
                  color: channel.provider != "Tiktok"
                      ? const Color(0xFF463BE8)
                      : Colors.black),
            ),

            const SizedBox(width: 12),

            // text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // subtitle co dãn, tránh bể size
                        Expanded(
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        if (showStatusBadge) ...[
                          StatusBadge(label: badgeText, tone: badgeTone),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),
            Column(
              children: [
                Transform.scale(
                  scale: 0.7,
                  transformHitTests: false, // giữ hitbox như cũ
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    inactiveThumbColor: Colors.white,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                    activeColor: AppColors.primary,
                    inactiveTrackColor: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final shouldDisconnect = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'confirm_disconnect'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'confirm_disconnect_content'
                                .tr(args: [title ?? '']),
                            style: const TextStyle(color: Colors.black54),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('cancel'.tr()),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('continue'.tr()),
                            ),
                          ],
                        );
                      },
                    );
                    if (shouldDisconnect == true) {
                      context.read<ConnectionChannelBloc>().add(
                          DisconnectChannelEvent(
                              id: channel.id, provider: channel.provider));
                    }
                  },
                  child: Icon(Icons.link_off, size: 20, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(
      {super.key, required this.label, this.tone = BadgeTone.green});
  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BadgeTone.green => (
          const Color(0xFFE6F5EC),
          const Color.fromARGB(255, 9, 146, 80)
        ),
      BadgeTone.red => (
          const Color(0xFFFDE7EA),
          const Color.fromARGB(255, 193, 49, 66)
        ),
      BadgeTone.gray => (const Color(0xFFF2F3F5), const Color(0xFF49515A)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.link, size: 16, color: Colors.grey),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'hint_connection_channel'.tr(),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
