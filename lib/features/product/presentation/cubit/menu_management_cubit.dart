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

  Future<void> loadMenu() async {
    emit(MenuManagementLoading());

    final results = await Future.wait([
      getProductsUseCase(GetProductsParams(storeId: storeId)),
      getCategoriesUseCase(GetCategoriesParams(storeId: storeId)),
    ]);

    final productsResult = results[0] as Either<Failure, List<ProductEntity>>;
    final categoriesResult =
        results[1] as Either<Failure, List<ProductCategoryEntity>>;

    if (productsResult.isLeft() || categoriesResult.isLeft()) {
      productsResult.fold(
        (failure) => emit(MenuManagementError(_mapFailureToMessage(failure))),
        (_) {},
      );
      return;
    }

    final products = productsResult.getOrElse(() => []);
    final categories = categoriesResult.getOrElse(() => []);

    emit(MenuManagementLoaded(
      products: products,
      categories: categories,
    ));
  }

  Future<void> toggleProductAvailability(
      {required int productId, required bool isAvailable}) async {
    final currentState = state;
    if (currentState is! MenuManagementLoaded) return;

    final togglingIds = Set<int>.from(currentState.togglingProductIds)
      ..add(productId);
    emit(currentState.copyWith(togglingProductIds: togglingIds));

    final result = await updateProductAvailabilityUseCase(
      UpdateAvailabilityParams(productId: productId, isAvailable: isAvailable),
    );

    result.fold(
      (failure) {
        final originalIds = Set<int>.from(currentState.togglingProductIds)
          ..remove(productId);
        emit(MenuManagementError(_mapFailureToMessage(failure)));
        emit(currentState.copyWith(togglingProductIds: originalIds));
      },
      (_) {
        final updatedProducts = List<ProductEntity>.from(currentState.products);
        final productIndex =
            updatedProducts.indexWhere((p) => p.id == productId);
        
        if (productIndex != -1) {
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
            isAvailable: isAvailable, 
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