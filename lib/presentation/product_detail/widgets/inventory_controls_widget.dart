import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InventoryControlsWidget extends StatelessWidget {
  final int currentCount;
  final Function(int) onQuantityChanged;

  const InventoryControlsWidget({
    super.key,
    required this.currentCount,
    required this.onQuantityChanged,
  });

  void _decrementQuantity() {
    if (currentCount > 0) {
      HapticFeedback.lightImpact();
      onQuantityChanged(currentCount - 1);
    }
  }

  void _incrementQuantity() {
    HapticFeedback.lightImpact();
    onQuantityChanged(currentCount + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'inventory',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Text(
                'Current Inventory',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Inventory Count Display
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$currentCount',
                style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Quantity Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement Button
              Container(
                decoration: BoxDecoration(
                  color: currentCount > 0
                      ? AppTheme.lightTheme.colorScheme.surface
                      : AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentCount > 0
                        ? AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3)
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: currentCount > 0 ? _decrementQuantity : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 12.w,
                      height: 6.h,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'remove',
                          color: currentCount > 0
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Current Count Display
              Container(
                width: 20.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$currentCount',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 6.w),

              // Increment Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _incrementQuantity,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 12.w,
                      height: 6.h,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'add',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Quick Add Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAddButton('+5', 5),
              _buildQuickAddButton('+10', 10),
              _buildQuickAddButton('+25', 25),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(String label, int value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        child: OutlinedButton(
          onPressed: () => onQuantityChanged(currentCount + value),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            side: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
