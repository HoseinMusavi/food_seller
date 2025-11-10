// lib/features/settings/presentation/pages/store_reviews_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/settings/presentation/cubit/reviews_cubit.dart';
import 'package:food_seller/features/settings/presentation/widgets/review_card.dart';

class StoreReviewsPage extends StatelessWidget {
  final int storeId;
  const StoreReviewsPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReviewsCubit>(param1: storeId)..loadReviews(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظرات مشتریان'),
        ),
        body: BlocBuilder<ReviewsCubit, ReviewsState>(
          builder: (context, state) {
            if (state is ReviewsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ReviewsError) {
              return Center(child: Text('خطا: ${state.message}'));
            }
            if (state is ReviewsLoaded) {
              if (state.reviews.isEmpty) {
                return const Center(
                    child: Text('هنوز نظری برای فروشگاه شما ثبت نشده است.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: state.reviews.length,
                itemBuilder: (context, index) {
                  return ReviewCard(review: state.reviews[index]);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}