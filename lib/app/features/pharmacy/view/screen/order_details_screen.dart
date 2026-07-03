import 'package:avo_app/app/core/models/pharmacy_order_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/pharmacy/data/pharmacy_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final PharmacyOrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _repo = PharmacyRepositoryImpl(consumer: FirebaseConsumerImpl());
  late bool _isPending;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isPending = widget.order.status == 'pending';
  }

  Future<void> _updateStatus(String status, String note) async {
    setState(() => _isUpdating = true);
    try {
      await _repo.updateOrderStatus(
        widget.order.id, 
        status, 
        note: note, 
        patientId: widget.order.patientId,
      );
      if (mounted) {
        setState(() {
          _isPending = false;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order marked as $status!')),
        );
        Navigator.pop(context); // Go back after updating
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  void _showActionDialog(String action) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(action == 'dispensed' ? 'Accept Order' : 'Cancel Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add an optional note to the patient:'),
              SizedBox(height: 8.h),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Medicine out of stock...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateStatus(action, noteController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'dispensed' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(action == 'dispensed' ? 'Accept' : 'Cancel Order'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.person, color: theme.colorScheme.primary),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.patientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                              SizedBox(height: 4.h),
                              Text(order.patientPhone.isNotEmpty ? order.patientPhone : 'No phone provided', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow('Order Date:', DateFormat('MMM d, yyyy - h:mm a').format(order.date)),
                    SizedBox(height: 8.h),
                    _buildInfoRow('Status:', _isPending ? 'Pending' : 'Dispensed', color: _isPending ? Colors.orange : Colors.green),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Medicines Requested',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ...order.medicines.map((m) {
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    child: const Icon(Icons.medication, color: Colors.purple),
                  ),
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Dosage: ${m.dosage} | Freq: ${m.time}'),
                ),
              );
            }),
            if (order.note != null && order.note!.isNotEmpty)
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    children: [
                      Icon(Icons.notes, color: Colors.orange),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Note: ${order.note}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 32.h),
            if (_isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : () => _showActionDialog('cancelled'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : () => _showActionDialog('dispensed'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isUpdating
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: color),
        ),
      ],
    );
  }
}
