import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InventoryItemCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isSelected;
  final bool isBulkSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const InventoryItemCardWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.isBulkSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quantity = item['quantity'] as int;
    final status = item['status'] as String;
    final lastUpdated = item['lastUpdated'] as DateTime;

    Color statusColor;
    switch (status) {
      case 'In Stock':
        statusColor = AppTheme.lightTheme.colorScheme.tertiary;
        break;
      case 'Low Stock':
        statusColor = AppTheme.getWarningColor(true);
        break;
      case 'Out of Stock':
        statusColor = AppTheme.getErrorColor(true);
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }

    return Dismissible(
      key: Key(item['id'].toString()),
      background: _buildSwipeBackground(
        color: AppTheme.lightTheme.colorScheme.primary,
        icon: 'edit',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppTheme.getErrorColor(true),
        icon: 'delete',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  if (isBulkSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap(),
                    ),
                    SizedBox(width: 3.w),
                  ],
                  _buildProductImage(),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildProductInfo(statusColor),
                  ),
                  _buildQuantityBadge(quantity, statusColor),
                ],
              ),
            ),
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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: item['image'] != null
            ? CustomImageWidget(
                imageUrl: item['image'] as String,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              )
            : Center(
                child: CustomIconWidget(
                  iconName: 'inventory_2',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
      ),
    );
  }

  Widget _buildProductInfo(Color statusColor) {
    final lastUpdated = item['lastUpdated'] as DateTime;
    final timeAgo = _getTimeAgo(lastUpdated);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['name'] as String,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['category'] as String,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['status'] as String,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Barcode: ${item['barcode']}',
          style: AppTheme.dataTextStyle(
            isLight: true,
            fontSize: 11,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Updated $timeAgo',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityBadge(int quantity, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            quantity.toString(),
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          item['price'] as String,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Item'),
            content: Text('Are you sure you want to delete "${item['name']}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getErrorColor(true),
                ),
                child: Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
