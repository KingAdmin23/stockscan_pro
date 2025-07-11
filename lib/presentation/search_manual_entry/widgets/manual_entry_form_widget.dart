import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ManualEntryFormWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSave;

  const ManualEntryFormWidget({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<ManualEntryFormWidget> createState() => _ManualEntryFormWidgetState();
}

class _ManualEntryFormWidgetState extends State<ManualEntryFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String? _selectedImagePath;
  bool _isLoading = false;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Health & Fitness',
    'Sports & Outdoors',
    'Books & Media',
    'Food & Beverages',
    'Automotive',
    'Beauty & Personal Care',
    'Toys & Games'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onImagePicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Add Product Photo',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: 'camera_alt',
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _selectImageFromCamera();
                    },
                  ),
                  _buildImagePickerOption(
                    icon: 'photo_library',
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _selectImageFromGallery();
                    },
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 30.w,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImageFromCamera() {
    // Mock camera selection
    setState(() {
      _selectedImagePath =
          'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=400&fit=crop';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo captured successfully!'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _selectImageFromGallery() {
    // Mock gallery selection
    setState(() {
      _selectedImagePath =
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo selected from gallery!'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          final productData = {
            'name': _nameController.text,
            'description': _descriptionController.text,
            'category': _selectedCategory,
            'sku': _skuController.text,
            'price': _priceController.text,
            'notes': _notesController.text,
            'image': _selectedImagePath,
            'createdAt': DateTime.now().toIso8601String(),
          };

          widget.onSave(productData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onCancel,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Add New Product',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _onSave,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Center(
                      child: InkWell(
                        onTap: _onImagePicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: _selectedImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomImageWidget(
                                    imageUrl: _selectedImagePath!,
                                    width: 40.w,
                                    height: 40.w,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'add_a_photo',
                                      color: AppTheme.textMediumEmphasisLight,
                                      size: 32,
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Add Photo',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelMedium
                                          ?.copyWith(
                                        color: AppTheme.textMediumEmphasisLight,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Product Name
                    Text(
                      'Product Name *',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter product name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Product name is required';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 3.h),
                    // Product Description
                    Text(
                      'Description',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Enter product description',
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 3.h),
                    // Category
                    Text(
                      'Category *',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // SKU and Price Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SKU',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              TextFormField(
                                controller: _skuController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter SKU',
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: AppTheme.lightTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  hintText: '\$0.00',
                                  prefixText: '\$ ',
                                ),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    // Notes
                    Text(
                      'Notes',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Add any additional notes or specifications',
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
