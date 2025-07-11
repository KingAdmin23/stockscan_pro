import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String selectedOption;
  final Function(String) onSortChanged;

  const SortBottomSheetWidget({
    Key? key,
    required this.selectedOption,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'label': 'Name', 'icon': 'sort_by_alpha'},
      {'label': 'Quantity', 'icon': 'format_list_numbered'},
      {'label': 'Date Added', 'icon': 'schedule'},
      {'label': 'Category', 'icon': 'category'},
    ];

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 3.h),
          Text(
            'Sort by',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...sortOptions.map((option) => _buildSortOption(
                context,
                option['label'] as String,
                option['icon'] as String,
              )),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, String icon) {
    final isSelected = selectedOption == label;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onSortChanged(label);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
