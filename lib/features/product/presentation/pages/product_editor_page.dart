// lib/features/product/presentation/pages/product_editor_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/core/widgets/custom_network_image.dart'; // *** ایمپورت ویجت عکس ***
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';
import 'package:food_seller/features/product/presentation/cubit/product_editor_cubit.dart';
import 'package:image_picker/image_picker.dart'; // *** ایمپورت ImageSource ***

class ProductEditorPage extends StatelessWidget {
  final int storeId;
  final List<ProductCategoryEntity> categories;
  // final ProductEntity? productToEdit;

  const ProductEditorPage({
    super.key,
    required this.storeId,
    required this.categories,
    // this.productToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProductEditorCubit>(),
      child: _ProductEditorView(
        storeId: storeId,
        categories: categories,
      ),
    );
  }
}

class _ProductEditorView extends StatefulWidget {
  final int storeId;
  final List<ProductCategoryEntity> categories;
  
  const _ProductEditorView({
    required this.storeId,
    required this.categories,
  });

  @override
  State<_ProductEditorView> createState() => _ProductEditorViewState();
}

class _ProductEditorViewState extends State<_ProductEditorView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  int? _selectedCategoryId;

  File? _imageFile;
  String? _networkImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    
    context.read<ProductEditorCubit>().saveNewProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.tryParse(_priceController.text) ?? 0.0,
          categoryId: _selectedCategoryId,
          storeId: widget.storeId,
        );
  }

  // *** متد جدید برای نمایش انتخاب منبع عکس ***
  void _showImageSourceSheet(BuildContext context) {
    final cubit = context.read<ProductEditorCubit>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('انتخاب از گالری'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('گرفتن عکس با دوربین'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  cubit.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('افزودن محصول جدید'),
      ),
      body: BlocConsumer<ProductEditorCubit, ProductEditorState>(
        listener: (context, state) {
          if (state is ProductEditorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is ProductEditorSaveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('محصول "${state.product.name}" با موفقیت ذخیره شد.'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            Navigator.pop(context, true); // true = رفرش کن
          }
          
          if (state is ProductEditorImageLoaded) {
            setState(() {
              _imageFile = state.pickedFile;
              _networkImageUrl = state.uploadedImageUrl;
            });
          }
        },
        builder: (context, state) {
          final isFormLoading = state is ProductEditorSaving || state is ProductEditorLoading;
          final isImageLoading = state is ProductEditorImageLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // *** بخش آپلود عکس (اصلاح شده) ***
                  GestureDetector(
                    // *** onTap اصلاح شد ***
                    onTap: isFormLoading
                        ? null
                        : () => _showImageSourceSheet(context),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      clipBehavior: Clip.antiAlias, // برای گرد کردن گوشه‌های عکس
                      child: isImageLoading
                          ? Center(child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ))
                          : (_imageFile != null
                              ? Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                )
                              : (_networkImageUrl != null
                                  ? CustomNetworkImage( // استفاده از ویجت خودمان
                                      imageUrl: _networkImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Colors.grey[600],
                                        size: 50,
                                      ),
                                    ))),
                    ),
                  ),
                  // ... (بقیه فرم بدون تغییر) ...
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    readOnly: isFormLoading,
                    decoration: const InputDecoration(labelText: 'نام محصول'),
                    validator: (v) => (v == null || v.isEmpty) ? 'نام الزامی است' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    readOnly: isFormLoading,
                    decoration: const InputDecoration(labelText: 'توضیحات'),
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    readOnly: isFormLoading,
                    decoration: const InputDecoration(
                      labelText: 'قیمت (تومان)',
                      prefixIcon: Icon(Icons.price_change_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'قیمت الزامی است';
                      if ((double.tryParse(v) ?? 0) <= 0) return 'قیمت باید معتبر باشد';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    hint: const Text('انتخاب دسته‌بندی (اختیاری)'),
                    decoration: const InputDecoration(
                      labelText: 'دسته‌بندی',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('بدون دسته‌بندی (سایر)'),
                      ),
                      ...widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: isFormLoading
                        ? null
                        : (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isFormLoading ? null : _onSavePressed,
                    child: isFormLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ذخیره محصول'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}