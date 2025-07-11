import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isAction;
  final int? count;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isAction = false,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isActive || isAction
                    ? (isAction
                        ? AppTheme.getErrorColor(true)
                        : AppTheme.lightTheme.colorScheme.primary)
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight:
                    isActive || isAction ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (count != null && count! > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (isActive && !isAction) ...[
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
            ],
            if (isAction) ...[
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'clear_all',
                color: AppTheme.getErrorColor(true),
                size: 16,
              ),
            ],
          ],
        ),
        selected: isActive,
        onSelected: (_) => onTap(),
        backgroundColor: isAction
            ? AppTheme.getErrorColor(true).withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        selectedColor:
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        side: BorderSide(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary
              : (isAction
                  ? AppTheme.getErrorColor(true)
                  : AppTheme.lightTheme.colorScheme.outline),
          width: isActive || isAction ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
