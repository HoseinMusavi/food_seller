// lib/features/orders/presentation/widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isLoading;
  final Function(OrderStatus) onUpdateStatus; // تابع آپدیت وضعیت
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.isLoading,
    required this.onUpdateStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );

    String timeAgo(DateTime dt) {
      final duration = DateTime.now().difference(dt);
      if (duration.inMinutes < 1) return 'همین الان';
      if (duration.inHours < 1) return '${duration.inMinutes} دقیقه قبل';
      if (duration.inDays < 1) return '${duration.inHours} ساعت قبل';
      return '${duration.inDays} روز قبل';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ردیف بالا: شماره سفارش و زمان ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سفارش #${order.id}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timeAgo(order.createdAt),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // *** مشکل ۱ حل شد: نمایش نام مشتری ***
              Text(
                'مشتری: ${order.customer?.fullName ?? 'نامشخص'}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Divider(height: 20),

              // *** مشکل ۲ حل شد: نمایش آیتم‌های سفارش ***
              _buildOrderItemsSummary(context, theme),
              const SizedBox(height: 12),

              // --- اطلاعات قیمت ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مبلغ کل:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    formatCurrency.format(order.totalPrice),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // *** مشکل ۳ حل شد: دکمه‌های کامل چرخه سفارش ***
              _buildActionButtons(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت جدید برای نمایش خلاصه آیتم‌ها
  Widget _buildOrderItemsSummary(BuildContext context, ThemeData theme) {
    if (order.items.isEmpty) {
      return const Text(
        'جزئیات آیتم‌ها بارگذاری نشد.',
        style: TextStyle(color: Colors.red),
      );
    }
    
    // نمایش ۳ آیتم اول
    final itemsToShow = order.items.take(3);
    final remainingCount = order.items.length - itemsToShow.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...itemsToShow.map((item) {
          String optionsText = item.options.map((o) => o.optionName).join('، ');
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Text(
                  '${item.quantity}x',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.productName + (optionsText.isNotEmpty ? ' ($optionsText)' : ''),
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '+ $remainingCount آیتم دیگر...',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
      ],
    );
  }

  // ویجت بازطراحی شده برای دکمه‌های اکشن
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // بر اساس وضعیت سفارش، دکمه مناسب را نشان بده
    switch (order.status) {
      case OrderStatus.pending:
        // تب "جدید": دکمه تایید و رد
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onUpdateStatus(OrderStatus.confirmed),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // سبز
                ),
                child: const Text('تایید سفارش'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onUpdateStatus(OrderStatus.cancelled),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error, // قرمز
                ),
                child: const Text('رد سفارش'),
              ),
            ),
          ],
        );

      case OrderStatus.confirmed:
        // تب "در حال انجام": دکمه شروع آماده‌سازی
        return ElevatedButton.icon(
          icon: const Icon(Icons.kitchen_outlined),
          label: const Text('شروع آماده‌سازی'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withAlpha(200),
            minimumSize: const Size(double.infinity, 44),
          ),
          onPressed: () => onUpdateStatus(OrderStatus.preparing),
        );

      case OrderStatus.preparing:
        // تب "در حال انجام": دکمه ارسال
        return ElevatedButton.icon(
          icon: const Icon(Icons.delivery_dining_outlined),
          label: const Text('ارسال شد (تحویل به پیک)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            minimumSize: const Size(double.infinity, 44),
          ),
          onPressed: () => onUpdateStatus(OrderStatus.delivering),
        );

      // برای بقیه وضعیت‌ها، فقط متن وضعیت را نشان بده
      case OrderStatus.delivering:
        return _buildStatusChip('در حال ارسال به مشتری', Colors.blue.shade600);
      case OrderStatus.delivered:
        return _buildStatusChip('تحویل داده شد', Colors.grey.shade700);
      case OrderStatus.cancelled:
        return _buildStatusChip('لغو شده', theme.colorScheme.error);
    }
  }

  Widget _buildStatusChip(String text, Color color) {
    return Center(
      child: Chip(
        label: Text(text),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}