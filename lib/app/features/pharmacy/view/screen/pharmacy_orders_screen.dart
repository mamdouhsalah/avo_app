import 'package:avo_app/app/core/models/pharmacy_order_model.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/pharmacy/data/pharmacy_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/features/pharmacy/view/widget/pharmacy_custom_drawer.dart';

class PharmacyOrdersScreen extends StatefulWidget {
  const PharmacyOrdersScreen({super.key});

  @override
  State<PharmacyOrdersScreen> createState() => _PharmacyOrdersScreenState();
}

class _PharmacyOrdersScreenState extends State<PharmacyOrdersScreen> {
  final _repo = PharmacyRepositoryImpl(consumer: FirebaseConsumerImpl());
  bool _isLoading = true;
  List<PharmacyOrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      final orders = await _repo.getPharmacyOrders(uid);
      // Sort by date descending
      orders.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const PharmacyCustomDrawer(),
      appBar: AppBar(
        title: Text(LocaleKeys.medical_records_pharmacy_orders.tr()),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.sp),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final isPending = order.status == 'pending';
                      final isCancelled = order.status == 'cancelled' || order.status == 'rejected';
                      
                      Color statusColor = isPending ? Colors.orange : (isCancelled ? Colors.red : Colors.green);
                      IconData statusIcon = isPending ? Icons.pending_actions : (isCancelled ? Icons.cancel : Icons.check_circle);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 2,
                        child: ListTile(
                          onTap: () {
                            context.push(AppRouter.orderDetails, extra: order).then((_) {
                              _loadOrders();
                            });
                          },
                          contentPadding: EdgeInsets.all(16.sp),
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withOpacity(0.1),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                            ),
                          ),
                          title: Text(
                            order.patientName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4.h),
                              Text('${order.medicines.length} Medicines'),
                              SizedBox(height: 4.h),
                              Text(
                                DateFormat('MMM d, yyyy - h:mm a').format(order.date),
                                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
