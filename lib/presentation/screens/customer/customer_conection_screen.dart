import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_base/presentation/screens/customer/dialog_user.dart';
import 'package:source_base/presentation/screens/shared/widgets/avatar_widget.dart';

import '../../blocs/customer_service/customer_service_action.dart';
import '../../blocs/customer_detail/customer_detail_bloc.dart';
import '../../blocs/customer_detail/customer_detail_event.dart';
import '../../blocs/organization/organization_action_bloc.dart';

class CustomerConectionScreen extends StatelessWidget {
  const CustomerConectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Nút back
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CustomerServiceBloc, CustomerServiceState>(
          builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              AppAvatar(
                imageUrl: state.facebookChat?.avatar,
                fallbackText: state.facebookChat?.fullName,
                size: 40,
                shape: AvatarShape.circle,
              ),
              const SizedBox(height: 12),

              // Tên
              Text(
                state.facebookChat?.fullName ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Opportunity/Deals section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Opportunity/Deals",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  showDialog<String>(
                    context: context,
                    builder: (context) => SelectUserDialog(
                      // customers: state.customers,
                      onSearch: (value) {
                        context.read<CustomerDetailBloc>().add(
                              SearchCustomerEvent(
                                organizationId: context
                                    .read<OrganizationBloc>()
                                    .state
                                    .organizationId!,
                                name: value,
                              ),
                            );
                      },
                    ),
                  ).then((selectedUser) {
                    if (selectedUser != null) {
                      context.read<CustomerDetailBloc>().add(LinkToLeadEvent(
                            organizationId: context
                                .read<OrganizationBloc>()
                                .state
                                .organizationId!,
                            conversationId: context
                                    .read<CustomerServiceBloc>()
                                    .state
                                    .facebookChat
                                    ?.id ??
                                '',
                            leadId: selectedUser,
                          ));
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  // height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Text("Opportunity/Deals"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.arrow_drop_down_rounded, size: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Create new opportunity"),
                ),
              ),
              const SizedBox(height: 24),

              // Customer section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Customer",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(value: "cus1", child: Text("Customer 1")),
                  DropdownMenuItem(value: "cus2", child: Text("Customer 2")),
                ],
                onChanged: (value) {},
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Create new customer"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
