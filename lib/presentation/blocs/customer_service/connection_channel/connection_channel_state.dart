import 'package:equatable/equatable.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/model/channel_model.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/model/tiktok_configuration_response.dart';

import 'model/account_tiktok_model.dart';
import 'model/form_account_tiktok_reponse.dart';

enum ConnectionChannelStatus {
  //default
  initial,
  loading,
  success,
  error,
  //create web form
  createWebFormLoading,
  createWebFormSuccess,
  createWebFormError,
  //verify web form
  verifyWebFormLoading,
  verifyWebFormSuccess,
  verifyWebFormError,
  //connect channel
  connectChannelLoading,
  connectChannelSuccess,
  connectChannelError,
  //disconnect channel
  disconnectChannelLoading,
  disconnectChannelSuccess,
  disconnectChannelError,
  //create integration
  createIntegrationLoading,
  createIntegrationSuccess,
  createIntegrationError,
  //get tiktok lead connections
  getTiktokLeadConnectionsLoading,
  getTiktokLeadConnectionsSuccess,
  getTiktokLeadConnectionsError,
  //get tiktok item list
  getTiktokItemListLoading,
  getTiktokItemListSuccess,
  getTiktokItemListError,
  //get tiktok configuration
  getTiktokConfigurationLoading,
  getTiktokConfigurationSuccess,
  getTiktokConfigurationError,
}

class ConnectionChannelState extends Equatable {
  final List<Channel>? channels;
  final ConnectionChannelStatus? status;
  final List<AccountTiktokModel>? accountTiktok;
  final List<FormAccountTiktokModel>? formAccountTiktok;
  final String? idChannel;
  final String? url;
  final String? organizationId;
  final String? errorMessage;
  final TiktokConfigurationModel? tiktokConfiguration;
  const ConnectionChannelState({
    this.channels,
    this.status,
    this.accountTiktok,
    this.formAccountTiktok,
    this.idChannel,
    this.url,
    this.organizationId,
    this.errorMessage,
    this.tiktokConfiguration,
  });

  ConnectionChannelState copyWith({
    bool? isCancel,
    List<Channel>? channels,
    ConnectionChannelStatus? status,
    List<AccountTiktokModel>? accountTiktok,
    List<FormAccountTiktokModel>? formAccountTiktok,
    String? url,
    String? idChannel,
    String? organizationId,
    String? errorMessage,
    TiktokConfigurationModel? tiktokConfiguration,
  }) {
    return ConnectionChannelState(
      channels: isCancel ?? false ? null : channels ?? this.channels,
      accountTiktok:
          isCancel ?? false ? null : accountTiktok ?? this.accountTiktok,
      formAccountTiktok: isCancel ?? false
          ? null
          : formAccountTiktok ?? this.formAccountTiktok,
      status: isCancel ?? false
          ? ConnectionChannelStatus.initial
          : status ?? this.status,
      idChannel: isCancel ?? false ? null : idChannel ?? this.idChannel,
      url: isCancel ?? false ? null : url ?? this.url,
      organizationId:
          isCancel ?? false ? null : organizationId ?? this.organizationId,
      errorMessage:
          isCancel ?? false ? null : errorMessage ?? this.errorMessage,
      tiktokConfiguration: isCancel ?? false
          ? null
          : tiktokConfiguration ?? this.tiktokConfiguration,
    );
  }

  @override
  List<Object?> get props => [
        channels,
        status,
        idChannel,
        url,
        organizationId,
        errorMessage,
        tiktokConfiguration,
      ];
}
