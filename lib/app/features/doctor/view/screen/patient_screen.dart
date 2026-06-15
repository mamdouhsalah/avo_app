import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_pationtcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredPatients = DataRepository.patients.where((patient) {
      return patient.fullName.toLowerCase().contains(query.toLowerCase()) ||
          patient.email.toLowerCase().contains(query.toLowerCase()) ||
          patient.phoneNumber.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: theme.textTheme.titleLarge?.color, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Patients',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => query = value);
              },
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                hintText: "Search patients by name or phone...",
                hintStyle: TextStyle(color: theme.colorScheme.outlineVariant),
                prefixIcon:
                    Icon(Icons.search, color: theme.colorScheme.outlineVariant),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => query = "");
                        },
                        icon: Icon(Icons.close,
                            color: theme.colorScheme.outlineVariant),
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                      BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: filteredPatients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 80.sp,
                              color: theme.colorScheme.outlineVariant),
                          SizedBox(height: 16.h),
                          Text(
                            query.isEmpty
                                ? "Search for patients"
                                : "No patients found",
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: CustomPatientCard(
                            patient: filteredPatients[index],
                            onTap: () {
                              context.push(
                                '/patient-details',
                                extra: filteredPatients[index],
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
