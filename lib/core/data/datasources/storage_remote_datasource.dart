// lib/core/data/datasources/storage_remote_datasource.dart
import 'dart:io';
import 'package:food_seller/core/error/exceptions.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StorageRemoteDataSource {
  /// فایل را در باکت مشخص شده آپلود می‌کند و URL عمومی آن را برمی‌گرداند
  Future<String> uploadFile({
    required File file,
    required String bucketName,
  });
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final SupabaseClient supabaseClient;

  StorageRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<String> uploadFile({
    required File file,
    required String bucketName,
  }) async {
    try {
      // ۱. یک نام فایل منحصر به فرد بر اساس زمان فعلی و پسوند فایل می‌سازیم
      final fileBytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName; // (در آینده می‌توان در پوشه‌های storeId ذخیره کرد)

      // ۲. نوع فایل (MIME type) را تشخیص می‌دهیم
      final mimeType = lookupMimeType(file.path);

      // ۳. آپلود فایل در Supabase Storage
      await supabaseClient.storage.from(bucketName).uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: false, // اگر فایل وجود داشت، خطا بده
            ),
          );

      // ۴. دریافت URL عمومی فایل آپلود شده
      final publicUrl = supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(message: 'خطا در آپلود فایل: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'خطای ناشناخته: ${e.toString()}');
    }
  }
}