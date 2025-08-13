import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ⚠️ đảm bảo có import này
import 'package:source_base/config/routes.dart';
import 'package:source_base/dio/service_locator.dart';

import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/chat/chat_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_action_bloc.dart';
import 'package:source_base/presentation/blocs/switch_final_deal/switch_final_deal_bloc.dart';
import 'package:source_base/presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/filter_item/filter_item_aciton.dart';
import 'presentation/blocs/final_deal/final_deal_action.dart';
import 'presentation/blocs/theme/theme_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ Ở đây giả định EasyLocalization đã bọc MyApp ở main.dart
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => getIt<ThemeBloc>()),
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<OrganizationBloc>(
            create: (_) => getIt<OrganizationBloc>()),
        BlocProvider<CustomerServiceBloc>(
            create: (_) => getIt<CustomerServiceBloc>()),
        BlocProvider<FilterItemBloc>(create: (_) => getIt<FilterItemBloc>()),
        BlocProvider<ChatBloc>(create: (_) => getIt<ChatBloc>()),
        BlocProvider<FinalDealBloc>(create: (_) => getIt<FinalDealBloc>()),
        BlocProvider<SwitchFinalDealBloc>(
            create: (_) => getIt<SwitchFinalDealBloc>()),
        BlocProvider<DealActivityBloc>(
            create: (_) => getIt<DealActivityBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (p, n) =>
            p.currentLocale != n.currentLocale || p.themeData != n.themeData,
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            // ✅ Lấy từ EasyLocalization (đã có ở trên cây widget)
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: state.currentLocale, // ✅ dùng locale từ ThemeBloc
            theme: state.themeData,
            routerConfig: router,
            // 🚫 BỎ key ép rebuild tránh deactivated ancestor crash
            // key: ValueKey(state.currentLocale.toString()),
          );
        },
      ),
    );
  }
}
