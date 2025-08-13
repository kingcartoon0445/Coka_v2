import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:source_base/config/app_color.dart' show AppColors;
import 'package:source_base/data/datasources/remote/param_model/lead_paging_request_model.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/screens/home/widget/customers_page.dart';
import 'package:source_base/presentation/widget/dialog_member.dart';

import '../../blocs/customer_service/customer_service_action.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Các widget tương ứng với mỗi tab
  final List<Widget> _screens = [
    const Center(child: Text('Explore Content')),
    const Center(child: Text('Notifications Content')),
    const Center(child: Text('Profile Content')),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerServiceBloc, CustomerServiceState>(
      bloc: context.read<CustomerServiceBloc>(),
      listener: (context, state) {
        if (state.status == CustomerServiceStatus.error) {
          ShowdialogNouti(context,
              type: NotifyType.error, title: 'Lỗi', message: state.error ?? '');
        }
      },
      builder: (context, state) => CustomersPage(
        organizationId:
            context.read<OrganizationBloc>().state.organizationId ?? '',
      ),
    );
  }
}
