import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScanControlsWidget extends StatelessWidget {
  final bool isFlashlightOn;
  final int scanCount;
  final VoidCallback onFlashlightToggle;
  final VoidCallback onManualEntry;
  final VoidCallback onScanHistoryToggle;
  final VoidCallback onSimulateScan;

  const ScanControlsWidget({
    super.key,
    required this.isFlashlightOn,
    required this.scanCount,
    required this.onFlashlightToggle,
    required this.onManualEntry,
    required this.onScanHistoryToggle,
    required this.onSimulateScan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Flashlight toggle
        _buildControlButton(
          icon: isFlashlightOn ? 'flash_on' : 'flash_off',
          label: 'Flash',
          isActive: isFlashlightOn,
          onTap: onFlashlightToggle,
        ),

        // Manual entry button
        _buildControlButton(
          icon: 'keyboard',
          label: 'Manual',
          isActive: false,
          onTap: onManualEntry,
        ),

        // Scan button (simulate scan for demo)
        _buildScanButton(),

        // Scan history with counter
        _buildControlButton(
          icon: 'history',
          label: 'History',
          isActive: false,
          onTap: onScanHistoryToggle,
          badge: scanCount > 0 ? scanCount.toString() : null,
        ),

        // Settings/Info button
        _buildControlButton(
          icon: 'info_outline',
          label: 'Info',
          isActive: false,
          onTap: () => _showScanInfo(context),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 15.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.lightTheme.primaryColor
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: AppTheme.getSuccessColor(true),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 4.w,
                        minHeight: 4.w,
                      ),
                      child: Text(
                        badge,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: onSimulateScan,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: Colors.white,
              size: 8.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'SCAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Barcode Scanner Info',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Supported Formats:', 'UPC, EAN, Code128, QR'),
            SizedBox(height: 1.h),
            _buildInfoRow('Scan Distance:', '10-30 cm optimal'),
            SizedBox(height: 1.h),
            _buildInfoRow('Lighting:', 'Use flash in low light'),
            SizedBox(height: 1.h),
            _buildInfoRow('Multiple Mode:', 'Scan without navigation'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
