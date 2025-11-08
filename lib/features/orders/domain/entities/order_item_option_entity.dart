// lib/features/orders/domain/entities/order_item_option_entity.dart
import 'package:equatable/equatable.dart';

class OrderItemOptionEntity extends Equatable {
  final String optionGroupName;
  final String optionName;
  final double priceDelta;

  const OrderItemOptionEntity({
    required this.optionGroupName,
    required this.optionName,
    required this.priceDelta,
  });

  @override
  List<Object?> get props => [optionGroupName, optionName, priceDelta];
}