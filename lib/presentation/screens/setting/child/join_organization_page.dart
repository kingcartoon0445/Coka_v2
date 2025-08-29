import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/setting/model/organization_search_repsonse.dart';
import 'package:source_base/presentation/blocs/setting/setting_action.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';
import 'package:source_base/presentation/screens/shared/widgets/loading_dialog.dart';
import 'package:source_base/presentation/screens/shared/widgets/search_bar.dart';
import 'package:source_base/presentation/widget/dialog_member.dart';
import 'package:source_base/presentation/widget/loading_indicator.dart';

class JoinOrganizationPage extends StatefulWidget {
  const JoinOrganizationPage({super.key});

  @override
  State<JoinOrganizationPage> createState() => _JoinOrganizationPageState();
}

class _JoinOrganizationPageState extends State<JoinOrganizationPage> {
  bool isFetching = false;

  Timer? _debounce;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchListOrg('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchListOrg(String searchText) async {
    setState(() {
      isFetching = true;
    });

    try {
      final response = await {};

      setState(() {
        isFetching = false;

        context.read<SettingBloc>().add(SearchOrganization(
            searchText: searchText,
            organizationId:
                context.read<OrganizationBloc>().state.organizationId ?? ''));
      });
    } catch (e) {
      setState(() {
        isFetching = false;
      });
      // Xử lý lỗi
    }
  }

  void onDebounce(Function(String) searchFunction, int debounceTime) {
    // Hủy bỏ bất kỳ timer nào nếu có
    _debounce?.cancel();

    // Tạo mới timer với thời gian debounce
    _debounce = Timer(Duration(milliseconds: debounceTime), () {
      // Lấy dữ liệu từ trường văn bản và gọi hàm tìm kiếm
      searchFunction(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FD),
        title: const Text(
          "Tham gia tổ chức",
          style: TextStyle(
              color: Color(0xFF1F2329),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: CustomSearchBar(
                width: double.infinity,
                hintText: "Nhập tên tổ chức",
                onQueryChanged: (value) {
                  onDebounce((v) {
                    fetchListOrg(value);
                  }, 800);
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Builder(builder: (context) {
              return BlocConsumer<SettingBloc, SettingState>(
                  listener: (context, state) {
                if (state.status == SettingStatus.successJoin) {
                  Navigator.of(context).pop();
                }
                if (state.status == SettingStatus.errorJoin) {
                  Navigator.of(context).pop();
                  ShowdialogNouti(context,
                      type: NotifyType.error,
                      title: 'Tham gia thất bại',
                      message: state.error ?? '');
                }
              }, builder: (context, state) {
                return Expanded(
                  child: isFetching
                      ? const Center(child: LoadingIndicator())
                      : state.organizations?.isEmpty ?? true
                          ? const Center(
                              child: Text(
                                  'Hãy tìm tổ chức mà bạn muốn tham gia',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                            )
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                return JoinOrgItem(
                                  dataItem: state.organizations![index],
                                  // organizationRepository: _organizationRepository,
                                );
                              },
                              itemCount: state.organizations?.length ?? 0,
                              shrinkWrap: true,
                            ),
                );
              });
            })
          ],
        ),
      ),
    );
  }
}

class JoinOrgItem extends StatefulWidget {
  final OrganizationSearchModel dataItem;
  // final OrganizationRepository organizationRepository;

  const JoinOrgItem({
    super.key,
    required this.dataItem,
    // required this.organizationRepository,
  });

  @override
  State<JoinOrgItem> createState() => _JoinOrgItemState();
}

class _JoinOrgItemState extends State<JoinOrgItem> {
  int stageBtn = 0;

  @override
  void initState() {
    super.initState();
    // Kiểm tra nếu đã gửi yêu cầu
    if (widget.dataItem.isRequest == true) {
      stageBtn = 1;
    }
  }

  Future<void> sendJoinRequest() async {
    if (widget.dataItem.isRequest == true || stageBtn == 1) {
      return;
    }

    showLoadingDialog(context);

    context.read<SettingBloc>().add(JoinOrganization(
        organizationId: widget.dataItem.organizationId ?? '',
        organizationName: widget.dataItem.name ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        leading: AppAvatar(
          fallbackText: widget.dataItem.name,
          size: 36,
        ),
        title: Text(
          widget.dataItem.name ?? '',
          style: TextStyles.heading3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          widget.dataItem.subscription == "PERSONAL"
              ? "Cá nhân"
              : "Doanh nghiệp",
          style: TextStyles.subtitle1,
        ),
        trailing: SizedBox(
          height: 28,
          child: ElevatedButton(
            onPressed: sendJoinRequest,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: Size.zero,
              backgroundColor:
                  stageBtn == 1 || widget.dataItem.isRequest == true
                      ? Colors.white
                      : AppColors.primary.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: stageBtn == 1 || widget.dataItem.isRequest == true
                      ? AppColors.primary.withValues(alpha: 0.6)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              stageBtn != 0 || widget.dataItem.isRequest == true
                  ? "Đã gửi"
                  : "Tham gia",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: stageBtn != 0 || widget.dataItem.isRequest == true
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
