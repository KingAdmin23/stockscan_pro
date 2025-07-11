import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onAddToInventory;
  final VoidCallback onEditDetails;
  final VoidCallback onDeleteItem;

  const ActionButtonsWidget({
    super.key,
    required this.isLoading,
    required this.onAddToInventory,
    required this.onEditDetails,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Primary Action Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onAddToInventory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'add_box',
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Add to Inventory',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Secondary Actions Row
          Row(
            children: [
              // Edit Details Button
              Expanded(
                child: SizedBox(
                  height: 5.h,
                  child: OutlinedButton(
                    onPressed: onEditDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Edit Details',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Delete Button
              Expanded(
                child: SizedBox(
                  height: 5.h,
                  child: OutlinedButton(
                    onPressed: onDeleteItem,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.getErrorColor(true),
                      side: BorderSide(
                        color:
                            AppTheme.getErrorColor(true).withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'delete_outline',
                          color: AppTheme.getErrorColor(true),
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Delete',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.getErrorColor(true),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: 'qr_code_scanner',
                label: 'Scan Again',
                onTap: () {
                  Navigator.pushNamed(context, '/barcode-scanner');
                },
              ),
              _buildQuickActionButton(
                icon: 'list_alt',
                label: 'View All',
                onTap: () {
                  Navigator.pushNamed(context, '/inventory-list');
                },
              ),
              _buildQuickActionButton(
                icon: 'search',
                label: 'Search',
                onTap: () {
                  Navigator.pushNamed(context, '/search-manual-entry');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
