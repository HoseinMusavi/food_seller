// lib/features/product/presentation/cubit/product_editor_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:food_seller/core/domain/usecases/upload_image_usecase.dart';
import 'package:food_seller/core/error/failure.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/domain/usecases/create_product_usecase.dart';
import 'package:image_picker/image_picker.dart';

part 'product_editor_state.dart';

class ProductEditorCubit extends Cubit<ProductEditorState> {
  final CreateProductUseCase createProductUseCase;
  final UploadImageUseCase uploadImageUseCase; 
  final ImagePicker _picker = ImagePicker(); 

  File? _pickedFile;
  String? _uploadedImageUrl;

  ProductEditorCubit({
    required this.createProductUseCase,
    required this.uploadImageUseCase, 
  }) : super(ProductEditorInitial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'یک خطای ناشناخته رخ داد';
  }

  // *** شروع بخش اصلاح شده ***
  /// (جدید) - انتخاب عکس از گالری یا دوربین
  Future<void> pickImage(ImageSource source) async {
    // اگر در حال ذخیره هستیم، اجازه انتخاب عکس جدید نده
    if (state is ProductEditorSaving) return;

    emit(ProductEditorImageLoading()); // نمایش لودر کوچک روی عکس
    try {
      final XFile? image = await _picker.pickImage(
        source: source, // <-- از پارامتر ورودی استفاده می‌کند
        maxWidth: 800, 
        imageQuality: 85,
      );

      if (image != null) {
        _pickedFile = File(image.path);
        _uploadedImageUrl = null; 
        emit(ProductEditorImageLoaded(pickedFile: _pickedFile));
      } else {
        // کاربر انتخاب را لغو کرد
        emit(ProductEditorInitial());
      }
    } catch (e) {
      emit(ProductEditorError('خطا در انتخاب عکس: ${e.toString()}'));
    }
  }
  // *** پایان بخش اصلاح شده ***


  Future<String?> _uploadImage() async {
    if (_pickedFile == null) return null; 
    if (_uploadedImageUrl != null) return _uploadedImageUrl; 

    emit(ProductEditorSaving()); 

    final result = await uploadImageUseCase(UploadFileParams(
      file: _pickedFile!,
      bucketName: 'products', 
    ));

    return result.fold(
      (failure) {
        emit(ProductEditorError(_mapFailureToMessage(failure)));
        return null; 
      },
      (url) {
        _uploadedImageUrl = url; 
        emit(ProductEditorImageLoaded(
            pickedFile: _pickedFile, uploadedImageUrl: url));
        return url; 
      },
    );
  }

  Future<void> saveNewProduct({
    required String name,
    required String description,
    required double price,
    required int? categoryId,
    required int storeId,
  }) async {
    emit(ProductEditorSaving());

    String? imageUrl;
    if (_pickedFile != null) {
      imageUrl = await _uploadImage();
      if (imageUrl == null) {
        return; 
      }
    } else {
      emit(const ProductEditorError('لطفا یک عکس برای محصول انتخاب کنید.'));
      return;
    }

    final newProduct = ProductEntity(
      id: 0,
      storeId: storeId,
      name: name,
      description: description,
      price: price,
      discountPrice: null,
      imageUrl: imageUrl, 
      isAvailable: true, 
      categoryId: categoryId,
    );

    final result = await createProductUseCase(newProduct);

    result.fold(
      (failure) => emit(ProductEditorError(_mapFailureToMessage(failure))),
      (createdProduct) => emit(ProductEditorSaveSuccess(createdProduct)),
    );
  }
}