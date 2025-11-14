// lib/features/settings/domain/usecases/update_store_logo_url_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/settings/domain/repositories/settings_repository.dart';

class UpdateStoreLogoUrlUseCase
    implements UseCase<void, UpdateStoreLogoUrlParams> {
  final SettingsRepository repository;
  UpdateStoreLogoUrlUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStoreLogoUrlParams params) async {
    return await repository.updateStoreLogoUrl(
      storeId: params.storeId,
      newLogoUrl: params.newLogoUrl,
    );
  }
}

class UpdateStoreLogoUrlParams extends Equatable {
  final int storeId;
  final String newLogoUrl;

  const UpdateStoreLogoUrlParams(
      {required this.storeId, required this.newLogoUrl});

  @override
  List<Object?> get props => [storeId, newLogoUrl];
}