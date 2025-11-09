// lib/features/product/presentation/cubit/product_editor_state.dart
part of 'product_editor_cubit.dart';

abstract class ProductEditorState extends Equatable {
  const ProductEditorState();
  @override
  List<Object?> get props => [];
}

class ProductEditorInitial extends ProductEditorState {}
class ProductEditorSaving extends ProductEditorState {}
class ProductEditorLoading extends ProductEditorState {}

class ProductEditorError extends ProductEditorState {
  final String message;
  const ProductEditorError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductEditorSaveSuccess extends ProductEditorState {
  final ProductEntity product;
  const ProductEditorSaveSuccess(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductEditorImageLoading extends ProductEditorState {}

class ProductEditorImageLoaded extends ProductEditorState {
  final File? pickedFile;
  final String? uploadedImageUrl;
  
  const ProductEditorImageLoaded({this.pickedFile, this.uploadedImageUrl});
  
  @override
  List<Object?> get props => [pickedFile, uploadedImageUrl];
}