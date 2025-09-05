import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:collection/collection.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/data/models/customer_service_response.dart';
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_event.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_state.dart';
import 'package:source_base/presentation/screens/home/widget/customer_list_item.dart';

class CustomersList extends StatefulWidget {
  final String organizationId;
  final String? stageGroupId;
  final String? searchQuery;
  final List<CustomerServiceModel> queryParams;
  final bool isArchive;
  final VoidCallback? onRefresh;

  const CustomersList({
    super.key,
    required this.organizationId,
    this.stageGroupId,
    this.searchQuery,
    required this.queryParams,
    this.isArchive = false,
    this.onRefresh,
  });

  @override
  State<CustomersList> createState() => _CustomersListState();
}

extension CustomersListExtension on _CustomersListState {
  // Method public để trigger refresh từ bên ngoài
  void triggerRefresh() {
    print('CustomersListExtension: triggerRefresh called');
    if (mounted) {
      try {
        setState(() {
          _isFirstLoad = true;
          _currentOffset = 0;
        });
        _loadInitialData();
      } catch (e) {
        print('CustomersListExtension: Error during triggerRefresh: $e');
      }
    }
  }
}

class _CustomersListState extends State<CustomersList> {
  final ScrollController _scrollController = ScrollController();
  final int _limit = 20;
  int _currentOffset = 0;
  final _mapEquality = const MapEquality<String, dynamic>();
  bool _isFirstLoad = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial data
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _loadInitialData();
    // });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadInitialData() {
    final pagingRequest = LeadPagingRequest(
        limit: _limit,
        offset: 0,
        searchText: widget.searchQuery,
        channels: ["LEAD"]);

