import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class SettingInitialized extends SettingEvent {
  final String organizationId;
  const SettingInitialized({required this.organizationId});
}

class SearchOrganization extends SettingEvent {
  final String searchText;
  final String organizationId;
  const SearchOrganization(
      {required this.searchText, required this.organizationId});
}

class OffBlocSetting extends SettingEvent {}

class JoinOrganization extends SettingEvent {
  final String organizationId;
  final String organizationName;
  const JoinOrganization(
      {required this.organizationId, required this.organizationName});
}

class GetInvitationList extends SettingEvent {
  final String organizationId;
  final String type;
  const GetInvitationList({required this.organizationId, required this.type});
}

class ConfirmInvitation extends SettingEvent {
  final String organizationId;
  final String id;
  final bool isAccept;
  const ConfirmInvitation(
      {required this.organizationId, required this.id, required this.isAccept});
}
