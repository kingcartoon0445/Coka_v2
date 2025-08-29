import 'package:equatable/equatable.dart';

abstract class ConnectionChannelEvent extends Equatable {
  const ConnectionChannelEvent();

  @override
  List<Object?> get props => [];
}

class GetChannelListEvent extends ConnectionChannelEvent {
  final String organizationId;

  const GetChannelListEvent({required this.organizationId});
}

class CreateWebFormEvent extends ConnectionChannelEvent {
  final String url;

  const CreateWebFormEvent({
    required this.url,
  });
}

class VerifyWebFormEvent extends ConnectionChannelEvent {
  final String id;

  const VerifyWebFormEvent({required this.id});
}

class ConnectChannelEvent extends ConnectionChannelEvent {
  final String id;
  final int status;
  final String provider;

  const ConnectChannelEvent(
      {required this.id, required this.status, required this.provider});
}

class DisconnectChannelEvent extends ConnectionChannelEvent {
  final String id;
  final String provider;

  const DisconnectChannelEvent({required this.id, required this.provider});
}

class CreateIntegrationEvent extends ConnectionChannelEvent {
  final String organizationId;
  final String source;
  final String expiryDate;

  const CreateIntegrationEvent(
      {required this.organizationId,
      required this.source,
      required this.expiryDate});
}

class CancelBloc extends ConnectionChannelEvent {
  const CancelBloc();
}

class PushTiktokLeadLoginEvent extends ConnectionChannelEvent {
  final String organizationId;
  final String accessToken;

  const PushTiktokLeadLoginEvent(
      {required this.organizationId, required this.accessToken});
}

class GetTiktokLeadConnectionsEvent extends ConnectionChannelEvent {
  final String organizationId;

  const GetTiktokLeadConnectionsEvent({required this.organizationId});
}

class GetTiktokItemListEvent extends ConnectionChannelEvent {
  final String organizationId;
  final String subscribedId;
  final String isConnect;

  const GetTiktokItemListEvent(
      {required this.organizationId,
      required this.subscribedId,
      required this.isConnect});
}

class GetTiktokConfigurationEvent extends ConnectionChannelEvent {
  final String organizationId;
  final String connectionId;
  final String pageId;

  const GetTiktokConfigurationEvent(
      {required this.organizationId,
      required this.connectionId,
      required this.pageId});
}
