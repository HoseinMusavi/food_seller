// lib/features/orders/presentation/pages/order_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/core/di/service_locator.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/domain/entities/order_item_entity.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_details_cubit.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<OrderDetailsCubit>()..fetchOrderDetails(orderId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('جزئیات سفارش #$orderId'),
        ),
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OrderDetailsError) {
              return Center(child: Text('خطا: ${state.message}'));
            }
            if (state is OrderDetailsLoaded) {
              return _buildOrderDetails(context, state.order);
            }
            return const Center(child: Text('در حال بارگذاری...'));
          },
        ),
        // دکمه‌های مدیریت در پایین صفحه
        // (فعلاً غیرفعال تا از شلوغی جلوگیری شود، چون دکمه‌ها در کارت هم هستند)
        // bottomNavigationBar: _buildActionButtons(context, state),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // بخش ۱: اطلاعات مشتری
        _buildSectionCard(
          theme,
          title: 'اطلاعات مشتری',
          icon: Icons.person_outline,
          children: [
            _buildInfoRow(theme, 'نام', order.customer?.fullName ?? 'نامشخص'),
            _buildInfoRow(theme, 'تلفن', order.customer?.phone ?? 'نامشخص'),
          ],
        ),
        const SizedBox(height: 16),

        // بخش ۲: آدرس تحویل
        _buildSectionCard(
          theme,
          title: 'آدرس تحویل',
          icon: Icons.location_on_outlined,
          children: [
            _buildInfoRow(theme, 'عنوان', order.address?.title ?? 'نامشخص'),
            _buildInfoRow(
                theme, 'آدرس کامل', order.address?.fullAddress ?? 'نامشخص'),
          ],
        ),
        const SizedBox(height: 16),

        // بخش ۳: آیتم‌های سفارش (مهم‌ترین بخش)
        _buildSectionCard(
          theme,
          title: 'آیتم‌های سفارش (${order.items.length})',
          icon: Icons.list_alt_outlined,
          children: [
            for (var item in order.items) _buildOrderItemTile(theme, item),
          ],
        ),
        const SizedBox(height: 16),

        // بخش ۴: یادداشت مشتری
        if (order.notes != null && order.notes!.isNotEmpty) ...[
          _buildSectionCard(
            theme,
            title: 'یادداشت مشتری',
            icon: Icons.notes_outlined,
            children: [
              Text(
                order.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // بخش ۵: خلاصه پرداخت
        _buildSectionCard(
          theme,
          title: 'خلاصه پرداخت',
          icon: Icons.receipt_long_outlined,
          children: [
            _buildPriceRow(theme, 'جمع آیتم‌ها',
                formatCurrency.format(order.subtotalPrice)),
            _buildPriceRow(theme, 'هزینه ارسال',
                formatCurrency.format(order.deliveryFee)),
            if (order.discountAmount > 0)
              _buildPriceRow(
                theme,
                'تخفیف',
                '- ${formatCurrency.format(order.discountAmount)}',
                color: theme.colorScheme.error,
              ),
            const Divider(height: 16),
            _buildPriceRow(
              theme,
              'مبلغ نهایی',
              formatCurrency.format(order.totalPrice),
              isTotal: true,
            ),
          ],
        ),
      ],
    );
  }

  // --- ویجت‌های کمکی ---

  Widget _buildSectionCard(ThemeData theme,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: theme.textTheme.bodySmall),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(ThemeData theme, OrderItemEntity item) {
    String optionsText =
        item.options.map((o) => '${o.optionGroupName}: ${o.optionName}').join('\n');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.quantity}x',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (optionsText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      optionsText,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(ThemeData theme, String label, String value,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.bodyLarge
                : theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: (isTotal
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.bodyLarge)
                ?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? (isTotal ? theme.colorScheme.primary : null),
            ),
          ),
        ],
      ),
    );
  }
}