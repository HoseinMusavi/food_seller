// lib/core/utils/lat_lng.dart
// یک کلاس ساده برای نگهداری مختصات
// (این در اپ مشتری هم بود، اینجا هم لازمش داریم)

import 'package:equatable/equatable.dart';

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}