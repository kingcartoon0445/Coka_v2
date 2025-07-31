import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/config/app_color.dart';
import 'package:source_base/config/test_style.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_event.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_state.dart';
import 'package:source_base/presentation/widget/loading_indicator.dart';

class ServiceDetailsListWidget extends StatefulWidget {
  final String organizationId;
  final String customerId;
  final int pageSize;

  const ServiceDetailsListWidget({
    super.key,
    required this.organizationId,
    required this.customerId,
    this.pageSize = 20,
  });

  @override
  State<ServiceDetailsListWidget> createState() =>
      _ServiceDetailsListWidgetState();
}

class _ServiceDetailsListWidgetState extends State<ServiceDetailsListWidget> {
  final ScrollController _scrollController = ScrollController();
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = context.read<CustomerServiceBloc>().state;
    if (state.hasMoreServiceDetails &&
        state.status != CustomerServiceStatus.loadingMore) {
      _currentOffset += widget.pageSize;
      context.read<CustomerServiceBloc>().add(
            LoadMoreServiceDetails(
              organizationId: widget.organizationId,
              limit: widget.pageSize,
              offset: _currentOffset,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
      builder: (context, state) {
        if (state.status == CustomerServiceStatus.loading &&
            state.serviceDetails.isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        if (state.status == CustomerServiceStatus.error &&
            state.serviceDetails.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.error}',
                  style: TextStyles.body.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reload initial data
                    context.read<CustomerServiceBloc>().add(
                          LoadJourneyPaging(
                            organizationId: widget.organizationId,
                          ),
                        );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: state.serviceDetails.length +
              (state.hasMoreServiceDetails ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.serviceDetails.length) {
              // Show loading indicator at the bottom
              if (state.status == CustomerServiceStatus.loadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: LoadingIndicator()),
                );
              }
              return const SizedBox.shrink();
            }

            final serviceDetail = state.serviceDetails[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    serviceDetail.createdByName
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  serviceDetail.summary ?? '',
                  style: TextStyles.body,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceDetail.createdByName ?? '',
                      style: TextStyles.subtitle1,
                    ),
                    Text(
                      serviceDetail.createdDate ?? '',
                      style: TextStyles.subtitle2.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(serviceDetail.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    serviceDetail.type ?? '',
                    style: TextStyles.subtitle2.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'note':
        return Colors.blue;
      case 'call':
        return Colors.green;
      case 'meeting':
        return Colors.orange;
      case 'email':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
