// lib/features/orders/presentation/cubit/order_details_state.dart
part of 'order_details_cubit.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();
  @override
  List<Object> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsError extends OrderDetailsState {
  final String message;
  const OrderDetailsError(this.message);
  @override
  List<Object> get props => [message];
}

class OrderDetailsLoaded extends OrderDetailsState {
  final OrderEntity order;
  const OrderDetailsLoaded(this.order);
  @override
  List<Object> get props => [order];
}