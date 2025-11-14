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
    if (state is! OrderManagementLoading && state is! OrderManagementLoaded) {
      emit(OrderManagementLoading());
    }

    // --- شروع بخش اصلاح شده ---
    final results = await Future.wait([
      // ۱. جدید
      getOrdersUseCase(
          GetOrdersParams(storeId: storeId, statuses: [OrderStatus.pending])),
      // ۲. در حال آماده‌سازی
      getOrdersUseCase(GetOrdersParams(storeId: storeId, statuses: [
        OrderStatus.confirmed,
        OrderStatus.preparing,
      ])),
      // ۳. در حال ارسال
      getOrdersUseCase(
          GetOrdersParams(storeId: storeId, statuses: [OrderStatus.delivering])),
      // ۴. تاریخچه
      getOrdersUseCase(GetOrdersParams(storeId: storeId, statuses: [
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ])),
    ]);

    final pendingResult = results[0];
    final preparingResult = results[1];
    final deliveringResult = results[2];
    final historyResult = results[3];

    // بررسی خطا برای هر ۴ درخواست
    if (pendingResult.isLeft() ||
        preparingResult.isLeft() ||
        deliveringResult.isLeft() ||
        historyResult.isLeft()) {
      // فقط یکی از خطاها را نمایش می‌دهیم
      pendingResult.fold(
          (failure) => emit(OrderManagementError(_mapFailureToMessage(failure))),
          (_) {});
      return;
    }

    final pendingOrders = pendingResult.getOrElse(() => []);
    final preparingOrders = preparingResult.getOrElse(() => []);
    final deliveringOrders = deliveringResult.getOrElse(() => []);
    final historyOrders = historyResult.getOrElse(() => []);

    // حفظ وضعیت لودینگ دکمه‌ها
    Set<int> currentUpdatingIds = {};
    if (state is OrderManagementLoaded) {
      currentUpdatingIds = (state as OrderManagementLoaded).updatingOrderIds;
    }

    emit(OrderManagementLoaded(
      pendingOrders: pendingOrders,
      preparingOrders: preparingOrders,
      deliveringOrders: deliveringOrders,
      historyOrders: historyOrders,
      updatingOrderIds: currentUpdatingIds, // حفظ وضعیت لودینگ
    ));
    // --- پایان بخش اصلاح شده ---

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
          print("Realtime change detected! Refetching orders...");
          loadOrders(); // واکشی مجدد کل داده‌ها
        });
      },
    );
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    final currentState = state;
    if (currentState is! OrderManagementLoaded) return;

    final updatingIds = Set<int>.from(currentState.updatingOrderIds)
      ..add(orderId);
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
        // Realtime (`_listenToChanges`) این تغییر را تشخیص داده
        // و `loadOrders()` را صدا می‌زند که به طور خودکار UI را رفرش می‌کند.
      },
    );
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}