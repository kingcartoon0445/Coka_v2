import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/api_calendar_service.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:source_base/data/models/notification_repository.dart';
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/chat_repository.dart';
import 'package:source_base/data/repositories/deal_activity_repository.dart';
import 'package:source_base/data/repositories/final_deal_repository.dart';
import 'package:source_base/data/repositories/message_repository.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'package:source_base/data/repositories/switch_final_deal_repository.dart';
import 'package:source_base/data/repositories/user_repository.dart';
import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/deal_activity/deal_activity_bloc.dart';
import 'package:source_base/presentation/blocs/message/message_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/theme/theme_bloc.dart';

import '../presentation/blocs/chat/chat_aciton.dart';
import '../presentation/blocs/filter_item/filter_item_aciton.dart';
import '../presentation/blocs/final_deal/final_deal_action.dart';
import '../presentation/blocs/switch_final_deal/switch_final_deal_bloc.dart';
import '../presentation/blocs/switch_final_deal/switch_final_deal_action.dart';

// Khởi tạo GetIt singleton
final GetIt getIt = GetIt.instance;

// Thiết lập các dependency
Future<void> setupServiceLocator() async {
  // Services
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // API Client
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Data Sources
  getIt.registerLazySingleton<SharedPreferencesService>(
      () => SharedPreferencesService());
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<DioClient>()));
  getIt.registerLazySingleton<ApiCalendarService>(
      () => ApiCalendarService(getIt<DioClient>()));

  // Repositories
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(getIt<DioClient>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(
        apiService: getIt<ApiService>(),
        // storageService: getIt<StorageService>(),
      ));
  getIt.registerLazySingleton<MessageRepository>(() => MessageRepository(
        getIt<DioClient>(),
      ));
  getIt.registerLazySingleton<OrganizationRepository>(
      () => OrganizationRepository(apiService: getIt<ApiService>()));

  getIt.registerLazySingleton<CalendarRepository>(() =>
      CalendarRepository(apiCalendarService: getIt<ApiCalendarService>()));
  getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepository(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<FinalDealRepository>(
      () => FinalDealRepository(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SwitchFinalDealRepository>(
      () => SwitchFinalDealRepository(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<DealActivityRepository>(() =>
      DealActivityRepository(
          apiService: getIt<ApiService>(),
          apiCalendarService: getIt<ApiCalendarService>()));
  // BLoCs
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
      userRepository: getIt<UserRepository>(),
      organizationRepository: getIt<OrganizationRepository>()));
  getIt.registerFactory<OrganizationBloc>(() => OrganizationBloc(
      organizationRepository: getIt<OrganizationRepository>()));
  getIt.registerFactory<CustomerServiceBloc>(() => CustomerServiceBloc(
        organizationRepository: getIt<OrganizationRepository>(),
        calendarRepository: getIt<CalendarRepository>(),
      ));
  getIt.registerFactory<FilterItemBloc>(() => FilterItemBloc(
      organizationRepository: getIt<OrganizationRepository>(),
      switchFinalDealRepository: getIt<SwitchFinalDealRepository>()));
  getIt.registerFactory<ChatBloc>(
      () => ChatBloc(chatRepository: getIt<ChatRepository>()));
  getIt.registerFactory<FinalDealBloc>(() => FinalDealBloc(
      repository: getIt<FinalDealRepository>(),
      switchFinalDealRepository: getIt<SwitchFinalDealRepository>(),
      dealActivityRepository: getIt<DealActivityRepository>()));
  getIt.registerFactory<SwitchFinalDealBloc>(() => SwitchFinalDealBloc(
      repository: getIt<SwitchFinalDealRepository>(),
      finalRepository: getIt<FinalDealRepository>()));
  getIt.registerFactory<DealActivityBloc>(() => DealActivityBloc(
      dealActivityRepository: getIt<DealActivityRepository>(),
      calendarRepository: getIt<CalendarRepository>(),
      switchFinalDealRepository: getIt<SwitchFinalDealRepository>()));
  getIt.registerFactory<MessageBloc>(() => MessageBloc(
        repository: getIt<MessageRepository>(),
      ));
}
