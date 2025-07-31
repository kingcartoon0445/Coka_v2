import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:source_base/core/api/dio_client.dart';
import 'package:source_base/data/datasources/local/shared_preferences_service.dart';
import 'package:source_base/data/datasources/remote/api_calendar_service.dart';
import 'package:source_base/data/datasources/remote/api_service.dart';
import 'package:source_base/data/repositories/calendar_repository.dart';
import 'package:source_base/data/repositories/origanzation_repository.dart';
import 'package:source_base/data/repositories/user_repository.dart';
import 'package:source_base/presentation/blocs/auth/auth_bloc.dart';
import 'package:source_base/presentation/blocs/customer_service/customer_service_bloc.dart';
import 'package:source_base/presentation/blocs/organization/organization_bloc.dart';
import 'package:source_base/presentation/blocs/theme/theme_bloc.dart';

import '../presentation/blocs/filter_item/filter_item_aciton.dart';

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
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(
        apiService: getIt<ApiService>(),
        // storageService: getIt<StorageService>(),
      ));
  getIt.registerLazySingleton<OrganizationRepository>(
      () => OrganizationRepository(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<CalendarRepository>(() =>
      CalendarRepository(apiCalendarService: getIt<ApiCalendarService>()));
  // BLoCs
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
  getIt.registerFactory<AuthBloc>(
      () => AuthBloc(userRepository: getIt<UserRepository>()));
  getIt.registerFactory<OrganizationBloc>(() => OrganizationBloc(
      organizationRepository: getIt<OrganizationRepository>()));
  getIt.registerFactory<CustomerServiceBloc>(() => CustomerServiceBloc(
        organizationRepository: getIt<OrganizationRepository>(),
        calendarRepository: getIt<CalendarRepository>(),
      ));
  getIt.registerFactory<FilterItemBloc>(() =>
      FilterItemBloc(organizationRepository: getIt<OrganizationRepository>()));
}
