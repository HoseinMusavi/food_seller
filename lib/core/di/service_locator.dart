// lib/core/di/service_locator.dart
import 'package:food_seller/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:food_seller/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:food_seller/features/auth/domain/repositories/auth_repository.dart';
import 'package:food_seller/features/auth/domain/usecases/login_usecase.dart';
import 'package:food_seller/features/auth/domain/usecases/logout_usecase.dart';
import 'package:food_seller/features/auth/domain/usecases/signup_usecase.dart';
import 'package:food_seller/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:food_seller/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:food_seller/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:food_seller/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:food_seller/features/onboarding/domain/usecases/check_store_exists_usecase.dart';
import 'package:food_seller/features/onboarding/domain/usecases/create_store_usecase.dart';
import 'package:food_seller/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:food_seller/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:food_seller/features/orders/data/repositories/order_repository_impl.dart';
import 'package:food_seller/features/orders/domain/repositories/order_repository.dart';
import 'package:food_seller/features/orders/domain/usecases/get_order_details_usecase.dart';
import 'package:food_seller/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:food_seller/features/orders/domain/usecases/listen_to_order_changes_usecase.dart';
import 'package:food_seller/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_details_cubit.dart'; // *** ایمپورت جدید ***
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // #region External Dependencies
  sl.registerLazySingleton(() => Supabase.instance.client);
  // #endregion

  // #region Features

  // --- Auth ---
  sl.registerFactory(() => AuthCubit(
        signupUseCase: sl(),
        loginUseCase: sl(),
        logoutUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Onboarding ---
  sl.registerFactory(() => OnboardingCubit(
        checkStoreExistsUseCase: sl(),
        createStoreUseCase: sl(),
      ));
  sl.registerLazySingleton(() => CheckStoreExistsUseCase(sl()));
  sl.registerLazySingleton(() => CreateStoreUseCase(sl()));
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDataSource: sl(), supabaseClient: sl()),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // --- Order Management ---
  sl.registerFactoryParam<OrderManagementCubit, int, void>(
    (storeId, _) => OrderManagementCubit(
      getOrdersUseCase: sl(),
      listenToOrderChangesUseCase: sl(),
      updateOrderStatusUseCase: sl(),
      storeId: storeId,
    ),
  );
  
  // *** شروع بخش جدید ***
  // --- Order Details ---
  sl.registerFactory(() => OrderDetailsCubit(
        getOrderDetailsUseCase: sl(),
      ));
  // *** پایان بخش جدید ***

  // UseCases (از قبل ثبت شده)
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => ListenToOrderChangesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailsUseCase(sl()));
  // Repository (از قبل ثبت شده)
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  // DataSource (از قبل ثبت شده)
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // #endregion
}