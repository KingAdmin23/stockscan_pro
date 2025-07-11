import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScanHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scanHistory;
  final VoidCallback onClose;
  final Function(String) onItemTap;

  const ScanHistoryWidget({
    super.key,
    required this.scanHistory,
    required this.onClose,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {}, // Prevent tap through
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan History (${scanHistory.length})',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ),

              // History list
              Expanded(
                child: scanHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: scanHistory.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[200],
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = scanHistory[index];
                          return _buildHistoryItem(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'qr_code_scanner',
            color: Colors.grey[400]!,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No scans yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start scanning to see your history',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final barcode = item['barcode'] as String;
    final format = item['format'] as String;
    final timestamp = item['timestamp'] as DateTime;
    final productName = item['productName'] as String;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 1.h,
      ),
      leading: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: _getFormatIcon(format),
          color: AppTheme.lightTheme.primaryColor,
          size: 6.w,
        ),
      ),
      title: Text(
        productName,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 0.5.h),
          Text(
            barcode,
            style: AppTheme.dataTextStyle(
              isLight: true,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
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
                  color: _getFormatColor(format).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  format,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: _getFormatColor(format),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: Colors.grey[400]!,
        size: 4.w,
      ),
      onTap: () => onItemTap(barcode),
    );
  }

  String _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'qr code':
      case 'qr':
        return 'qr_code';
      case 'upc-a':
      case 'upc':
        return 'barcode_reader';
      case 'ean-13':
      case 'ean':
        return 'barcode_reader';
      case 'code128':
        return 'barcode_reader';
      default:
        return 'qr_code_scanner';
    }
  }

  Color _getFormatColor(String format) {
    switch (format.toLowerCase()) {
      case 'qr code':
      case 'qr':
        return AppTheme.getSuccessColor(true);
      case 'upc-a':
      case 'upc':
        return AppTheme.lightTheme.primaryColor;
      case 'ean-13':
      case 'ean':
        return AppTheme.getWarningColor(true);
      case 'code128':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
