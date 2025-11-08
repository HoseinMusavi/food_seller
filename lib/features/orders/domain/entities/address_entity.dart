// lib/features/orders/domain/entities/address_entity.dart
import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final int? id;
  final String customerId;
  final String title;
  final String fullAddress;
  final String? postalCode;
  final String? city;
  final double latitude;
  final double longitude;

  const AddressEntity({
    this.id,
    required this.customerId,
    required this.title,
    required this.fullAddress,
    this.postalCode,
    this.city,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        title,
        fullAddress,
        postalCode,
        city,
        latitude,
        longitude
      ];
}