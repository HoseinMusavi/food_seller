// lib/features/settings/data/models/store_review_model.dart
import 'package:food_seller/features/settings/domain/entities/store_review_entity.dart';

class StoreReviewModel extends StoreReviewEntity {
  const StoreReviewModel({
    required super.id,
    required super.createdAt,
    required super.rating,
    super.comment,
    required super.customerName,
    super.customerAvatarUrl,
  });

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      customerName: json['customer_name'] as String? ?? 'کاربر ناشناس',
      customerAvatarUrl: json['customer_avatar_url'] as String?,
    );
  }
}