import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpecificationsWidget extends StatefulWidget {
  final Map<String, String> specifications;

  const SpecificationsWidget({
    super.key,
    required this.specifications,
  });

  @override
  State<SpecificationsWidget> createState() => _SpecificationsWidgetState();
}

class _SpecificationsWidgetState extends State<SpecificationsWidget> {
  bool _isExpanded = false;

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
                    iconName: 'info_outline',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Specifications',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
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
                        ...widget.specifications.entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.value,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                      fontFamily: entry.key == 'SKU' ||
                                              entry.key == 'Barcode'
                                          ? 'monospace'
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}
