// lib/features/orders/data/models/address_model.dart
import 'package:food_seller/features/orders/domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({
    super.id,
    required super.customerId,
    required super.title,
    required super.fullAddress,
    super.postalCode,
    super.city,
    required super.latitude,
    required super.longitude,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double long = 0.0;

    // ما موقعیت را به صورت 'location:location::text' می‌خوانیم
    if (json['location'] != null && json['location'] is String) {
      try {
        // "POINT(long lat)"
        final parts = json['location']
            .toString()
            .replaceAll('POINT(', '')
            .replaceAll(')', '')
            .split(' ');
        if (parts.length == 2) {
          long = double.parse(parts[0]);
          lat = double.parse(parts[1]);
        }
      } catch (e) {
        print('Error parsing location in AddressModel: $e');
      }
    }

    return AddressModel(
      id: json['id'] as int?,
      customerId: json['customer_id'] as String,
      title: json['title'] as String? ?? 'بدون عنوان',
      fullAddress: json['full_address'] as String? ?? 'آدرس نامشخص',
      postalCode: json['postal_code'] as String?,
      city: json['city'] as String?,
      latitude: lat,
      longitude: long,
    );
  }
}