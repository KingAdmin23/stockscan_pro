import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchResultCardWidget extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddProduct;

  const SearchResultCardWidget({
    super.key,
    required this.product,
    required this.onAddProduct,
  });

  @override
  State<SearchResultCardWidget> createState() => _SearchResultCardWidgetState();
}

class _SearchResultCardWidgetState extends State<SearchResultCardWidget> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool inStock = widget.product['inStock'] as bool? ?? false;
    final int availableQuantity = widget.product['quantity'] as int? ?? 0;

    return Card(
      elevation: AppTheme.lightTheme.cardTheme.elevation,
      shape: AppTheme.lightTheme.cardTheme.shape,
      color: AppTheme.lightTheme.cardTheme.color,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: widget.product['image'] as String? ?? '',
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product['name'] as String? ?? 'Unknown Product',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  // Product Description
                  Text(
                    widget.product['description'] as String? ?? '',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // SKU and Category
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SKU: ${widget.product['sku'] as String? ?? 'N/A'}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product['category'] as String? ?? 'General',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Price and Stock Status
                  Row(
                    children: [
                      Text(
                        widget.product['price'] as String? ?? '\$0.00',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? AppTheme.successLight.withValues(alpha: 0.1)
                              : AppTheme.errorLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: inStock ? 'check_circle' : 'cancel',
                              color: inStock
                                  ? AppTheme.successLight
                                  : AppTheme.errorLight,
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              inStock
                                  ? 'In Stock ($availableQuantity)'
                                  : 'Out of Stock',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: inStock
                                    ? AppTheme.successLight
                                    : AppTheme.errorLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            // Quantity and Add Button
            Column(
              children: [
                // Quantity Stepper
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _decrementQuantity,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 8.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                            color: _quantity > 1
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.1),
                          ),
                          child: CustomIconWidget(
                            iconName: 'remove',
                            color: _quantity > 1
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.textDisabledLight,
                            size: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: 10.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _quantity.toString(),
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _incrementQuantity,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 8.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                          ),
                          child: CustomIconWidget(
                            iconName: 'add',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                // Add Button
                SizedBox(
                  width: 26.w,
                  child: ElevatedButton(
                    onPressed: inStock ? widget.onAddProduct : null,
                    style:
                        AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(vertical: 1.h),
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) {
                          if (states.contains(WidgetState.disabled)) {
                            return AppTheme.textDisabledLight;
                          }
                          return AppTheme.lightTheme.colorScheme.primary;
                        },
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'add',
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Add',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
