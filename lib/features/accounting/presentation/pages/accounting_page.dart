// lib/features/accounting/presentation/pages/accounting_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/features/accounting/domain/entities/daily_summary_entity.dart';
import 'package:food_seller/features/accounting/presentation/cubit/accounting_cubit.dart';
import 'package:intl/intl.dart';

class AccountingPage extends StatelessWidget {
  const AccountingPage({super.key});

  String _formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency(
      locale: 'fa_IR',
      name: ' تومان',
      decimalDigits: 0,
    );
    return format.format(amount);
  }
  
  String _formatDate(DateTime date) {
    // برای نمایش تاریخ شمسی، پکیج shamsi_date یا معادل آن نیاز است
    // فعلا میلادی نمایش می‌دهیم
    return DateFormat('yyyy/MM/dd').format(date);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AccountingCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابداری'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => cubit.loadAccountingData(),
          ),
        ],
      ),
      body: BlocBuilder<AccountingCubit, AccountingState>(
        builder: (context, state) {
          if (state is AccountingLoading || state is AccountingInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => cubit.loadAccountingData(),
                    child: const Text('تلاش مجدد'),
                  )
                ],
              ),
            );
          }
          if (state is AccountingLoaded) {
            return RefreshIndicator(
              onRefresh: () async => cubit.loadAccountingData(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- بخش فروش امروز ---
                  Text(
                    'فروش امروز (سفارش‌های تحویل‌شده)',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTodaySummaryCard(theme, state.todaySummary),
                  
                  const SizedBox(height: 32),

                  // --- بخش تاریخچه فروش ---
                  Text(
                    'تاریخچه فروش ۳۰ روز گذشته',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  if (state.salesHistory.isEmpty)
                    const Center(child: Text('تاریخچه فروشی یافت نشد.'))
                  else
                    ...state.salesHistory.map((summary) {
                      return _buildHistoryRow(theme, summary);
                    }).toList(),
                ],
              ),
            );
          }
          return const Center(child: Text('وضعیت نامشخص'));
        },
      ),
    );
  }

  Widget _buildTodaySummaryCard(ThemeData theme, DailySummaryEntity summary) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.primary.withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'تعداد سفارش',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  summary.totalOrders.toString(),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            Container(width: 1, height: 50, color: Colors.grey[300]),
            Column(
              children: [
                Text(
                  'مجموع فروش',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  _formatCurrency(summary.totalSales),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(ThemeData theme, DailySummaryEntity summary) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!)
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          _formatDate(summary.salesDate), // TODO: تبدیل به شمسی
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${summary.totalOrders} سفارش موفق'),
        trailing: Text(
          _formatCurrency(summary.totalSales),
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}