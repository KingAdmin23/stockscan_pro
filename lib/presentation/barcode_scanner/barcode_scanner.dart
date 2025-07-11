import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/scan_controls_widget.dart';
import './widgets/scan_history_widget.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner>
    with TickerProviderStateMixin {
  bool _isFlashlightOn = false;
  bool _isMultipleScanMode = false;
  bool _isScanning = false;
  bool _showScanHistory = false;
  int _scanCount = 0;
  String _lastScannedCode = '';
  String _detectedFormat = '';

  late AnimationController _scanAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _scanAnimation;
  late Animation<double> _successAnimation;

  // Mock scan history data
  final List<Map<String, dynamic>> _scanHistory = [
    {
      'barcode': '1234567890123',
      'format': 'UPC-A',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
      'productName': 'Wireless Bluetooth Headphones',
    },
    {
      'barcode': '9876543210987',
      'format': 'EAN-13',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'productName': 'Smartphone Case Premium',
    },
    {
      'barcode': 'QR123456789',
      'format': 'QR Code',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
      'productName': 'Organic Coffee Beans 500g',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestCameraPermission();
  }

  void _initializeAnimations() {
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _scanAnimationController.repeat();
  }

  Future<void> _requestCameraPermission() async {
    // Mock camera permission request
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isScanning = true;
    });
  }

  void _toggleFlashlight() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
    });
  }

  void _toggleMultipleScanMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isMultipleScanMode = !_isMultipleScanMode;
    });
  }

  void _simulateSuccessfulScan() {
    if (!_isScanning) return;

    // Mock barcode data
    final mockBarcodes = [
      {
        'code': '1234567890123',
        'format': 'UPC-A',
        'product': 'Wireless Bluetooth Headphones'
      },
      {
        'code': '9876543210987',
        'format': 'EAN-13',
        'product': 'Smartphone Case Premium'
      },
      {
        'code': 'QR123456789',
        'format': 'QR Code',
        'product': 'Organic Coffee Beans 500g'
      },
    ];

    final randomBarcode = mockBarcodes[_scanCount % mockBarcodes.length];

    HapticFeedback.heavyImpact();
    _successAnimationController.forward().then((_) {
      _successAnimationController.reset();
    });

    setState(() {
      _lastScannedCode = randomBarcode['code'] as String;
      _detectedFormat = randomBarcode['format'] as String;
      _scanCount++;
    });

    // Add to scan history
    _scanHistory.insert(0, {
      'barcode': randomBarcode['code'],
      'format': randomBarcode['format'],
      'timestamp': DateTime.now(),
      'productName': randomBarcode['product'],
    });

    // Show format indicator briefly
    _showFormatIndicator();

    // Navigate based on scan mode
    if (!_isMultipleScanMode) {
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pushNamed(context, '/product-detail');
      });
    }
  }

  void _showFormatIndicator() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_detectedFormat} detected: $_lastScannedCode'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _toggleScanHistory() {
    setState(() {
      _showScanHistory = !_showScanHistory;
    });
  }

  void _navigateToManualEntry() {
    Navigator.pushNamed(context, '/search-manual-entry');
  }

  void _navigateToProductDetail(String barcode) {
    Navigator.pushNamed(context, '/product-detail');
  }

  void _handleTapToFocus(TapUpDetails details) {
    HapticFeedback.selectionClick();
    // Mock tap to focus functionality
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // Show focus indicator at tap position
    _showFocusIndicator(localPosition);
  }

  void _showFocusIndicator(Offset position) {
    // This would typically show a focus square animation
    // For now, we'll just provide haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera viewfinder (mock)
            _buildCameraViewfinder(),

            // Success flash animation
            _buildSuccessFlash(),

            // Camera overlay with scanning reticle
            CameraOverlayWidget(
              scanAnimation: _scanAnimation,
              onTapToFocus: _handleTapToFocus,
            ),

            // Top controls
            _buildTopControls(),

            // Bottom controls
            _buildBottomControls(),

            // Scan history overlay
            if (_showScanHistory)
              ScanHistoryWidget(
                scanHistory: _scanHistory,
                onClose: _toggleScanHistory,
                onItemTap: _navigateToProductDetail,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraViewfinder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 80.w,
          height: 40.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Camera Viewfinder\n(Mock)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessFlash() {
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return _successAnimation.value > 0
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: AppTheme.getSuccessColor(true).withValues(
                  alpha: _successAnimation.value * 0.3,
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 2.h,
      left: 4.w,
      right: 4.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),

          // Multiple scan mode toggle
          GestureDetector(
            onTap: _toggleMultipleScanMode,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: _isMultipleScanMode
                    ? AppTheme.lightTheme.primaryColor
                    : Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'qr_code_scanner',
                    color: Colors.white,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Multi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scan controls
            ScanControlsWidget(
              isFlashlightOn: _isFlashlightOn,
              scanCount: _scanCount,
              onFlashlightToggle: _toggleFlashlight,
              onManualEntry: _navigateToManualEntry,
              onScanHistoryToggle: _toggleScanHistory,
              onSimulateScan: _simulateSuccessfulScan,
            ),

            SizedBox(height: 2.h),

            // Tap to focus hint
            GestureDetector(
              onTapUp: _handleTapToFocus,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  'Tap to Focus • Point camera at barcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
