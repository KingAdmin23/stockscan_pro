import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityItemWidget extends StatelessWidget {
  final String productName;
  final String barcode;
  final String category;
  final int quantity;
  final String timestamp;
  final String imageUrl;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecentActivityItemWidget({
    super.key,
    required this.productName,
    required this.barcode,
    required this.category,
    required this.quantity,
    required this.timestamp,
    required this.imageUrl,
    required this.price,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(barcode),
      background: _buildSwipeBackground(
        color: AppTheme.successLight,
        icon: 'edit',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppTheme.errorLight,
        icon: 'delete',
        alignment: Alignment.centerRight,
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
        } else {
          onDelete();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(4.w),
          margin: EdgeInsets.only(bottom: 1.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppTheme.dividerDark.withValues(alpha: 0.2)
                  : AppTheme.dividerLight.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: imageUrl,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 4.w),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Qty: $quantity',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'qr_code',
                          size: 12,
                          color: isDark
                              ? AppTheme.textDisabledDark
                              : AppTheme.textDisabledLight,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          barcode,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppTheme.textDisabledDark
                                        : AppTheme.textDisabledLight,
                                    fontFamily: 'monospace',
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price and Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successLight,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _formatTimestamp(timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppTheme.textDisabledDark
                              : AppTheme.textDisabledLight,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required String icon,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomIconWidget(
        iconName: icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
