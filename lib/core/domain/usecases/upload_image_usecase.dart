// lib/core/domain/usecases/upload_image_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/data/datasources/storage_remote_datasource.dart';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/core/usecase/usecase.dart';
// (ما باید یک ریپازیتوری هم بسازیم)

// ابتدا ریپازیتوری انتزاعی را تعریف می‌کنیم
abstract class StorageRepository {
  Future<Either<Failure, String>> uploadFile(UploadFileParams params);
}

// سپس پیاده‌سازی آن
class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource remoteDataSource;
  StorageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> uploadFile(UploadFileParams params) async {
    try {
      final url = await remoteDataSource.uploadFile(
        file: params.file,
        bucketName: params.bucketName,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}

// و در نهایت UseCase
class UploadImageUseCase implements UseCase<String, UploadFileParams> {
  final StorageRepository repository;
  UploadImageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadFileParams params) async {
    return await repository.uploadFile(params);
  }
}

class UploadFileParams extends Equatable {
  final File file;
  final String bucketName;
  const UploadFileParams({required this.file, required this.bucketName});
  @override
  List<Object?> get props => [file, bucketName];
}