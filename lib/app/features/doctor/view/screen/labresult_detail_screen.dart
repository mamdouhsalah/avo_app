import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/features/doctor/services/labresult_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class LabresultDetailScreen extends StatefulWidget {
  const LabresultDetailScreen({super.key, required this.result});

  final LabResultModel result;

  @override
  State<LabresultDetailScreen> createState() => _LabresultDetailScreenState();
}

class _LabresultDetailScreenState extends State<LabresultDetailScreen> {
  bool _isDownloading = false;
  bool _isSharing = false;

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      await LabResultService.downloadFile(widget.result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      await LabResultService.shareFile(widget.result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error sharing: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showOptionsMenu() {
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
            leading: const Icon(Icons.download_rounded, color: Colors.green),
            title: const Text('Download'),
            onTap: () {
              Navigator.pop(ctx);
              _download();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded, color: Colors.purple),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(ctx);
              _share();
            },
          ),
          ListTile(
            leading: const Icon(Icons.print_rounded, color: Colors.blue),
            title: const Text('Print'),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Print feature coming soon')),
              );
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;
    final isAI = result.typeAdd == 'AI';

    return Scaffold(
      appBar: AppBar(
          title: Text(
            result.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showOptionsMenu,
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: theme.colorScheme.onSurface, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          )),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentPreview(theme, result),
            SizedBox(height: 24.h),

            _buildSection(
              title: 'General Information',
              icon: Icons.info_outline_rounded,
              color: theme.colorScheme.primary,
              theme: theme,
              children: [
                _infoRow(Icons.title, 'Title', result.title, theme),
                _infoRow(
                    Icons.category_outlined,
                    'Type',
                    result.typeAdd == 'AI' ? ' AI Generated' : ' Manual',
                    theme),
                _infoRow(Icons.description_outlined, 'Description',
                    result.description, theme),
                _infoRow(Icons.calendar_today_outlined, 'Date',
                    result.formattedDate, theme),
                _infoRow(Icons.access_time_rounded, 'Time',
                    result.formattedTime, theme),
                _infoRow(Icons.insert_drive_file_outlined, 'File Type',
                    result.fileType.toUpperCase(), theme),
              ],
            ),
            SizedBox(height: 16.h),

            _buildSection(
              title: 'Patient',
              icon: Icons.person_outline_rounded,
              color: Colors.teal,
              theme: theme,
              children: [
                _infoRow(
                    Icons.badge_outlined, 'Name', result.patient.name, theme),
                _infoRow(
                    Icons.email_outlined, 'Email', result.patient.email, theme),
                _infoRow(
                    Icons.phone_outlined, 'Phone', result.patient.phone, theme),
                if (result.patient.diagnosis != null)
                  _infoRow(Icons.medical_information_outlined, 'Diagnosis',
                      result.patient.diagnosis!, theme),
                _infoRow(
                  Icons.verified_outlined,
                  'Verified',
                  result.patient.isVerified ? '✅ Yes' : '❌ No',
                  theme,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            _buildSection(
              title: 'Result Summary',
              icon: Icons.summarize_outlined,
              color: isAI ? Colors.purple : Colors.orange,
              theme: theme,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: (isAI ? Colors.purple : Colors.orange)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    result.resultSummary ?? 'No summary available',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Notes ─────────────────────────────────────────
            _buildSection(
              title: 'Notes',
              icon: Icons.notes_rounded,
              color: Colors.grey,
              theme: theme,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    result.notes ?? 'No notes available',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ── Action Buttons ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSharing ? null : _share,
                    icon: _isSharing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child:
                                const CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _download,
                    icon: _isDownloading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ))
                        : const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────

  Widget _buildDocumentPreview(ThemeData theme, LabResultModel result) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          Shimmer(
            duration: const Duration(seconds: 3),
            interval: const Duration(seconds: 1),
            child: Container(
              height: 200.h,
              width: double.infinity,
              color: Colors.grey[200],
            ),
          ),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  result.fileType == 'xray'
                      ? Icons.blur_on_rounded
                      : Icons.picture_as_pdf_rounded,
                  size: 56.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 12.h),
                Text(
                  result.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    result.fileType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 18.sp, color: color),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15)),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey[500]),
          SizedBox(width: 10.w),
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
