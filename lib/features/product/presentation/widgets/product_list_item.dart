// lib/features/product/presentation/widgets/product_list_item.dart
import 'package:flutter/material.dart';
// *** ایمپورت جدید ویجت تصویر ***
import 'package:food_seller/core/widgets/custom_network_image.dart'; 
import 'package:food_seller/features/product/domain/entities/product_entity.dart';
import 'package:intl/intl.dart';

// --- ویجت CustomNetworkImage از این فایل حذف شد ---
// (چون به فایل core/widgets منتقل شد)

class ProductListItem extends StatelessWidget {
  final ProductEntity product;
  final bool isToggling; // آیا این آیتم در حال آپدیت شدن است؟
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onTap;

  const ProductListItem({
    super.key,
    required this.product,
    required this.isToggling,
    required this.onAvailabilityChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );

    // تغییر شفافیت ویجت اگر موجود نباشد
    return Opacity(
      opacity: product.isAvailable ? 1.0 : 0.6,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // تصویر محصول
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CustomNetworkImage( // <-- اکنون از ویجت ایمپورت شده استفاده می‌کند
                    imageUrl: product.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // نام و قیمت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: product.isAvailable
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency.format(product.finalPrice),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // دکمه Switch (مهم‌ترین بخش)
                if (isToggling)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Switch(
                    value: product.isAvailable,
                    onChanged: onAvailabilityChanged,
                    // *** شروع بخش اصلاح شده ***
                    // 'activeColor' با 'activeThumbColor' جایگزین شد
                    activeThumbColor: theme.colorScheme.primary, 
                    // (اختیاری) رنگ ترک (track) را هم برای زیبایی اضافه می‌کنیم
                    activeTrackColor: theme.colorScheme.primary.withAlpha(100),
                    // *** پایان بخش اصلاح شده ***
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}