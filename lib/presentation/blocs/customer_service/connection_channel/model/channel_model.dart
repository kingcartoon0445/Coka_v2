import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum BadgeTone { green, red, gray }

class ConnectionChannelResponse {
  int? code;
  List<Channel>? content;

  ConnectionChannelResponse({this.code, this.content});

  ConnectionChannelResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['content'] != null) {
      content = <Channel>[];
      json['content'].forEach((v) {
        content!.add(new Channel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    if (this.content != null) {
      data['content'] = this.content!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Channel {
  final String id;
  final String title;
  final String provider; // Website | Webhook | FACEBOOK | Tiktok | ...
  final String? connectionState; // "Đang kết nối" | "Mất kết nối" | null
  final String status; // "1" / "0"

  const Channel({
    required this.id,
    required this.title,
    required this.provider,
    required this.status,
    this.connectionState,
  });

  factory Channel.fromJson(Map<String, dynamic> m) => Channel(
        id: m['id'] as String,
        title: (m['title'] ?? '').toString(),
        provider: (m['provider'] ?? '').toString(),
        status: (m['status'] ?? '0').toString(),
        connectionState: m['connectionState']?.toString(),
      );

  bool get isOn => status == '1';
  bool get hasState => connectionState != null;

  String get providerLower => provider.toLowerCase();

  IconData get icon {
    final p = providerLower;
    if (p.contains('website') || p.contains('web')) return Icons.language;
    if (p.contains('facebook')) return Icons.facebook;
    if (p.contains('tiktok')) return Icons.tiktok;
    if (p.contains('webhook')) return Icons.webhook_outlined;
    return Icons.extension;
  }

  // Suy diễn trạng thái nếu API không gửi connectionState
  String get effectiveState =>
      connectionState ??
      (isOn ? 'connecting_status'.tr() : 'lost_connection_status'.tr());

  BadgeTone get badgeTone =>
      effectiveState == 'Đang kết nối' ? BadgeTone.green : BadgeTone.red;
  String get badgeText => effectiveState;

  Channel copyWithStatus(bool on) => Channel(
        id: id,
        title: title,
        provider: provider,
        status: on ? '1' : '0',
        connectionState: connectionState,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['provider'] = provider;
    data['status'] = status;
    data['connectionState'] = connectionState;
    return data;
  }
}
