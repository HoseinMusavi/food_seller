// lib/features/settings/domain/entities/store_review_entity.dart
import 'package:equatable/equatable.dart';

class StoreReviewEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final int rating;
  final String? comment;
  final String customerName;
  final String? customerAvatarUrl;

  const StoreReviewEntity({
    required this.id,
    required this.createdAt,
    required this.rating,
    this.comment,
    required this.customerName,
    this.customerAvatarUrl,
  });

  @override
  List<Object?> get props =>
      [id, createdAt, rating, comment, customerName, customerAvatarUrl];
}