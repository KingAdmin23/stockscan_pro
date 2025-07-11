import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_new_product_card_widget.dart';
import './widgets/manual_entry_form_widget.dart';
import './widgets/recent_search_chip_widget.dart';
import './widgets/search_result_card_widget.dart';

class SearchManualEntry extends StatefulWidget {
  const SearchManualEntry({super.key});

  @override
  State<SearchManualEntry> createState() => _SearchManualEntryState();
}

class _SearchManualEntryState extends State<SearchManualEntry>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isLoading = false;
  bool _showManualEntryForm = false;
  String _selectedCategory = 'All Categories';
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [];

  // Mock data for search results
  final List<Map<String, dynamic>> _mockProducts = [
    {
      "id": 1,
      "name": "Wireless Bluetooth Headphones",
      "description":
          "Premium noise-cancelling wireless headphones with 30-hour battery life",
      "category": "Electronics",
      "sku": "WBH-001",
      "price": "\$149.99",
      "image":
          "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop",
      "inStock": true,
      "quantity": 25
    },
    {
      "id": 2,
      "name": "Organic Cotton T-Shirt",
      "description":
          "Comfortable 100% organic cotton t-shirt in various colors",
      "category": "Clothing",
      "sku": "OCT-002",
      "price": "\$29.99",
      "image":
          "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop",
      "inStock": true,
      "quantity": 50
    },
    {
      "id": 3,
      "name": "Stainless Steel Water Bottle",
      "description":
          "Insulated stainless steel water bottle keeps drinks cold for 24 hours",
      "category": "Home & Garden",
      "sku": "SSWB-003",
      "price": "\$24.99",
      "image":
          "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&h=400&fit=crop",
      "inStock": false,
      "quantity": 0
    },
    {
      "id": 4,
      "name": "Protein Powder Vanilla",
      "description":
          "High-quality whey protein powder with natural vanilla flavor",
      "category": "Health & Fitness",
      "sku": "PPV-004",
      "price": "\$39.99",
      "image":
          "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400&h=400&fit=crop",
      "inStock": true,
      "quantity": 15
    },
    {
      "id": 5,
      "name": "LED Desk Lamp",
      "description":
          "Adjustable LED desk lamp with touch controls and USB charging port",
      "category": "Electronics",
      "sku": "LDL-005",
      "price": "\$45.99",
      "image":
          "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&h=400&fit=crop",
      "inStock": true,
      "quantity": 12
    }
  ];

  final List<String> _categories = [
    'All Categories',
    'Electronics',
    'Clothing',
    'Home & Garden',
    'Health & Fitness',
    'Sports & Outdoors',
    'Books & Media'
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = [
        'Wireless headphones',
        'Cotton t-shirt',
        'Water bottle',
        'Protein powder',
        'LED lamp'
      ];
    });
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _performSearch(_searchController.text);
      }
    });
  }

  void _performSearch(String query) {
    final filteredResults = _mockProducts.where((product) {
      final matchesQuery = (product['name'] as String)
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          (product['description'] as String)
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          (product['sku'] as String)
              .toLowerCase()
              .contains(query.toLowerCase());

      final matchesCategory = _selectedCategory == 'All Categories' ||
          product['category'] == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    setState(() {
      _searchResults = filteredResults;
      _isLoading = false;
    });

    // Add to recent searches if not already present
    if (!_recentSearches.contains(query) && query.isNotEmpty) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _onRecentSearchTap(String searchTerm) {
    _searchController.text = searchTerm;
    _searchFocusNode.unfocus();
    _performSearch(searchTerm);
  }

  void _onVoiceSearch() {
    HapticFeedback.lightImpact();
    // Voice search implementation would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onAddProduct(Map<String, dynamic> product) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/product-detail', arguments: product);
  }

  void _onShowManualEntryForm() {
    setState(() {
      _showManualEntryForm = true;
    });
  }

  void _onHideManualEntryForm() {
    setState(() {
      _showManualEntryForm = false;
    });
  }

  void _onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
        title: Text(
          'Search & Add Products',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/barcode-scanner'),
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: _showManualEntryForm
          ? ManualEntryFormWidget(
              onCancel: _onHideManualEntryForm,
              onSave: (productData) {
                _onHideManualEntryForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added successfully!'),
                    backgroundColor: AppTheme.successLight,
                  ),
                );
              },
            )
          : Column(
              children: [
                // Search Section
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
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText:
                                'Search products by name, SKU, or description',
                            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasisLight,
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: CustomIconWidget(
                                iconName: 'search',
                                color: AppTheme.textMediumEmphasisLight,
                                size: 20,
                              ),
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchFocusNode.unfocus();
                                    },
                                    icon: CustomIconWidget(
                                      iconName: 'clear',
                                      color: AppTheme.textMediumEmphasisLight,
                                      size: 20,
                                    ),
                                  ),
                                IconButton(
                                  onPressed: _onVoiceSearch,
                                  icon: CustomIconWidget(
                                    iconName: 'mic',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            _searchFocusNode.unfocus();
                            _performSearch(value);
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Category Filter
                      Row(
                        children: [
                          Text(
                            'Category:',
                            style: AppTheme.lightTheme.textTheme.labelMedium,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
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
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onCategoryChanged,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Recent Searches
                      if (_recentSearches.isNotEmpty && !_isSearching) ...[
                        SizedBox(height: 2.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recent Searches',
                            style: AppTheme.lightTheme.textTheme.labelMedium,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(
                          height: 5.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _recentSearches.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 2.w),
                            itemBuilder: (context, index) {
                              return RecentSearchChipWidget(
                                searchTerm: _recentSearches[index],
                                onTap: () =>
                                    _onRecentSearchTap(_recentSearches[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Results Section
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _isSearching
                          ? _buildSearchResults()
                          : _buildEmptyState(),
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        return Container(
          height: 12.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 10.h,
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 2.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        height: 1.5.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: _searchResults.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return AddNewProductCardWidget(
            onTap: _onShowManualEntryForm,
          );
        }

        final product = _searchResults[index - 1];
        return SearchResultCardWidget(
          product: product,
          onAddProduct: () => _onAddProduct(product),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.textMediumEmphasisLight,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No products found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms or category filter',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: _onShowManualEntryForm,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Add New Product'),
              style: AppTheme.lightTheme.elevatedButtonTheme.style,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search',
              color: AppTheme.textMediumEmphasisLight,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'Search for products',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Enter product name, SKU, or description to find items in your inventory',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/barcode-scanner'),
                  icon: CustomIconWidget(
                    iconName: 'qr_code_scanner',
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Scan Barcode'),
                  style: AppTheme.lightTheme.elevatedButtonTheme.style,
                ),
                OutlinedButton.icon(
                  onPressed: _onShowManualEntryForm,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Add Manually'),
                  style: AppTheme.lightTheme.outlinedButtonTheme.style,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
