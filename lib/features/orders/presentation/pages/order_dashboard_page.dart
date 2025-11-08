// lib/features/orders/presentation/pages/order_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_seller/features/orders/domain/entities/order_entity.dart';
import 'package:food_seller/features/orders/presentation/cubit/order_management_cubit.dart';
import 'package:food_seller/features/orders/presentation/widgets/order_card.dart';
// *** ایمپورت جدید صفحه جزئیات ***
import 'package:food_seller/features/orders/presentation/pages/order_details_page.dart';

class OrderDashboardPage extends StatefulWidget {
  const OrderDashboardPage({super.key});

  @override
  State<OrderDashboardPage> createState() => _OrderDashboardPageState();
}

class _OrderDashboardPageState extends State<OrderDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            BlocBuilder<OrderManagementCubit, OrderManagementState>(
              builder: (context, state) {
                int count = 0;
                if (state is OrderManagementLoaded) {
                  count = state.pendingOrders.length;
                }
                return _buildTab('جدید', count);
              },
            ),
            BlocBuilder<OrderManagementCubit, OrderManagementState>(
              builder: (context, state) {
                int count = 0;
                if (state is OrderManagementLoaded) {
                  count = state.activeOrders.length;
                }
                return _buildTab('در حال انجام', count);
              },
            ),
            const Tab(text: 'تکمیل‌شده'),
          ],
        ),
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
                // تب ۲: در حال انجام (Active)
                _OrderList(
                  key: const PageStorageKey('activeOrders'),
                  orders: state.activeOrders,
                  updatingIds: state.updatingOrderIds,
                  emptyMessage: 'هیچ سفارش فعالی وجود ندارد.',
                ),
                // تب ۳: تکمیل‌شده (Completed)
                _OrderList(
                  key: const PageStorageKey('completedOrders'),
                  orders: state.completedOrders,
                  updatingIds: state.updatingOrderIds,
                  emptyMessage: 'هیچ سفارش تکمیل‌شده‌ای وجود ندارد.',
                ),
              ],
            );
          }
          
          if (state is OrderManagementError) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('خطا: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<OrderManagementCubit>().loadOrders(), 
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

  Widget _buildTab(String title, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Badge(
              label: Text(count.toString()),
              backgroundColor: title == 'جدید'
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
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0), 
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
            
            // *** شروع بخش اصلاح شده ***
            // TODO شما را با کد واقعی جایگزین کردیم
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsPage(orderId: order.id),
                ),
              );
            },
            // *** پایان بخش اصلاح شده ***
          );
        },
      ),
    );
  }
}