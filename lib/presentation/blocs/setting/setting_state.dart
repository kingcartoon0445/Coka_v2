import 'package:equatable/equatable.dart';
import 'package:source_base/presentation/blocs/setting/model/Invitation_list_response.dart';
import 'package:source_base/presentation/blocs/setting/model/organization_search_repsonse.dart';

enum SettingStatus {
  initial,
  loading,
  success,
  error,
  successJoin,
  errorJoin,
  successGetInvitationList,
  errorGetInvitationList,
  successConfirmInvitation,
  errorConfirmInvitation
}

class SettingState extends Equatable {
  final String? organizationName;
  final SettingStatus status;
  final String? error;
  final List<OrganizationSearchModel>? organizations;
  final String? organizationId;
  final List<InvitationListModel>? invitations;
  const SettingState({
    this.organizationName,
    this.status = SettingStatus.initial,
    this.error,
    this.organizations,
    this.organizationId,
    this.invitations,
  });

  @override
  List<Object?> get props => [status, error, organizationName];

  SettingState copyWith({
    bool isDelete = false,
    String? organizationName,
    SettingStatus? status,
    String? error,
    List<OrganizationSearchModel>? organizations,
    String? organizationId,
    List<InvitationListModel>? invitations,
  }) {
    return SettingState(
      organizationName:
          isDelete ? null : organizationName ?? this.organizationName,
      status: status ?? this.status,
      error: error ?? this.error,
      organizations: isDelete ? null : organizations ?? this.organizations,
      organizationId: isDelete ? null : organizationId ?? this.organizationId,
      invitations: isDelete ? null : invitations ?? this.invitations,
    );
  }
}
