// lib/features/settings/domain/usecases/update_store_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/settings/domain/repositories/settings_repository.dart';

class UpdateStoreStatusUseCase implements UseCase<void, UpdateStoreStatusParams> {
  final SettingsRepository repository;
  UpdateStoreStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStoreStatusParams params) async {
    return await repository.updateStoreStatus(
      storeId: params.storeId,
      isOpen: params.isOpen,
    );
  }
}

class UpdateStoreStatusParams extends Equatable {
  final int storeId;
  final bool isOpen;
  const UpdateStoreStatusParams({required this.storeId, required this.isOpen});
  @override
  List<Object?> get props => [storeId, isOpen];
}