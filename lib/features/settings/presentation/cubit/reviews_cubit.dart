// lib/features/settings/presentation/cubit/reviews_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/settings/domain/entities/store_review_entity.dart';
import 'package:food_seller/features/settings/domain/usecases/get_store_reviews_usecase.dart';

part 'reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsState> {
  final GetStoreReviewsUseCase getStoreReviewsUseCase;
  final int storeId;

  ReviewsCubit({
    required this.getStoreReviewsUseCase,
    required this.storeId,
  }) : super(ReviewsInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  Future<void> loadReviews() async {
    emit(ReviewsLoading());
    final result =
        await getStoreReviewsUseCase(GetStoreReviewsParams(storeId: storeId));

    result.fold(
      (failure) => emit(ReviewsError(_mapFailureToMessage(failure))),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }
}