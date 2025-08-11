import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/data/models/member_response.dart';
import 'dart:async';

import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/skeleton_widget.dart';

import '../../../blocs/filter_item/filter_item_aciton.dart';

class AssigneeSelectionDialog extends StatefulWidget {
  final String organizationId;
  final List<MemberModel> initialValue;

  const AssigneeSelectionDialog({
    super.key,
    required this.organizationId,
    required this.initialValue,
  });

  static Future<List<MemberModel>?> show(
    BuildContext context,
    String organizationId,
    List<MemberModel> initialValue,
  ) {
    return showDialog<List<MemberModel>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AssigneeSelectionDialog(
        organizationId: organizationId,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<AssigneeSelectionDialog> createState() =>
      _AssigneeSelectionDialogState();
}

class _AssigneeSelectionDialogState extends State<AssigneeSelectionDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _memberSearchController = TextEditingController();
  final TextEditingController _teamSearchController = TextEditingController();
  List<MemberModel> _selectedAssignees = [];
  List<MemberModel> _members = [];
  List<MemberModel> _teams = [];
  bool _isLoadingMembers = true;
  bool _isLoadingTeams = true;
  String _memberSearchText = '';
  String _teamSearchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedAssignees = List.from(widget.initialValue);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memberSearchController.dispose();
    _teamSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadMembers(),
      _loadTeams(),
    ]);
  }

  Future<void> _loadMembers() async {
    try {
      // Load members using FilterItemBloc
      context.read<FilterItemBloc>().add(LoadFilterItem(
            organizationId: widget.organizationId,
          ));
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Có lỗi xảy ra khi tải danh sách thành viên')),
        );
      }
    }
  }

  Future<void> _loadTeams() async {
    try {
      // For now, we'll use the same members data for teams
      // In a real implementation, you would call a separate API for teams
      setState(() {
        _isLoadingTeams = false;
        _teams = []; // Initialize empty teams list
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTeams = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi tải danh sách đội')),
        );
      }
    }
  }

  void _toggleAssignee(MemberModel assignee) {
    setState(() {
      if (_selectedAssignees
          .any((item) => item.profileId == assignee.profileId)) {
        _selectedAssignees
            .removeWhere((item) => item.profileId == assignee.profileId);
      } else {
        _selectedAssignees.add(assignee);
      }
    });
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 44,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          constraints: const BoxConstraints(maxHeight: 40),
          hintText: 'Tìm kiếm',
          hintStyle: const TextStyle(fontSize: 14),
          prefixIconConstraints: const BoxConstraints(maxHeight: 40),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, size: 20),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListItem(MemberModel assignee) {
    final isSelected =
        _selectedAssignees.any((item) => item.profileId == assignee.profileId);
    return ListTile(
      leading: AppAvatar(
        size: 40,
        shape: AvatarShape.circle,
        imageUrl: assignee.avatar,
        fallbackText: assignee.fullName,
      ),
      title: Text(
        assignee.fullName ?? '',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF101828),
        ),
      ),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (value) => _toggleAssignee(assignee),
        activeColor: AppColors.primary,
      ),
      onTap: () => _toggleAssignee(assignee),
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        _buildSearchBar(
          controller: _memberSearchController,
          onChanged: (value) {
            setState(() {
              _memberSearchText = value;
            });
            _loadMembers();
          },
        ),
        Expanded(
          child: _isLoadingMembers
              ? const AssigneeListSkeleton()
              : _members.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy thành viên nào'),
                    )
                  : ListView.builder(
                      itemCount: _members.length,
                      itemBuilder: (context, index) =>
                          _buildListItem(_members[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildTeamsList() {
    return Column(
      children: [
        _buildSearchBar(
          controller: _teamSearchController,
          onChanged: (value) {
            setState(() {
              _teamSearchText = value;
            });
            _loadTeams();
          },
        ),
        Expanded(
          child: _isLoadingTeams
              ? const AssigneeListSkeleton()
              : _teams.isEmpty
                  ? const Center(
                      child: Text('Không tìm thấy đội nào'),
                    )
                  : ListView.builder(
                      itemCount: _teams.length,
                      itemBuilder: (context, index) =>
                          _buildListItem(_teams[index]),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocListener<FilterItemBloc, FilterItemState>(
          bloc: context.read<FilterItemBloc>(),
          listener: (context, state) {
            if (state.status == FilterItemStatus.success) {
              setState(() {
                _isLoadingMembers = false;
                _members = state.members ?? [];
              });
            }
            if (state.status == FilterItemStatus.error) {
              setState(() {
                _isLoadingMembers = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? ''),
                ),
              );
            }
            if (state.status == FilterItemStatus.loading) {
              setState(() {
                _isLoadingMembers = true;
              });
            }
          },
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'select_assignee'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: const Color(0xFF667085),
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Thành viên'),
                    Tab(text: 'Đội sale'),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMembersList(),
                      _buildTeamsList(),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFEAECF0)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Huỷ'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).pop(_selectedAssignees);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Xác nhận'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
