// lib/features/settings/presentation/cubit/reviews_state.dart
part of 'reviews_cubit.dart';

abstract class ReviewsState extends Equatable {
  const ReviewsState();
  @override
  List<Object> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsError extends ReviewsState {
  final String message;
  const ReviewsError(this.message);
  @override
  List<Object> get props => [message];
}

class ReviewsLoaded extends ReviewsState {
  final List<StoreReviewEntity> reviews;
  const ReviewsLoaded(this.reviews);
  @override
  List<Object> get props => [reviews];
}