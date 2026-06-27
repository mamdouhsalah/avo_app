// lib/app/features/admin/views/screen/admin_logs_screen.dart
import 'package:avo_app/app/features/admin/logic/admin_cubit.dart';
import 'package:avo_app/app/features/admin/logic/admin_state.dart';
import 'package:avo_app/app/features/admin/views/widgets/log_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  final _filters = ['all', 'info', 'success', 'warning', 'error'];
  final _labels = ['All', 'Info', 'Success', 'Warning', 'Error'];
  String _selected = 'all';

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().startListeningLogs();
  }

  Color _filterColor(String filter) {
    switch (filter) {
      case 'error':
        return const Color(0xFFD32F2F);
      case 'warning':
        return const Color(0xFFFBC02D);
      case 'success':
        return const Color(0xFF00A991);
      case 'info':
        return const Color(0xFF0095FF);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AdminCubit>().refreshLogs();
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 50.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final isSelected = _selected == _filters[i];
                final color = _filterColor(_filters[i]);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = _filters[i]);
                    context.read<AdminCubit>().filterLogs(_filters[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color:
                            isSelected ? color : color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Logs List
          Expanded(
            child: BlocBuilder<AdminCubit, AdminState>(
              buildWhen: (prev, curr) => 
                  curr is AdminLogsLoaded || 
                  curr is AdminLoading || 
                  curr is AdminError,
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00A991),
                    ),
                  );
                }
                if (state is AdminError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48.sp, color: Colors.red),
                        SizedBox(height: 8.h),
                        Text(state.error,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.sp)),
                      ],
                    ),
                  );
                }
                if (state is AdminLogsLoaded) {
                  if (state.logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt_rounded,
                              size: 64.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3)),
                          SizedBox(height: 12.h),
                          Text(
                            'No logs found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: state.logs.length,
                    itemBuilder: (context, i) => LogTile(log: state.logs[i]),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
