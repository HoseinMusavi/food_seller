// lib/features/product/presentation/pages/menu_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/features/product/domain/entities/product_category_entity.dart';
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:food_seller/features/product/presentation/cubit/menu_management_cubit.dart';
import 'package:food_seller/features/product/presentation/widgets/product_list_item.dart';

class MenuManagementPage extends StatelessWidget {
  const MenuManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menuCubit = context.read<MenuManagementCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت منو'),
      ),
      body: BlocConsumer<MenuManagementCubit, MenuManagementState>(
        listener: (context, state) {
          if (state is MenuManagementError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is MenuManagementLoading || state is MenuManagementInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MenuManagementLoaded) {
            if (state.products.isEmpty && state.categories.isEmpty) {
              return const Center(
                  child: Text('هنوز هیچ محصول یا دسته‌بندی ثبت نکرده‌اید.'));
            }
            return _buildMenu(context, state, menuCubit);
          }

          if (state is MenuManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => menuCubit.loadMenu(),
                    child: const Text('تلاش مجدد'),
                  )
                ],
              ),
            );
          }

          return const Center(child: Text('وضعیت نامشخص'));
        },
      ),
      floatingActionButton: BlocBuilder<MenuManagementCubit, MenuManagementState>(
        builder: (context, state) {
          if (state is! MenuManagementLoaded) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/add-product', 
                arguments: {
                  'storeId': menuCubit.storeId,
                  'categories': state.categories,
                  'menuCubit': menuCubit,
                },
              );
              
              if (result == true && context.mounted) {
                context.read<MenuManagementCubit>().loadMenu();
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildMenu(BuildContext context, MenuManagementLoaded state,
      MenuManagementCubit menuCubit) {
    final Map<int?, List<ProductEntity>> productsByCategory = {};
    for (var product in state.products) {
      productsByCategory.putIfAbsent(product.categoryId, () => []).add(product);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await menuCubit.loadMenu();
      },
      child: ListView.builder(
        itemCount: state.categories.length + 1,
        itemBuilder: (context, index) {
          ProductCategoryEntity? category;
          List<ProductEntity> productsInThisCategory;

          if (index < state.categories.length) {
            category = state.categories[index];
            productsInThisCategory = productsByCategory[category.id] ?? [];
          } else {
            category = null;
            productsInThisCategory = productsByCategory[null] ?? [];
            if (productsInThisCategory.isEmpty && state.categories.isNotEmpty) {
              return const SizedBox.shrink();
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)
                        .copyWith(top: 24.0),
                child: Text(
                  category?.name ?? 'سایر محصولات',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (productsInThisCategory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'محصولی در این دسته‌بندی وجود ندارد.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productsInThisCategory.length,
                  itemBuilder: (ctx, productIndex) {
                    final product = productsInThisCategory[productIndex];
                    return ProductListItem(
                      product: product,
                      isToggling: state.togglingProductIds.contains(product.id),
                      onAvailabilityChanged: (isAvailable) {
                        menuCubit.toggleProductAvailability(
                          productId: product.id,
                          isAvailable: isAvailable,
                        );
                      },
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/edit-product', 
                          arguments: {
                            'product': product, 
                            'categories': state.categories,
                            'menuCubit': menuCubit,
                          },
                        );
                        if (result == true && context.mounted) {
                          menuCubit.loadMenu();
                        }
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}