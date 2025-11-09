// lib/features/product/presentation/cubit/product_editor_state.dart
part of 'product_editor_cubit.dart';

abstract class ProductEditorState extends Equatable {
  const ProductEditorState();
  @override
  List<Object?> get props => [];
}

// وضعیت اولیه، فرم آماده است
class ProductEditorInitial extends ProductEditorState {}

// در حال ذخیره (ایجاد یا ویرایش) محصول
class ProductEditorSaving extends ProductEditorState {}

// در حال واکشی اطلاعات یک محصول (برای حالت ویرایش)
class ProductEditorLoading extends ProductEditorState {}

// خطا در ذخیره یا واکشی
class ProductEditorError extends ProductEditorState {
  final String message;
  const ProductEditorError(this.message);
  @override
  List<Object?> get props => [message];
}

// محصول با موفقیت ذخیره شد
class ProductEditorSaveSuccess extends ProductEditorState {
  final ProductEntity product;
  const ProductEditorSaveSuccess(this.product);
  @override
  List<Object?> get props => [product];
}


// *** وضعیت‌های جدید برای آپلود عکس ***

// در حال انتخاب یا آپلود عکس
class ProductEditorImageLoading extends ProductEditorState {}

// عکس با موفقیت انتخاب شد و آماده آپلود است (یا آپلود شده)
class ProductEditorImageLoaded extends ProductEditorState {
  final File? pickedFile; // فایل انتخاب شده از گالری
  final String? uploadedImageUrl; // لینکی که از Storage می‌آید
  
  const ProductEditorImageLoaded({this.pickedFile, this.uploadedImageUrl});
  
  @override
  List<Object?> get props => [pickedFile, uploadedImageUrl];
}