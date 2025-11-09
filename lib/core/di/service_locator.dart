// lib/core/di/service_locator.dart
import 'dart:io'; // (برای فایل‌های اصلی)
import 'package:food_seller/core/data/datasources/storage_remote_datasource.dart';
import 'package:food_seller/core/domain/usecases/upload_image_usecase.dart';
// ... (سایر ایمپورت‌های قبلی)
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
import 'package:food_seller/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/product/data/datasources/product_remote_datasource.dart';
import 'package:food_seller/features/product/data/repositories/product_repository_impl.dart';
import 'package:food_seller/features/product/domain/repositories/product_repository.dart';
import 'package:food_seller/features/product/domain/usecases/create_product_usecase.dart';
import 'package:food_seller/features/product/domain/usecases/get_categories_usecase.dart';
import 'package:food_seller/features/product/domain/usecases/get_products_usecase.dart';
import 'package:food_seller/features/product/domain/usecases/update_product_availability_usecase.dart';
import 'package:food_seller/features/product/domain/usecases/update_product_usecase.dart';
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';
import 'package:food_seller/features/product/presentation/cubit/product_editor_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// lib/core/di/service_locator.dart



final sl = GetIt.instance;

Future<void> init() async {
  // ... (External, Core, Auth, Onboarding, Order Management بدون تغییر) ...
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => UploadImageUseCase(sl()));
  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => StorageRemoteDataSourceImpl(supabaseClient: sl()),
  );
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
  sl.registerFactoryParam<OrderManagementCubit, int, void>(
    (storeId, _) => OrderManagementCubit(
      getOrdersUseCase: sl(),
      listenToOrderChangesUseCase: sl(),
      updateOrderStatusUseCase: sl(),
      storeId: storeId,
    ),
  );
  sl.registerFactory(() => OrderDetailsCubit(
        getOrderDetailsUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => ListenToOrderChangesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailsUseCase(sl()));
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(supabaseClient: sl()),
  );


  // --- Product Management (آپدیت شده) ---
  sl.registerFactoryParam<MenuManagementCubit, int, void>(
    (storeId, _) => MenuManagementCubit(
      getProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      updateProductAvailabilityUseCase: sl(),
      storeId: storeId,
    ),
  );
  
  // *** ProductEditorCubit آپدیت شد ***
  sl.registerFactory(() => ProductEditorCubit(
        createProductUseCase: sl(),
        updateProductUseCase: sl(), // <-- اضافه شد
        uploadImageUseCase: sl(), 
      ));
  
  sl.registerLazySingleton(() => CreateProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl())); // <-- اضافه شد
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductAvailabilityUseCase(sl()));
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // #endregion
}