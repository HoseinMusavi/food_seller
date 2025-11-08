// lib/features/orders/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
// *** ایمپورت مدل مشتری که الان ساختیم ***
import 'package:food_seller/features/orders/data/models/customer_model.dart'; 
import 'order_item_entity.dart';
import 'store_entity.dart'; 
import 'address_entity.dart'; 

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  delivering,
  delivered,
  cancelled,
}

class OrderEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String customerId;
  final int? storeId;
  final int? addressId;
  final double subtotalPrice;
  final double deliveryFee;
  final double discountAmount;
  final double totalPrice;
  final OrderStatus status;
  final List<OrderItemEntity> items;
  final StoreEntity? store;
  final AddressEntity? address;
  
  // *** فیلد جدید اضافه شد ***
  final CustomerModel? customer; // برای نگهداری نام مشتری

  final String? estimatedDeliveryTime;
  final String? notes;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.customerId,
    this.storeId,
    this.addressId,
    required this.subtotalPrice,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalPrice,
    required this.status,
    required this.items,
    this.store,
    this.address,
    this.customer, // *** اضافه شد به constructor ***
    this.estimatedDeliveryTime,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        customerId,
        storeId,
        addressId,
        subtotalPrice,
        deliveryFee,
        discountAmount,
        totalPrice,
        status,
        items,
        store,
        address,
        customer, // *** اضافه شد به props ***
        estimatedDeliveryTime,
        notes,
      ];

  // (متد copyWith برای سادگی فعلاً آپدیت نشده، اما مشکلی ایجاد نمی‌کند)
  // ... copyWith ...
}

extension OrderStatusExtension on String {
  OrderStatus toOrderStatus() {
    try {
      return OrderStatus.values.firstWhere((e) => e.name == this);
    } catch (e) {
      print('!!! Unknown OrderStatus: $this');
      return OrderStatus.pending;
    }
  }
}