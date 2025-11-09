// lib/features/product/presentation/cubit/product_editor_state.dart
part of 'product_editor_cubit.dart';

abstract class ProductEditorState extends Equatable {
  const ProductEditorState();
  @override
  List<Object?> get props => [];
}

class ProductEditorInitial extends ProductEditorState {}

class ProductEditorLoading extends ProductEditorState {} // برای لود اولیه کل صفحه

class ProductEditorError extends ProductEditorState {
  final String message;
  const ProductEditorError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductEditorSaving extends ProductEditorState {} // برای ذخیره نهایی

class ProductEditorSaveSuccess extends ProductEditorState {
  final ProductEntity product;
  const ProductEditorSaveSuccess(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductEditorImageLoading extends ProductEditorState {} // برای لودر روی عکس

class ProductEditorImageLoaded extends ProductEditorState {
  final File? pickedFile;
  final String? uploadedImageUrl;
  
  const ProductEditorImageLoaded({this.pickedFile, this.uploadedImageUrl});
  
  @override
  List<Object?> get props => [pickedFile, uploadedImageUrl];
}

// *** وضعیت جدید برای مدیریت آپشن‌ها ***
// این وضعیت اصلی صفحه پس از لود شدن است
class ProductEditorDataLoaded extends ProductEditorState {
  // تمام گروه‌های آپشن موجود در این فروشگاه (مثلاً "سایز"، "افزودنی")
  final List<OptionGroupEntity> allOptionGroups;
  // ID گروه‌هایی که به این محصول خاص لینک شده‌اند
  final Set<int> linkedGroupIds;
  
  // برای نمایش لودر هنگام ایجاد گروه یا آپشن جدید
  final bool isOptionsBusy; 
  // برای لودر روی عکس (ادغام شد)
  final bool isImageLoading;
  // برای فایل عکس (ادغام شد)
  final File? pickedFile;

  const ProductEditorDataLoaded({
    required this.allOptionGroups,
    required this.linkedGroupIds,
    this.isOptionsBusy = false,
    this.isImageLoading = false,
    this.pickedFile,
  });

  ProductEditorDataLoaded copyWith({
    List<OptionGroupEntity>? allOptionGroups,
    Set<int>? linkedGroupIds,
    bool? isOptionsBusy,
    bool? isImageLoading,
    File? pickedFile,
    bool clearPickedFile = false, // برای پاک کردن عکس
  }) {
    return ProductEditorDataLoaded(
      allOptionGroups: allOptionGroups ?? this.allOptionGroups,
      linkedGroupIds: linkedGroupIds ?? this.linkedGroupIds,
      isOptionsBusy: isOptionsBusy ?? this.isOptionsBusy,
      isImageLoading: isImageLoading ?? this.isImageLoading,
      pickedFile: clearPickedFile ? null : pickedFile ?? this.pickedFile,
    );
  }

  @override
  List<Object?> get props => [allOptionGroups, linkedGroupIds, isOptionsBusy, isImageLoading, pickedFile];
}