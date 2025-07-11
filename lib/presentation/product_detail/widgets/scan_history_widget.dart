import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScanHistoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> scanHistory;

  const ScanHistoryWidget({
    super.key,
    required this.scanHistory,
  });

  @override
  State<ScanHistoryWidget> createState() => _ScanHistoryWidgetState();
}

class _ScanHistoryWidgetState extends State<ScanHistoryWidget> {
  bool _isExpanded = false;

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Recent Scan History',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.scanHistory.length}',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Container(
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                    child: Column(
                      children: [
                        Divider(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                          height: 1,
                        ),
                        SizedBox(height: 2.h),
                        ...widget.scanHistory.asMap().entries.map((entry) {
                          final index = entry.key;
                          final scan = entry.value;
                          final isLast = index == widget.scanHistory.length - 1;

                          return Container(
                            margin: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
                            child: _buildScanHistoryItem(scan),
                          );
                        }).toList(),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanHistoryItem(Map<String, dynamic> scan) {
    final timestamp = scan['timestamp'] as DateTime;
    final quantity = scan['quantity'] as int;
    final user = scan['user'] as String;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Scan Icon
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: AppTheme.getSuccessColor(true),
              size: 16,
            ),
          ),

          SizedBox(width: 3.w),

          // Scan Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Added $quantity items',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDateTime(timestamp),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 12,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      user,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
