import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/pharmacy_order_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/features/pharmacy/data/pharmacy_repository_impl.dart';
import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SendPrescriptionScreen extends StatefulWidget {
  final String pharmacyId;

  const SendPrescriptionScreen({super.key, required this.pharmacyId});

  @override
  State<SendPrescriptionScreen> createState() => _SendPrescriptionScreenState();
}

class _SendPrescriptionScreenState extends State<SendPrescriptionScreen> {
  bool _isLoading = true;
  List<MedicineModel> _medicines = [];
  final List<MedicineModel> _selectedMedicines = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final repo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());
      final meds = await repo.getPatientMedicines(uid);
      setState(() {
        _medicines = meds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOrder() async {
    if (_selectedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one medicine to order')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final consumer = FirebaseConsumerImpl();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      // Fetch patient details for the order from ProfileCubit
      final userProfile = context.read<ProfileCubit>().userProfile;
      final patientName = userProfile?.fullName ?? 'Unknown';
      final patientPhone = userProfile?.phoneNumber ?? 'No phone provided';

      // Fetch pharmacy name
      final pharmacyRepo = PharmacyRepositoryImpl(consumer: consumer);
      final pharmacyProfile = await pharmacyRepo.getPharmacyProfile(widget.pharmacyId);
      final pharmacyName = pharmacyProfile?.name ?? 'Pharmacy';
      
      final order = PharmacyOrderModel(
        id: '', // Will be set by Firebase
        patientId: uid,
        pharmacyId: widget.pharmacyId,
        patientName: patientName,
        patientPhone: patientPhone,
        patientAddress: '', // Prompt user for address in future if needed
        status: 'pending',
        date: DateTime.now(),
        medicines: _selectedMedicines,
        pharmacyName: pharmacyName,
      );

      final orderId = await consumer.push(DatabasePaths.pharmacyOrders, data: order.toJson());
      await consumer.update('${DatabasePaths.pharmacyOrders}/$orderId', data: {'id': orderId});

      // Send notification to the pharmacy
      final notificationData = {
        'title': 'New Prescription Order',
        'body': 'You have received a new prescription order from $patientName.',
        'type': 'pharmacy_order',
        'isRead': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await consumer.push('${DatabasePaths.notifications}/${widget.pharmacyId}', data: notificationData);

      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order sent to pharmacy successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Send Prescription'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
              ? const Center(child: Text('You have no active prescriptions.'))
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: Text(
                        'Select the medicines you want to order from the pharmacy:',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        itemCount: _medicines.length,
                        itemBuilder: (context, index) {
                          final m = _medicines[index];
                          final isSelected = _selectedMedicines.contains(m);
                          final dateStr = m.date != null ? DateFormat.yMMMd().format(m.date!) : 'Unknown Date';

                          return Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: isSelected ? 4 : 1,
                            color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : theme.cardColor,
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedMedicines.add(m);
                                  } else {
                                    _selectedMedicines.remove(m);
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.all(12.sp),
                              secondary: CircleAvatar(
                                backgroundColor: Colors.purple.withOpacity(0.1),
                                child: const Icon(Icons.medication, color: Colors.purple),
                              ),
                              title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4.h),
                                  Text('Dosage: ${m.dosage} | Freq: ${m.time}'),
                                  SizedBox(height: 4.h),
                                  Text('Prescribed: $dateStr', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.sp),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: _isSending
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Send Order to Pharmacy', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
    );
  }
}
