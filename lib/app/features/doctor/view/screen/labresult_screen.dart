import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/features/doctor/view/screen/labresult_detail_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/add_labresult_screen.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/doctor/services/labresult_service.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class LabresultScreen extends StatefulWidget {
  const LabresultScreen({super.key});

  @override
  State<LabresultScreen> createState() => _LabresultScreenState();
}

class _LabresultScreenState extends State<LabresultScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late List<LabResultModel> _allResults;
  late List<LabResultModel> _filteredResults;
  String _searchQuery = '';
  String _filterType = '';
  late TabController _tabController;
  bool _isLoading = true;

  late final DoctorRepositoryImpl _doctorRepo;
  final String _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _doctorRepo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_onTabChanged);
    _allResults = [];
    _filteredResults = [];
    _loadLabResults();
  }

  Future<void> _loadLabResults() async {
    setState(() => _isLoading = true);
    try {
      // Fetch all lab results where doctorId == current doctor
      final consumer = FirebaseConsumerImpl();
      final results = await consumer.getList(
        DatabasePaths.reports,
        fromJson: (json) => LabResultModel.fromJson(json),
      );
      // Filter by doctorId client-side (Firebase Realtime DB single index limitation)
      final doctorResults =
          results.where((r) => r.doctorId == _doctorId).toList();
      if (mounted) {
        setState(() {
          _allResults = doctorResults;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allResults = [];
          _filteredResults = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filterType = '';
          break;
        case 1:
          _filterType = 'Manual';
          break;
        case 2:
          _filterType = 'AI';
          break;
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<LabResultModel> base = _allResults;
    if (_filterType.isNotEmpty) {
      base = base.where((r) => r.typeAdd == _filterType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              (r.patientName?.toLowerCase().contains(q) ?? false) ||
              (r.resultSummary?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    _filteredResults = base;
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _applyFilters();
    });
  }

  // ── More Vert bottom sheet ────────────────────────────────
  void showMoreVert(LabResultModel result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.visibility, color: Colors.blue),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(ctx);
              _navigateToDetails(result);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Colors.purple),
            title: const Text('Share'),
            onTap: () async {
              Navigator.pop(ctx);
              await _shareFile(result);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _deleteLabResult(result);
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void _navigateToDetails(LabResultModel result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabresultDetailScreen(result: result),
      ),
    );
  }

  Future<void> _shareFile(LabResultModel result) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing ${result.title}...'),
          duration: const Duration(seconds: 1),
        ),
      );
      await LabResultService.shareFile(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteLabResult(LabResultModel result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lab Result'),
        content: Text('Are you sure you want to delete "${result.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Delete from Firebase
                final consumer = FirebaseConsumerImpl();
                await consumer.delete('${DatabasePaths.reports}/${result.id}');
                if (mounted) {
                  setState(() {
                    _allResults.removeWhere((r) => r.id == result.id);
                    _applyFilters();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ── Add Options ────────────────────────────────────────────
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_document, size: 28),
            title: const Text('Add Manually'),
            subtitle: const Text('Enter details yourself'),
            onTap: () {
              Navigator.pop(ctx);
              _showSourceOptions(isAI: false);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.auto_awesome, size: 28, color: Colors.purple),
            title: const Text('Add with AI'),
            subtitle: const Text('Let AI extract data from document'),
            onTap: () {
              Navigator.pop(ctx);
              _showSourceOptions(isAI: true);
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void _showSourceOptions({required bool isAI}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Open Camera'),
            onTap: () async {
              Navigator.pop(ctx);
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.camera);
              if (image != null && mounted) {
                _handleFileSelected(image, isAI: isAI);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Upload from Gallery'),
            onTap: () async {
              Navigator.pop(ctx);
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (image != null && mounted) {
                _handleFileSelected(image, isAI: isAI);
              }
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  void _handleFileSelected(XFile file, {required bool isAI}) async {
    final didAdd = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddLabResultScreen(
          file: file,
          isAI: isAI,
        ),
      ),
    );

    if (didAdd == true && mounted) {
      // Refresh from Firebase
      _loadLabResults();
    }
  }

  // ── Search Dialog ──────────────────────────────────────────
  void _showSearchDialog() {
    final ctrl = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Lab Results'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by title, patient, or summary...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _performSearch(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Lab Results'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu,
                color: theme.textTheme.titleLarge?.color, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: Icon(Icons.search,
                size: 24, color: theme.textTheme.titleLarge?.color),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Manual'),
            Tab(text: 'AI'),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                children: [
                  // Active search banner
                  if (_searchQuery.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              size: 16, color: theme.colorScheme.primary),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Results for: "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: _clearSearch,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                  // Stats row
                  _buildStatsRow(theme),
                  SizedBox(height: 16.h),

                  // List
                  Expanded(
                    child: _filteredResults.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredResults.length,
                            itemBuilder: (_, index) => _buildLabResultTile(
                                _filteredResults[index], theme),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: theme.colorScheme.onPrimary,
        foregroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, size: 28.sp),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final total = _allResults.length;
    final manual = _allResults.where((r) => r.typeAdd == 'Manual').length;
    final ai = _allResults.where((r) => r.typeAdd == 'AI').length;

    return Row(
      children: [
        _statChip('Total', total, Colors.blue, theme),
        SizedBox(width: 8.w),
        _statChip('Manual', manual, Colors.orange, theme),
        SizedBox(width: 8.w),
        _statChip('AI', ai, Colors.purple, theme),
      ],
    );
  }

  Widget _statChip(String label, int count, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isEmpty
                ? 'No lab results yet'
                : 'No results found for "$_searchQuery"',
            style: TextStyle(fontSize: 15.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultTile(LabResultModel result, ThemeData theme) {
    final isAI = result.typeAdd == 'AI';
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      color: theme.colorScheme.surface,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: isAI
                ? Colors.purple.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            isAI ? Icons.auto_awesome : Icons.description_rounded,
            color: isAI ? Colors.purple : theme.colorScheme.primary,
            size: 26.sp,
          ),
        ),
        title: Text(
          result.title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  result.patientName ?? 'Unknown Patient',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  result.formattedDate,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.access_time_rounded,
                    size: 13.sp, color: Colors.grey[500]),
                SizedBox(width: 4.w),
                Text(
                  result.formattedTime,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
              ],
            ),
            if (result.resultSummary != null) ...[
              SizedBox(height: 4.h),
              Text(
                result.resultSummary!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
            ],
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isAI
                    ? Colors.purple.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                result.typeAdd,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isAI ? Colors.purple : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => showMoreVert(result),
        ),
        onTap: () => _navigateToDetails(result),
      ),
    );
  }
}
