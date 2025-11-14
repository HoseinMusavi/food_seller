// lib/features/orders/presentation/pages/order_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/orders/presentation/widgets/order_card.dart';
import 'package:food_seller/features/orders/presentation/pages/order_details_page.dart';

class OrderDashboardPage extends StatefulWidget {
  const OrderDashboardPage({super.key});

  @override
  State<OrderDashboardPage> createState() => _OrderDashboardPageState();
}

class _OrderDashboardPageState extends State<OrderDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- شروع بخش اصلاح شده ---
  @override
  void initState() {
    super.initState();
    // تعداد تب‌ها به ۴ افزایش یافت
    _tabController = TabController(length: 4, vsync: this);
  }
  // --- پایان بخش اصلاح شده ---

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت سفارش‌ها'),
        // --- شروع بخش اصلاح شده ---
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // برای جلوگیری از سرریز در صفحه‌های کوچک
          tabs: [
            // تب ۱: جدید
            BlocBuilder<OrderManagementCubit, OrderManagementState>(
              buildWhen: (p, c) => c is OrderManagementLoaded,
              builder: (context, state) {
                int count = 0;
                if (state is OrderManagementLoaded) {
                  count = state.pendingOrders.length;
                }
                return _buildTab('جدید', count, isPending: true);
              },
            ),
            // تب ۲: آماده‌سازی
            BlocBuilder<OrderManagementCubit, OrderManagementState>(
              buildWhen: (p, c) => c is OrderManagementLoaded,
              builder: (context, state) {
                int count = 0;
                if (state is OrderManagementLoaded) {
                  count = state.preparingOrders.length;
                }
                return _buildTab('آماده‌سازی', count);
              },
            ),
            // تب ۳: در حال ارسال
            BlocBuilder<OrderManagementCubit, OrderManagementState>(
              buildWhen: (p, c) => c is OrderManagementLoaded,
              builder: (context, state) {
                int count = 0;
                if (state is OrderManagementLoaded) {
                  count = state.deliveringOrders.length;
                }
                return _buildTab('در حال ارسال', count);
              },
            ),
            // تب ۴: تاریخچه
            const Tab(text: 'تاریخچه'),
          ],
        ),
        // --- پایان بخش اصلاح شده ---
      ),
      body: BlocConsumer<OrderManagementCubit, OrderManagementState>(
        listener: (context, state) {
          if (state is OrderManagementError) {
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
          if (state is OrderManagementLoading || state is OrderManagementInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderManagementLoaded) {
            // --- شروع بخش اصلاح شده ---
            return TabBarView(
              controller: _tabController,
              children: [
                // تب ۱: جدید (Pending)
                _OrderList(
                  key: const PageStorageKey('pendingOrders'),
                  orders: state.pendingOrders,
                  updatingIds: state.updatingOrderIds,
                  emptyMessage: 'هیچ سفارش جدیدی یافت نشد.',
                ),
                // تب ۲: آماده‌سازی (Confirmed, Preparing)
                _OrderList(
                  key: const PageStorageKey('preparingOrders'),
                  orders: state.preparingOrders,
                  updatingIds: state.updatingOrderIds,
                  emptyMessage: 'هیچ سفارش در حال آماده‌سازی وجود ندارد.',
                ),
                // تب ۳: در حال ارسال (Delivering)
                _OrderList(
                  key: const PageStorageKey('deliveringOrders'),
                  orders: state.deliveringOrders,
                  updatingIds: state.updatingOrderIds,
                  emptyMessage: 'هیچ سفارش در حال ارسالی وجود ندارد.',
                ),
                // تب ۴: تاریخچه (Completed, Cancelled)
                _OrderList(
                  key: const PageStorageKey('historyOrders'),
                  orders: state.historyOrders,
                  updatingIds: state.updatingOrderIds,
                  emptyMessage: 'هیچ سفارشی در تاریخچه یافت نشد.',
                ),
              ],
            );
            // --- پایان بخش اصلاح شده ---
          }

          if (state is OrderManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا: ${state.message}'),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<OrderManagementCubit>().loadOrders(),
                    child: const Text('تلاش مجدد'),
                  )
                ],
              ),
            );
          }

          return const Center(child: Text('وضعیت نامشخص'));
        },
      ),
    );
  }

  // --- ویجت کمکی تب، اصلاح شد ---
  Widget _buildTab(String title, int count, {bool isPending = false}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Badge(
              label: Text(count.toString()),
              backgroundColor: isPending
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

// --- ویجت داخلی برای نمایش لیست سفارش‌های هر تب ---
// (بدون تغییر باقی می‌ماند، چون منطق را به OrderCard منتقل کردیم)
class _OrderList extends StatelessWidget {
  final List<OrderEntity> orders;
  final Set<int> updatingIds;
  final String emptyMessage;

  const _OrderList({
    super.key,
    required this.orders,
    required this.updatingIds,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrderManagementCubit>().loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0), // افزودن پدینگ پایین
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            isLoading: updatingIds.contains(order.id),
            onUpdateStatus: (newStatus) {
              context
                  .read<OrderManagementCubit>()
                  .updateOrderStatus(order.id, newStatus);
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(orderId: order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}