import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditProductBottomSheet extends StatefulWidget {
  final Map<String, dynamic> productData;
  final Function(Map<String, dynamic>) onSave;

  const EditProductBottomSheet({
    super.key,
    required this.productData,
    required this.onSave,
  });

  @override
  State<EditProductBottomSheet> createState() => _EditProductBottomSheetState();
}

class _EditProductBottomSheetState extends State<EditProductBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late TextEditingController _priceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productData['name']);
    _descriptionController =
        TextEditingController(text: widget.productData['description']);
    _categoryController =
        TextEditingController(text: widget.productData['category']);
    _notesController = TextEditingController();
    _priceController = TextEditingController(text: widget.productData['price']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedData = {
        ...widget.productData,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'price': _priceController.text,
        'notes': _notesController.text,
      };

      widget.onSave(updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Edit Product Details',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      'Product Name',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter product name',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Price
                    Text(
                      'Price',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: 'Enter price',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Category
                    Text(
                      'Category',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        hintText: 'Enter category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Description
                    Text(
                      'Description',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Enter product description',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Custom Notes
                    Text(
                      'Custom Notes',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Add any additional notes (optional)',
                        prefixIcon: Icon(Icons.note_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
