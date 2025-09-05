import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';import 'package:source_base/config/routes.dart';
import 'package:source_base/dio/service_locator.dart';
import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/chat/chat_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/connection_channel/connection_channel_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/customer_detail/customer_detail_bloc.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_bloc.dart';
import 'package:source_base/presentation/blocs/message/message_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_action_bloc.dart';
import 'package:source_base/presentation/blocs/setting/setting_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/switch_final_deal_bloc.dart';
import 'package:source_base/presentation/blocs/theme/theme_bloc.dart';

import 'presentation/blocs/filter_item/filter_item_aciton.dart';
import 'presentation/blocs/final_deal/final_deal_action.dart';
import 'presentation/blocs/theme/theme_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Đăng ký các BLoC
        BlocProvider<ThemeBloc>(
          create: (_) => getIt<ThemeBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>(),
        ),
        BlocProvider<OrganizationBloc>(
          create: (_) => getIt<OrganizationBloc>(),
        ),
        BlocProvider<CustomerServiceBloc>(
          create: (_) => getIt<CustomerServiceBloc>(),
        ),
        BlocProvider<CustomerDetailBloc>(
          create: (_) => getIt<CustomerDetailBloc>(),
        ),
        BlocProvider<FilterItemBloc>(
          create: (_) => getIt<FilterItemBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => getIt<ChatBloc>(),
        ),
        BlocProvider<FinalDealBloc>(
          create: (_) => getIt<FinalDealBloc>(),
        ),
        BlocProvider<SwitchFinalDealBloc>(
          create: (_) => getIt<SwitchFinalDealBloc>(),
        ),
        BlocProvider<DealActivityBloc>(
          create: (_) => getIt<DealActivityBloc>(),
        ),
        BlocProvider<MessageBloc>(
          create: (_) => getIt<MessageBloc>(),
        ),
        BlocProvider<ConnectionChannelBloc>(
          create: (_) => getIt<ConnectionChannelBloc>(),
        ),
        BlocProvider<SettingBloc>(
          create: (_) => getIt<SettingBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          // Xây dựng ứng dụng với chủ đề từ ThemeBloc
          return MaterialApp.router(
            title: 'Flutter Demo',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: state.currentLocale, // Sử dụng locale từ ThemeBloc
            theme: state.themeData, // Sử dụng theme từ state
            routerConfig: router, // Sử dụng router đã đăng ký
            // Thêm key để force rebuild khi locale thay đổi
            key: ValueKey(state.currentLocale.toString()),
          );
        },
      ),
    );
  }
}
