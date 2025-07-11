import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/edit_product_bottom_sheet.dart';
import './widgets/inventory_controls_widget.dart';
import './widgets/product_image_carousel_widget.dart';
import './widgets/product_info_widget.dart';
import './widgets/scan_history_widget.dart';
import './widgets/specifications_widget.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  int _currentImageIndex = 0;
  int _inventoryCount = 45;
  bool _isLoading = false;

  // Mock product data
  final Map<String, dynamic> productData = {
    "id": "PRD-001",
    "name": "Premium Wireless Bluetooth Headphones",
    "description":
        "High-quality wireless headphones with active noise cancellation, premium sound quality, and 30-hour battery life. Perfect for music lovers and professionals who demand exceptional audio performance.",
    "images": [
      "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "https://images.unsplash.com/photo-1484704849700-f032a568e944?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "https://images.unsplash.com/photo-1583394838336-acd977736f90?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3"
    ],
    "sku": "WBH-2024-001",
    "category": "Electronics",
    "weight": "250g",
    "dimensions": "18.5 x 16.2 x 7.8 cm",
    "barcode": "1234567890123",
    "price": "\$299.99",
    "lastScanned": DateTime.now().subtract(const Duration(minutes: 15)),
    "scanHistory": [
      {
        "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
        "quantity": 5,
        "user": "John Doe"
      },
      {
        "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
        "quantity": 3,
        "user": "Jane Smith"
      },
      {
        "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        "quantity": 8,
        "user": "Mike Johnson"
      }
    ]
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onImageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  void _onQuantityChanged(int newQuantity) {
    HapticFeedback.lightImpact();
    setState(() {
      _inventoryCount = newQuantity;
    });
  }

  void _onAddToInventory() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_inventoryCount items to inventory'),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onEditDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProductBottomSheet(
        productData: productData,
        onSave: (updatedData) {
          // Handle product update
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product details updated successfully'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _onDeleteItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Product deleted successfully'),
                  backgroundColor: AppTheme.getErrorColor(true),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getErrorColor(true),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onShare() {
    HapticFeedback.selectionClick();
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product details shared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product information updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Product Details',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: _onShare,
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Carousel
              ProductImageCarouselWidget(
                images: (productData['images'] as List).cast<String>(),
                currentIndex: _currentImageIndex,
                onImageChanged: _onImageChanged,
              ),

              SizedBox(height: 3.h),

              // Product Information
              ProductInfoWidget(
                name: productData['name'] as String,
                description: productData['description'] as String,
                price: productData['price'] as String,
                sku: productData['sku'] as String,
                category: productData['category'] as String,
              ),

              SizedBox(height: 3.h),

              // Specifications
              SpecificationsWidget(
                specifications: {
                  'Weight': productData['weight'] as String,
                  'Dimensions': productData['dimensions'] as String,
                  'SKU': productData['sku'] as String,
                  'Category': productData['category'] as String,
                  'Barcode': productData['barcode'] as String,
                },
              ),

              SizedBox(height: 3.h),

              // Inventory Controls
              InventoryControlsWidget(
                currentCount: _inventoryCount,
                onQuantityChanged: _onQuantityChanged,
              ),

              SizedBox(height: 3.h),

              // Action Buttons
              ActionButtonsWidget(
                isLoading: _isLoading,
                onAddToInventory: _onAddToInventory,
                onEditDetails: _onEditDetails,
                onDeleteItem: _onDeleteItem,
              ),

              SizedBox(height: 3.h),

              // Scan History
              ScanHistoryWidget(
                scanHistory: (productData['scanHistory'] as List)
                    .cast<Map<String, dynamic>>(),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
