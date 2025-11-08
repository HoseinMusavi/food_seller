// lib/features/orders/data/models/store_model.dart
import 'package:food_seller/core/utils/lat_lng.dart';
import 'package:food_seller/features/orders/domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.address,
    required super.logoUrl,
    required super.isOpen,
    required super.rating,
    required super.ratingCount,
    required super.cuisineType,
    required super.deliveryTimeEstimate,
    super.location,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    // تابع کمکی برای پارس کردن موقعیت جغرافیایی
    LatLng? parseLocation(dynamic loc) {
      if (loc == null) return null;
      try {
        if (loc is String && loc.contains('POINT')) {
          final parts = loc.split('(')[1].split(')')[0].split(' ');
          final lon = double.parse(parts[0]);
          final lat = double.parse(parts[1]);
          return LatLng(latitude: lat, longitude: lon);
        }
        if (loc is Map<String, dynamic> && loc['coordinates'] != null) {
           final coordinates = loc['coordinates'] as List;
           return LatLng(
             longitude: (coordinates[0] as num).toDouble(),
             latitude: (coordinates[1] as num).toDouble(),
           );
        }
      } catch (e) {
        print('Error parsing location in StoreModel: $e');
        return null;
      }
      return null;
    }

    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? 'آدرس نامشخص',
      logoUrl: json['logo_url'] as String? ?? '',
      isOpen: json['is_open'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
      cuisineType: json['cuisine_type'] as String? ?? 'متفرقه',
      deliveryTimeEstimate:
          json['delivery_time_estimate'] as String? ?? 'نامشخص',
      location: parseLocation(json['location']),
    );
  }
}