// lib/features/settings/domain/usecases/get_store_details_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/orders/domain/entities/store_entity.dart';
import 'package:food_seller/features/settings/domain/repositories/settings_repository.dart';

class GetStoreDetailsUseCase implements UseCase<StoreEntity, GetStoreDetailsParams> {
  final SettingsRepository repository;
  GetStoreDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, StoreEntity>> call(GetStoreDetailsParams params) async {
    return await repository.getStoreDetails(params.storeId);
  }
}

class GetStoreDetailsParams extends Equatable {
  final int storeId;
  const GetStoreDetailsParams({required this.storeId});
  @override
  List<Object?> get props => [storeId];
}