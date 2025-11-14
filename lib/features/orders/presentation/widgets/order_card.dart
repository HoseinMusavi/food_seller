// lib/features/orders/presentation/widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isLoading;
  final ValueChanged<OrderStatus> onUpdateStatus;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.isLoading,
    required this.onUpdateStatus,
    required this.onTap,
  });

  // --- توابع کمکی برای استایل‌دهی ---

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'جدید';
      case OrderStatus.confirmed:
        return 'تأیید شده';
      case OrderStatus.preparing:
        return 'در حال آماده‌سازی';
      case OrderStatus.delivering:
        return 'در حال ارسال';
      case OrderStatus.delivered:
        return 'تحویل داده شد';
      case OrderStatus.cancelled:
        return 'لغو شده';
    }
  }

  Color _getStatusColor(OrderStatus status, ThemeData theme) {
    switch (status) {
      case OrderStatus.pending:
        return theme.colorScheme.error;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
      case OrderStatus.delivering:
        return theme.colorScheme.primary;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return theme.colorScheme.outline;
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm - yyyy/MM/dd', 'fa_IR').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status, theme);
    final itemNames = order.items.map((e) => 'x${e.quantity} ${e.productName}').join('، ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ردیف هدر: شماره سفارش و وضعیت ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سفارش #${order.id}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- اطلاعات مشتری و زمان ---
              Text(
                order.customer?.fullName ?? 'مشتری',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                _formatTime(order.createdAt),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const Divider(height: 20),

              // --- آیتم‌ها و قیمت ---
              Text(
                itemNames,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مبلغ نهایی', style: theme.textTheme.bodyMedium),
                  Text(
                    _formatCurrency(order.totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              // --- دکمه‌های عملیات ---
              if (_buildActionButtons(theme).isNotEmpty) ...[
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: _buildActionButtons(theme),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- بخش کلیدی: منطق دکمه‌ها ---
  // (دکمه "رد" برای Pending حذف شده است)
  List<Widget> _buildActionButtons(ThemeData theme) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary),
              onPressed: () => onUpdateStatus(OrderStatus.confirmed),
              child: const Text('تأیید سفارش'),
            ),
          ),
          // دکمه لغو در این مرحله وجود ندارد
        ];

      case OrderStatus.confirmed:
        return [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary),
              onPressed: () => onUpdateStatus(OrderStatus.preparing),
              child: const Text('آماده‌سازی شد'),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => onUpdateStatus(OrderStatus.cancelled),
            child: const Text('لغو سفارش'),
          ),
        ];

      case OrderStatus.preparing:
        return [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary),
              onPressed: () => onUpdateStatus(OrderStatus.delivering),
              child: const Text('ارسال شد'),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => onUpdateStatus(OrderStatus.cancelled),
            child: const Text('لغو سفارش'),
          ),
        ];

      case OrderStatus.delivering:
        return [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => onUpdateStatus(OrderStatus.delivered),
              child: const Text('تحویل داده شد'),
            ),
          ),
        ];

      // برای سفارش‌های تحویل‌شده یا لغوشده، دکمه‌ای وجود ندارد
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return [];
    }
  }
}