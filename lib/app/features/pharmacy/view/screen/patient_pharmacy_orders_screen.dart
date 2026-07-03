import 'package:avo_app/app/core/models/pharmacy_order_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/pharmacy/data/pharmacy_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PatientPharmacyOrdersScreen extends StatefulWidget {
  const PatientPharmacyOrdersScreen({super.key});

  @override
  State<PatientPharmacyOrdersScreen> createState() => _PatientPharmacyOrdersScreenState();
}

class _PatientPharmacyOrdersScreenState extends State<PatientPharmacyOrdersScreen> {
  final _repository = PharmacyRepositoryImpl(consumer: FirebaseConsumerImpl());
  final _patientId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'approved':
      case 'dispensed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Pharmacy Orders'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: StreamBuilder<List<PharmacyOrderModel>>(
        stream: _repository.streamPatientPharmacyOrders(_patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80.sp, color: theme.colorScheme.outlineVariant),
                  SizedBox(height: 16.h),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort by date descending
          orders.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(order.date),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status, context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(order.status, context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        order.pharmacyName ?? 'Pharmacy',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Divider(),
                      SizedBox(height: 8.h),
                      Text(
                        'Medicines:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...order.medicines.map((med) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(Icons.medication_outlined, size: 16.sp, color: theme.colorScheme.primary),
                            SizedBox(width: 8.w),
                            Text(
                              '${med.name} - ${med.dosage}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (order.note != null && order.note!.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, size: 20.sp, color: theme.colorScheme.error),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Note from Pharmacy:',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      order.note!,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
