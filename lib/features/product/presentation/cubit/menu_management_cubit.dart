// lib/features/product/presentation/cubit/menu_management_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/domain/usecases/get_categories_usecase.dart';
import 'package:food_seller/features/product/domain/usecases/get_products_usecase.dart';
import 'package:food_seller/features/product/domain/usecases/update_product_availability_usecase.dart';

part 'menu_management_state.dart';

class MenuManagementCubit extends Cubit<MenuManagementState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final UpdateProductAvailabilityUseCase updateProductAvailabilityUseCase;
  final int storeId;

  MenuManagementCubit({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
    required this.updateProductAvailabilityUseCase,
    required this.storeId,
  }) : super(MenuManagementInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  /// ۱. واکشی همزمان محصولات و دسته‌بندی‌ها
  // lib/features/product/presentation/cubit/menu_management_cubit.dart

  // ... (کدهای بالای تابع loadMenu، شامل constructor و mapFailureToMessage، دست نخورده باقی می‌مانند) ...

  /// ۱. واکشی همزمان محصولات و دسته‌بندی‌ها
  Future<void> loadMenu() async {
    emit(MenuManagementLoading());

    final results = await Future.wait([
      getProductsUseCase(GetProductsParams(storeId: storeId)),
      getCategoriesUseCase(GetCategoriesParams(storeId: storeId)),
    ]);

    // *** شروع بخش اصلاح شده ***
    // ما باید به صراحت نوع هر نتیجه را مشخص کنیم
    final productsResult = results[0] as Either<Failure, List<ProductEntity>>;
    final categoriesResult =
        results[1] as Either<Failure, List<ProductCategoryEntity>>;
    // *** پایان بخش اصلاح شده ***

    if (productsResult.isLeft() || categoriesResult.isLeft()) {
      // (منطق خطا بدون تغییر)
      productsResult.fold(
        (failure) => emit(MenuManagementError(_mapFailureToMessage(failure))),
        (_) {},
      );
      return;
    }

    // حالا getOrElse به درستی نوع List<ProductEntity> را برمی‌گرداند
    final products = productsResult.getOrElse(() => []);
    // و این یکی List<ProductCategoryEntity> را برمی‌گرداند
    final categories = categoriesResult.getOrElse(() => []);

    emit(MenuManagementLoaded(
      products: products,
      categories: categories,
    ));
  }

  // ... (بقیه فایل، شامل تابع toggleProductAvailability، دست نخورده باقی می‌ماند) ...

  /// ۲. آپدیت کردن وضعیت موجودی (قابلیت کلیدی)
  Future<void> toggleProductAvailability(
      {required int productId, required bool isAvailable}) async {
    final currentState = state;
    if (currentState is! MenuManagementLoaded) return;

    // لودر را برای این محصول خاص روشن کن
    final togglingIds = Set<int>.from(currentState.togglingProductIds)
      ..add(productId);
    emit(currentState.copyWith(togglingProductIds: togglingIds));

    final result = await updateProductAvailabilityUseCase(
      UpdateAvailabilityParams(productId: productId, isAvailable: isAvailable),
    );

    result.fold(
      (failure) {
        // اگر خطا رخ داد، لودر را خاموش کن و خطا را نشان بده
        final originalIds = Set<int>.from(currentState.togglingProductIds)
          ..remove(productId);
        // (ما یک خطا emit می‌کنیم اما state اصلی را حفظ می‌کنیم
        // تا UI از بین نرود. UI می‌تواند این خطا را در SnackBar نشان دهد)
        emit(MenuManagementError(_mapFailureToMessage(failure)));
        emit(currentState.copyWith(togglingProductIds: originalIds));
      },
      (_) {
        // اگر موفق بود، UI را به صورت خوش‌بینانه (Optimistic) آپدیت می‌کنیم
        // (لیست محصولات را به صورت محلی آپدیت می‌کنیم تا UI سریع باشد)
        final updatedProducts = List<ProductEntity>.from(currentState.products);
        final productIndex =
            updatedProducts.indexWhere((p) => p.id == productId);
        
        if (productIndex != -1) {
          // یک ProductEntity جدید با وضعیت isAvailable جدید می‌سازیم
          // (متأسفانه ProductEntity ما copyWith ندارد، پس دستی می‌سازیم)
          final oldProduct = updatedProducts[productIndex];
          updatedProducts[productIndex] = ProductEntity(
            id: oldProduct.id,
            storeId: oldProduct.storeId,
            name: oldProduct.name,
            description: oldProduct.description,
            price: oldProduct.price,
            discountPrice: oldProduct.discountPrice,
            imageUrl: oldProduct.imageUrl,
            categoryId: oldProduct.categoryId,
            categoryName: oldProduct.categoryName,
            isAvailable: isAvailable, // <-- تغییر در اینجا
          );
        }

        final updatedTogglingIds =
            Set<int>.from(currentState.togglingProductIds)..remove(productId);
            
        emit(currentState.copyWith(
          products: updatedProducts,
          togglingProductIds: updatedTogglingIds,
        ));
      },
    );
  }
}