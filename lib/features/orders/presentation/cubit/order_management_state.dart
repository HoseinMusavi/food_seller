// lib/features/orders/presentation/cubit/order_management_state.dart
part of 'order_management_cubit.dart';

abstract class OrderManagementState extends Equatable {
  const OrderManagementState();
  @override
  List<Object> get props => [];
}

class OrderManagementInitial extends OrderManagementState {}

class OrderManagementLoading extends OrderManagementState {}

class OrderManagementError extends OrderManagementState {
  final String message;
  const OrderManagementError(this.message);
  @override
  List<Object> get props => [message];
}

class OrderManagementLoaded extends OrderManagementState {
  // --- شروع بخش اصلاح شده ---
  final List<OrderEntity> pendingOrders; // تب ۱: جدید (Pending)
  final List<OrderEntity>
      preparingOrders; // تب ۲: در حال آماده‌سازی (Confirmed, Preparing)
  final List<OrderEntity> deliveringOrders; // تب ۳: در حال ارسال (Delivering)
  final List<OrderEntity> historyOrders; // تب ۴: تاریخچه (Delivered, Cancelled)
  // --- پایان بخش اصلاح شده ---
  final Set<int> updatingOrderIds; // لودر دکمه‌های هر کارت

  const OrderManagementLoaded({
    required this.pendingOrders,
    required this.preparingOrders,
    required this.deliveringOrders,
    required this.historyOrders,
    required this.updatingOrderIds,
  });

  OrderManagementLoaded copyWith({
    List<OrderEntity>? pendingOrders,
    List<OrderEntity>? preparingOrders,
    List<OrderEntity>? deliveringOrders,
    List<OrderEntity>? historyOrders,
    Set<int>? updatingOrderIds,
  }) {
    return OrderManagementLoaded(
      pendingOrders: pendingOrders ?? this.pendingOrders,
      preparingOrders: preparingOrders ?? this.preparingOrders,
      deliveringOrders: deliveringOrders ?? this.deliveringOrders,
      historyOrders: historyOrders ?? this.historyOrders,
      updatingOrderIds: updatingOrderIds ?? this.updatingOrderIds,
    );
  }

  @override
  List<Object> get props => [
        pendingOrders,
        preparingOrders,
        deliveringOrders,
        historyOrders,
        updatingOrderIds
      ];
}