// lib/features/orders/presentation/cubit/order_management_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:food_seller/features/orders/domain/usecases/listen_to_order_changes_usecase.dart';
import 'package:food_seller/features/orders/domain/usecases/update_order_status_usecase.dart';

part 'order_management_state.dart';

class OrderManagementCubit extends Cubit<OrderManagementState> {
  final GetOrdersUseCase getOrdersUseCase;
  final ListenToOrderChangesUseCase listenToOrderChangesUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final int storeId; 

  StreamSubscription? _orderSubscription;

  OrderManagementCubit({
    required this.getOrdersUseCase,
    required this.listenToOrderChangesUseCase,
    required this.updateOrderStatusUseCase,
    required this.storeId, 
  }) : super(OrderManagementInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> loadOrders() async {
    // اگر از قبل در حال لودینگ نیستیم، لودینگ را نشان بده
    if (state is! OrderManagementLoading) {
       emit(OrderManagementLoading());
    }

    final results = await Future.wait([
      getOrdersUseCase(GetOrdersParams(
          storeId: storeId, statuses: [OrderStatus.pending])),
      getOrdersUseCase(GetOrdersParams(storeId: storeId, statuses: [
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.delivering
      ])),
      getOrdersUseCase(GetOrdersParams(storeId: storeId, statuses: [
        OrderStatus.delivered,
        OrderStatus.cancelled
      ])),
    ]);

    final pendingResult = results[0];
    final activeResult = results[1];
    final completedResult = results[2];

    if (pendingResult.isLeft() ||
        activeResult.isLeft() ||
        completedResult.isLeft()) {
      pendingResult.fold(
          (failure) => emit(OrderManagementError(_mapFailureToMessage(failure))),
          (_) {});
      return;
    }

    final pendingOrders = pendingResult.getOrElse(() => []);
    final activeOrders = activeResult.getOrElse(() => []);
    final completedOrders = completedResult.getOrElse(() => []);

    // *** اصلاح شد: وضعیت لودینگ دکمه‌ها را حفظ کن ***
    Set<int> currentUpdatingIds = {};
    if (state is OrderManagementLoaded) {
      currentUpdatingIds = (state as OrderManagementLoaded).updatingOrderIds;
    }

    emit(OrderManagementLoaded(
      pendingOrders: pendingOrders,
      activeOrders: activeOrders,
      completedOrders: completedOrders,
      updatingOrderIds: currentUpdatingIds, // حفظ وضعیت لودینگ
    ));

    // فقط اگر اولین بار است، به تغییرات گوش بده
    if (_orderSubscription == null) {
      _listenToChanges();
    }
  }

  void _listenToChanges() async {
    await _orderSubscription?.cancel();
    
    final failureOrStream =
        await listenToOrderChangesUseCase(ListenToOrdersParams(storeId: storeId));

    failureOrStream.fold(
      (failure) =>
          print('Error listening to orders: ${_mapFailureToMessage(failure)}'),
      (stream) {
        _orderSubscription = stream.listen((_) {
          // *** اصلاح شد: بهینه‌سازی ***
          // هر تغییری که در Realtime بشنویم (insert, update, delete)
          // ما فقط کل لیست‌ها را دوباره واکشی می‌کنیم (loadOrders).
          // این ساده‌ترین و مطمئن‌ترین راه برای همگام‌سازی است.
          print("Realtime change detected! Refetching orders...");
          loadOrders(); // واکشی مجدد کل داده‌ها
        });
      },
    );
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final updatingIds = Set<int>.from(currentState.updatingOrderIds)..add(orderId);
    emit(currentState.copyWith(updatingOrderIds: updatingIds));

    final result = await updateOrderStatusUseCase(
      UpdateOrderStatusParams(orderId: orderId, newStatus: newStatus),
    );

    result.fold(
      (failure) {
        // اگر خطا رخ داد، به کاربر اطلاع می‌دهیم
        final updatedIds = Set<int>.from(currentState.updatingOrderIds)
          ..remove(orderId);
        emit(OrderManagementError(_mapFailureToMessage(failure)));
        // بازگشت به حالت Loaded
        emit(currentState.copyWith(updatingOrderIds: updatedIds));
      },
      (_) {
        // موفقیت!
        // هیچ کاری نمی‌کنیم. Realtime (`_listenToChanges`) این تغییر را تشخیص داده
        // و `loadOrders()` را صدا می‌زند که به طور خودکار UI را رفرش می‌کند.
        // لودر دکمه نیز در `loadOrders()` پاک خواهد شد.
      },
    );
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}