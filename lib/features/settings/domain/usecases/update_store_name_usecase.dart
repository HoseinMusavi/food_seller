// lib/features/settings/domain/usecases/update_store_name_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
import 'package:food_seller/features/settings/domain/repositories/settings_repository.dart';

class UpdateStoreNameUseCase
    implements UseCase<void, UpdateStoreNameParams> {
  final SettingsRepository repository;
  UpdateStoreNameUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateStoreNameParams params) async {
    return await repository.updateStoreName(
      storeId: params.storeId,
      newName: params.newName,
    );
  }
}

class UpdateStoreNameParams extends Equatable {
  final int storeId;
  final String newName;

  const UpdateStoreNameParams({required this.storeId, required this.newName});

  @override
  List<Object?> get props => [storeId, newName];
}