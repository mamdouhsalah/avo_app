import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PatientSearchBottomSheet extends StatefulWidget {
  final List<PatientModel> patients;
  final PatientModel? selectedPatient;
  final Function(PatientModel) onPatientSelected;

  const PatientSearchBottomSheet({
    super.key,
    required this.patients,
    this.selectedPatient,
    required this.onPatientSelected,
  });

  @override
  State<PatientSearchBottomSheet> createState() =>
      _PatientSearchBottomSheetState();
}

class _PatientSearchBottomSheetState extends State<PatientSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredPatients = widget.patients.where((patient) {
      return patient.fullName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (patient.email.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (patient.phoneNumber
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()));
    }).toList();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            "Select Patient",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search by name, email or phone...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),

          SizedBox(height: 16.h),

          // Results
          Expanded(
            child: filteredPatients.isEmpty
                ? Center(
                    child: Text(
                      "No patients found",
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      final isSelected =
                          widget.selectedPatient?.id == patient.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: patient.image != null
                              ? NetworkImage(patient.image!)
                              : null,
                          child: patient.image == null
                              ? Text(patient.fullName[0].toUpperCase())
                              : null,
                        ),
                        title: Text(patient.fullName),
                        subtitle:
                            Text(patient.email),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => widget.onPatientSelected(patient),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
