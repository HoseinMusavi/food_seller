// lib/features/product/presentation/cubit/menu_management_state.dart
part of 'menu_management_cubit.dart';

abstract class MenuManagementState extends Equatable {
  const MenuManagementState();
  @override
  List<Object?> get props => [];
}

class MenuManagementInitial extends MenuManagementState {}

class MenuManagementLoading extends MenuManagementState {}

class MenuManagementError extends MenuManagementState {
  final String message;
  const MenuManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

class MenuManagementLoaded extends MenuManagementState {
  final List<ProductCategoryEntity> categories;
  final List<ProductEntity> products;
  // این Set آیدی محصولاتی را نگه می‌دارد که دکمه Switch آن‌ها
  // در حال لودینگ (ارتباط با دیتابیس) است.
  final Set<int> togglingProductIds;

  const MenuManagementLoaded({
    this.categories = const [],
    this.products = const [],
    this.togglingProductIds = const {},
  });

  MenuManagementLoaded copyWith({
    List<ProductCategoryEntity>? categories,
    List<ProductEntity>? products,
    Set<int>? togglingProductIds,
  }) {
    return MenuManagementLoaded(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      togglingProductIds: togglingProductIds ?? this.togglingProductIds,
    );
  }

  @override
  List<Object?> get props => [categories, products, togglingProductIds];
}