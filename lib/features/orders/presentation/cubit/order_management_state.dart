// lib/features/orders/presentation/cubit/order_management_state.dart
part of 'order_management_cubit.dart';

abstract class OrderManagementState extends Equatable {
  const OrderManagementState();
  @override
  List<Object?> get props => [];
}

class OrderManagementInitial extends OrderManagementState {}

class OrderManagementLoading extends OrderManagementState {}

class OrderManagementError extends OrderManagementState {
  final String message;
  const OrderManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

// وضعیت اصلی ما: تمام لیست‌ها را در خود نگه می‌دارد
class OrderManagementLoaded extends OrderManagementState {
  final List<OrderEntity> pendingOrders; // تب "جدید"
  final List<OrderEntity> activeOrders; // تب "در حال انجام"
  final List<OrderEntity> completedOrders; // تب "تکمیل شده"

  // لیستی از ID سفارش‌هایی که در حال آپدیت شدن هستند (برای نمایش لودر روی دکمه)
  final Set<int> updatingOrderIds;

  const OrderManagementLoaded({
    this.pendingOrders = const [],
    this.activeOrders = const [],
    this.completedOrders = const [],
    this.updatingOrderIds = const {},
  });

  OrderManagementLoaded copyWith({
    List<OrderEntity>? pendingOrders,
    List<OrderEntity>? activeOrders,
    List<OrderEntity>? completedOrders,
    Set<int>? updatingOrderIds,
  }) {
    return OrderManagementLoaded(
      pendingOrders: pendingOrders ?? this.pendingOrders,
      activeOrders: activeOrders ?? this.activeOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      updatingOrderIds: updatingOrderIds ?? this.updatingOrderIds,
    );
  }

  @override
  List<Object?> get props => [
        pendingOrders,
        activeOrders,
        completedOrders,
        updatingOrderIds,
      ];
}