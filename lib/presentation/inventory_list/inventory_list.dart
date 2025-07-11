import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import './widgets/bulk_action_bar_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/inventory_item_card_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';

class InventoryList extends StatefulWidget {
  const InventoryList({Key? key}) : super(key: key);

  @override
  State<InventoryList> createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ProductService _productService = ProductService();

  bool _isSearching = false;
  bool _isBulkSelectionMode = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSortOption = 'Name';
  List<String> _activeFilters = [];
  Set<String> _selectedItems = {};
  int _currentTabIndex = 2; // Inventory tab active

  // Data from Supabase
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _recentSearches = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getProducts();
      final categories = await _productService.getCategories();

      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
          _availableCategories = categories;
          _isLoading = false;
        });
        _filterItems();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load inventory: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterItems();
    });
  }

  void _filterItems() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.namaProduk
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          product.kategori.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.barcode
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);

      final matchesFilters = _activeFilters.isEmpty ||
          _activeFilters.every((filter) => _itemMatchesFilter(product, filter));

      return matchesSearch && matchesFilters;
    }).toList();

    _sortItems();
  }

  bool _itemMatchesFilter(ProductModel product, String filter) {
    switch (filter) {
      case 'In Stock':
        return product.totalStock > 10;
      case 'Low Stock':
        return product.totalStock > 0 && product.totalStock <= 10;
      case 'Out of Stock':
        return product.totalStock == 0;
      case 'Active':
        return product.status == 'aktif';
      case 'Inactive':
        return product.status == 'nonaktif';
      default:
        // Check if filter is a category
        if (_availableCategories.contains(filter)) {
          return product.kategori == filter;
        }
        return true;
    }
  }

  void _sortItems() {
    switch (_selectedSortOption) {
      case 'Name':
        _filteredProducts.sort((a, b) => a.namaProduk.compareTo(b.namaProduk));
        break;
      case 'Stock':
        _filteredProducts.sort((a, b) => b.totalStock.compareTo(a.totalStock));
        break;
      case 'Price':
        _filteredProducts
            .sort((a, b) => b.hargaSatuan.compareTo(a.hargaSatuan));
        break;
      case 'Date Added':
        _filteredProducts
            .sort((a, b) => b.tanggalDibuat.compareTo(a.tanggalDibuat));
        break;
      case 'Category':
        _filteredProducts.sort((a, b) => a.kategori.compareTo(b.kategori));
        break;
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
      _filterItems();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchController.clear();
      _searchQuery = '';
      _filterItems();
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SortBottomSheetWidget(
        selectedOption: _selectedSortOption,
        onSortChanged: (option) {
          setState(() {
            _selectedSortOption = option;
            _sortItems();
          });
        },
      ),
    );
  }

  void _toggleBulkSelection() {
    setState(() {
      _isBulkSelectionMode = !_isBulkSelectionMode;
      if (!_isBulkSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _selectAllItems() {
    setState(() {
      _selectedItems = _filteredProducts.map((product) => product.id).toSet();
    });
  }

  void _deselectAllItems() {
    setState(() {
      _selectedItems.clear();
    });
  }

  Future<void> _refreshInventory() async {
    await _loadData();
  }

  void _deleteSelectedItems() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Items'),
        content: Text(
            'Are you sure you want to delete ${_selectedItems.length} selected items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Delete selected items
                for (String itemId in _selectedItems) {
                  await _productService.deleteProduct(itemId);
                }

                // Refresh data
                await _loadData();

                setState(() {
                  _selectedItems.clear();
                  _isBulkSelectionMode = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Items deleted successfully')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete items: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSelectedItems() {
    // Simulate export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_selectedItems.length} items to CSV'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          if (_activeFilters.isNotEmpty) _buildFilterChips(),
          Expanded(
            child: _buildInventoryList(),
          ),
        ],
      ),
      bottomNavigationBar:
          _isBulkSelectionMode ? null : _buildBottomNavigationBar(),
      floatingActionButton:
          _isBulkSelectionMode ? null : _buildFloatingActionButton(),
      bottomSheet: _isBulkSelectionMode
          ? BulkActionBarWidget(
              selectedCount: _selectedItems.length,
              onDelete: _deleteSelectedItems,
              onExport: _exportSelectedItems,
              onSelectAll: _selectAllItems,
              onDeselectAll: _deselectAllItems,
              onCancel: _toggleBulkSelection,
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Inventory List',
        style: AppTheme.lightTheme.textTheme.titleLarge,
      ),
      actions: [
        if (!_isBulkSelectionMode)
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: CustomIconWidget(
              iconName: 'sort',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        if (_isBulkSelectionMode)
          TextButton(
            onPressed: _toggleBulkSelection,
            child: Text('Cancel'),
          ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search items, categories, or barcodes...',
              prefixIcon: CustomIconWidget(
                iconName: 'search',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    )
                  : null,
            ),
            onTap: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          if (_isSearching &&
              _searchQuery.isEmpty &&
              _recentSearches.isNotEmpty)
            _buildRecentSearches(),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _recentSearches
                .map((search) => GestureDetector(
                      onTap: () {
                        _searchController.text = search;
                        setState(() {
                          _isSearching = false;
                        });
                      },
                      child: Chip(
                        label: Text(search),
                        backgroundColor: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _activeFilters.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChipWidget(
                    label: 'Clear All',
                    isActive: false,
                    onTap: _clearAllFilters,
                    isAction: true,
                  );
                }
                final filter = _activeFilters[index - 1];
                return FilterChipWidget(
                  label: filter,
                  isActive: true,
                  onTap: () => _toggleFilter(filter),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshInventory,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          final isSelected = _selectedItems.contains(product.id);

          return InventoryItemCardWidget(
            item: {
              'id': product.id,
              'name': product.namaProduk,
              'barcode': product.barcode ?? product.sku,
              'category': product.kategori,
              'quantity': product.totalStock,
              'lastUpdated': product.updatedAt ?? product.tanggalDibuat,
              'image': product.imageUrl ??
                  'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?fm=jpg&q=60&w=400',
              'price': product.formattedPrice,
              'status': product.stockStatus,
            },
            isSelected: isSelected,
            isBulkSelectionMode: _isBulkSelectionMode,
            onTap: () {
              if (_isBulkSelectionMode) {
                _toggleItemSelection(product.id);
              } else {
                Navigator.pushNamed(context, '/product-detail',
                    arguments: product.id);
              }
            },
            onLongPress: () {
              if (!_isBulkSelectionMode) {
                _toggleBulkSelection();
                _toggleItemSelection(product.id);
              }
            },
            onEdit: () {
              Navigator.pushNamed(context, '/product-detail',
                  arguments: product.id);
            },
            onDelete: () {
              _showDeleteConfirmation(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'inventory_2',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                ? 'No items found'
                : 'No inventory items',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Start scanning items to build your inventory',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty || _activeFilters.isNotEmpty) ...[
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _clearAllFilters,
              child: Text('Clear Filters'),
            ),
          ] else ...[
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/barcode-scanner');
              },
              child: Text('Start Scanning'),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content:
            Text('Are you sure you want to delete "${product.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _productService.deleteProduct(product.id);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product deleted successfully')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete product: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          _currentTabIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/dashboard-home');
            break;
          case 1:
            Navigator.pushNamed(context, '/barcode-scanner');
            break;
          case 2:
            // Current screen
            break;
          case 3:
            Navigator.pushNamed(context, '/search-manual-entry');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: _currentTabIndex == 0
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'qr_code_scanner',
            color: _currentTabIndex == 1
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'inventory_2',
            color: _currentTabIndex == 2
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'search',
            color: _currentTabIndex == 3
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Search',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/barcode-scanner');
      },
      child: CustomIconWidget(
        iconName: 'qr_code_scanner',
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
