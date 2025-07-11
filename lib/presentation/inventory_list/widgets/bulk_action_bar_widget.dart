import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BulkActionBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onCancel;

  const BulkActionBarWidget({
    Key? key,
    required this.selectedCount,
    required this.onDelete,
    required this.onExport,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedCount selected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onSelectAll,
                    child: Text('Select All'),
                  ),
                  TextButton(
                    onPressed: onDeselectAll,
                    child: Text('Deselect All'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: selectedCount > 0 ? onExport : null,
                  icon: CustomIconWidget(
                    iconName: 'file_download',
                    color: selectedCount > 0
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  label: Text('Export'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      selectedCount > 0 ? _showCategoryChangeDialog : null,
                  icon: CustomIconWidget(
                    iconName: 'category',
                    color: selectedCount > 0
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  label: Text('Category'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedCount > 0 ? onDelete : null,
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCount > 0
                        ? AppTheme.getErrorColor(true)
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryChangeDialog() {
    // This would show a dialog to change category for selected items
    // Implementation would depend on available categories
  }
}
