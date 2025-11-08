// lib/features/orders/presentation/cubit/order_details_cubit.dart
import 'package:bloc/bloc.dart';


import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/usecases/get_order_details_usecase.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final GetOrderDetailsUseCase getOrderDetailsUseCase;

  OrderDetailsCubit({required this.getOrderDetailsUseCase})
      : super(OrderDetailsInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> fetchOrderDetails(int orderId) async {
    emit(OrderDetailsLoading());
    final result =
        await getOrderDetailsUseCase(GetOrderDetailsParams(orderId: orderId));

    result.fold(
      (failure) => emit(OrderDetailsError(_mapFailureToMessage(failure))),
      (order) => emit(OrderDetailsLoaded(order)),
    );
  }
}