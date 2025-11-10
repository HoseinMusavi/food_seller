// lib/features/settings/presentation/widgets/review_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_seller/core/widgets/custom_network_image.dart';
import 'package:food_seller/features/settings/domain/entities/store_review_entity.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final StoreReviewEntity review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = DateFormat.yMd('fa_IR').add_jm().format(review.createdAt);

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: review.customerAvatarUrl != null
                      ? ClipOval(
                          child: CustomNetworkImage(
                            imageUrl: review.customerAvatarUrl!,
                            width: 40,
                            height: 40,
                          ),
                        )
                      : const Icon(Icons.person_outline, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating.toDouble(),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemSize: 18.0,
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                review.comment!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}