    context.read<CustomerServiceBloc>().add(
          LoadCustomerService(
            organizationId: widget.organizationId,
            pagingRequest: pagingRequest,
          ),
        );
  }

  void _loadMore() {
    final state = context.read<CustomerServiceBloc>().state;
    print(
        'LoadMore called - hasMore: ${state.hasMoreCustomers}, status: ${state.status}, isLoadingMore: $_isLoadingMore, offset: $_currentOffset');

    if (state.hasMoreCustomers &&
        state.status != CustomerServiceStatus.loadingMore &&
        !_isLoadingMore) {
      print('Starting load more with offset: $_currentOffset');
      _isLoadingMore = true;
      _currentOffset += _limit;

      final pagingRequest = LeadPagingRequest(
        limit: _limit,
        offset: _currentOffset,
        searchText: widget.searchQuery,
      );

      // Lưu vị trí scroll hiện tại
      final currentScrollPosition = _scrollController.position.pixels;

      context.read<CustomerServiceBloc>().add(
            LoadMoreCustomers(
              organizationId: widget.organizationId,
              pagingRequest: null,
            ),
          );

      // Reset flag sau khi gọi API
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('Resetting isLoadingMore flag');
        _isLoadingMore = false;
      });
    }
  }

  @override
  void didUpdateWidget(CustomersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Chỉ refresh khi có thay đổi quan trọng
    bool hasImportantChanges = oldWidget.stageGroupId != widget.stageGroupId ||
        oldWidget.organizationId != widget.organizationId ||
        oldWidget.searchQuery != widget.searchQuery;

    if (hasImportantChanges) {
      setState(() {
        _isFirstLoad = true;
        _currentOffset = 0;
      });
      // Sử dụng Future.delayed để tránh nhiều refresh liên tiếp
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadInitialData();
        }
      });
    }
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to customer assignment changes để auto-refresh khi có assignment update
    // ref.listen<int>(customerAssignmentRefreshProvider, (previous, next) {
    //   if (previous != null && previous != next && mounted) {
    //     print('CustomersList: Assignment change detected, refreshing list');
    //     if (mounted) {
    //       try {
    //         setState(() {
    //           _isFirstLoad = true;
    //         });
    //         _pagingController.refresh();
    //       } catch (e) {
    //         print('CustomersList: Error during assignment refresh: $e');
    //       }
    //     }
    //   }
    // });

    // Listen to customer list changes để auto-refresh khi có thêm/xóa/sửa customer
    // ref.listen<int>(customerListRefreshProvider, (previous, next) {
    //   if (previous != null && previous != next && mounted) {
    //     print('CustomersList: Customer list change detected, refreshing list');
    //     if (mounted) {
    //       try {
    //         setState(() {
    //           _isFirstLoad = true;
    //         });
    //         _pagingController.refresh();
    //       } catch (e) {
    //         print('CustomersList: Error during customer list refresh: $e');
    //       }
    //     }
    //   }
    // });

    return RefreshIndicator(
      onRefresh: () async {
        print('CustomersList: Pull to refresh triggered');
        if (mounted) {
          setState(() {
            _isFirstLoad = true;
            _currentOffset = 0;
          });

          _loadInitialData();
          widget.onRefresh?.call();
        }
      },
      child: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
        builder: (context, state) {
          // Show shimmer loading only for initial load when no data
          if (state.status == CustomerServiceStatus.loadingUserInfo) {
            return Column(
              children: List.generate(
                5,
                (index) => _buildShimmerItem(),
              ),
            );
          }

          // Show error only when no data
          if (state.status == CustomerServiceStatus.error &&
              state.customerServices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Có lỗi xảy ra: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isFirstLoad = true;
                        _currentOffset = 0;
                      });
                      _loadInitialData();
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (state.customerServices.isEmpty &&
              state.status != CustomerServiceStatus.loadingUserInfo) {
            return const Center(
              child: Text(
                'Không có khách hàng nào',
                style: TextStyle(color: AppColors.text, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: state.customerServices.length +
                (state.hasMoreCustomers ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.customerServices.length) {
                // Show loading indicator at the bottom for load more
                if (state.status == CustomerServiceStatus.loadingMore) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đang tải thêm...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              return CustomerListItem(
                customer: state.customerServices[index],
                organizationId: widget.organizationId,
                isArchive: widget.isArchive,
              );
            },
          );
        },
      ),

      //  PagingListener<int, CustomerServiceModel>(
      //   controller: _pagingController,
      //   builder: (context, state, fetchNextPage) =>
      //       PagedListView<int, CustomerServiceModel>(
      //     state: state,
      //     fetchNextPage: fetchNextPage,
      //     builderDelegate: PagedChildBuilderDelegate<CustomerServiceModel>(
      //       itemBuilder: (context, customer, index) => CustomerListItem(
      //         customer: customer,
      //         organizationId: widget.organizationId,
      //         workspaceId: widget.workspaceId,
      //       ),
      //       firstPageProgressIndicatorBuilder: (context) => _isFirstLoad
      //           ? Column(
      //               children: List.generate(
      //                 5,
      //                 (index) => _buildShimmerItem(),
      //               ),
      //             )
      //           : const SizedBox.shrink(),
      //       newPageProgressIndicatorBuilder: (context) => _buildShimmerItem(),
      //       firstPageErrorIndicatorBuilder: (context) => Center(
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             const Text(
      //               'Có lỗi xảy ra khi tải danh sách khách hàng',
      //               style: TextStyle(
      //                 color: AppColors.text,
      //                 fontSize: 14,
      //               ),
      //             ),
      //             const SizedBox(height: 8),
      //             TextButton(
      //               onPressed: () {
      //                 setState(() {
      //                   _isFirstLoad = true;
      //                 });
      //                 _pagingController.refresh();
      //               },
      //               child: const Text(
      //                 'Thử lại',
      //                 style: TextStyle(
      //                   color: AppColors.primary,
      //                   fontSize: 14,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       noItemsFoundIndicatorBuilder: (context) => _isFirstLoad
      //           ? const SizedBox.shrink()
      //           : const Center(
      //               child: Padding(
      //                 padding: EdgeInsets.all(16),
      //                 child: Text('Không có khách hàng nào'),
      //               ),
      //             ),
      //     ),
      //   ),
      // ),
    );
  }
}
