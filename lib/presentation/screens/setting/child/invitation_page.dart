import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/setting/model/Invitation_list_response.dart';
import 'package:source_base/presentation/blocs/setting/setting_action.dart';
import 'package:source_base/presentation/screens/setting/widget/profile_invite_item.dart';
import 'package:source_base/presentation/widget/loading_indicator.dart';

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key});

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage>
    with SingleTickerProviderStateMixin {
  List<InvitationListModel> invList = [];
  bool isFetching = false;
  late TabController _tabController;
  String _currentType = 'INVITE'; // Theo dõi loại hiện tại

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    fetchInviteList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentType = _tabController.index == 0 ? 'INVITE' : 'REQUEST';
      });
      fetchInviteList();
    }
  }

  Future fetchInviteList() async {
    context.read<SettingBloc>().add(GetInvitationList(
          organizationId:
              context.read<OrganizationBloc>().state.organizationId ?? '',
          type: _currentType,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lời mời",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2329)),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              child: Text("Đã nhận",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            Tab(
              child: Text("Đã gửi",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      body: isFetching
          ? const Center(child: LoadingIndicator())
          : BlocConsumer<SettingBloc, SettingState>(listener: (context, state) {
              // if (state.status == SettingStatus.successGetInvitationList) {}
            }, builder: (context, state) {
              invList = state.invitations ?? [];
              return TabBarView(
                controller: _tabController,
                children: [
                  // Tab Đã nhận - INVITE
                  RefreshIndicator(
                    onRefresh: () async {
                      await fetchInviteList();
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 120,
                      ),
                      child: _currentType == 'INVITE'
                          ? InviteList(
                              invitedList: invList,
                              onReload: () {
                                fetchInviteList();
                              },
                            )
                          : const Center(child: LoadingIndicator()),
                    ),
                  ),
                  // Tab Đã gửi - REQUEST
                  RefreshIndicator(
                    onRefresh: () async {
                      await fetchInviteList();
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 120,
                      ),
                      child: _currentType == 'REQUEST'
                          ? RequestList(
                              requestList: invList,
                              onReload: () {
                                fetchInviteList();
                              },
                            )
                          : const Center(child: LoadingIndicator()),
                    ),
                  )
                ],
              );
            }),
    );
  }
}

class InviteList extends StatelessWidget {
  final List<InvitationListModel> invitedList;
  final Function onReload;
  const InviteList(
      {super.key, required this.invitedList, required this.onReload});

  @override
  Widget build(BuildContext context) {
    if (invitedList.isEmpty) {
      return const Center(
        child: Text("Không có lời mời nào"),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return ProfileInviteItem(
          dataItem: invitedList[index],
          onReload: onReload,
        );
      },
      itemCount: invitedList.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16),
    );
  }
}

class RequestList extends StatelessWidget {
  final List<InvitationListModel> requestList;
  final Function onReload;
  const RequestList(
      {super.key, required this.requestList, required this.onReload});

  @override
  Widget build(BuildContext context) {
    if (requestList.isEmpty) {
      return const Center(
        child: Text("Không có yêu cầu nào"),
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        return ProfileRequestItem(
          dataItem: requestList[index],
          onReload: onReload,
        );
      },
      itemCount: requestList.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 16),
    );
  }
}
