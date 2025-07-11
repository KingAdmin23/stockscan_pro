import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/product_service.dart';
import '../../services/supabase_service.dart';
import './widgets/recent_activity_item_widget.dart';
import './widgets/start_scanning_card_widget.dart';
import './widgets/stats_card_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isRefreshing = false;
  bool _isLoading = true;

  final ProductService _productService = ProductService();
  final SupabaseService _supabaseService = SupabaseService();

  // Data from Supabase
  Map<String, dynamic> dashboardStats = {
    "todaysScans": 0,
    "totalItems": 0,
    "categories": 0,
    "lowStockItems": 0,
    "lastSync": "Loading...",
    "syncStatus": "loading"
  };

  List<Map<String, dynamic>> recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load dashboard stats and recent activity from Supabase
      final stats = await _productService.getDashboardStats();
      final activity = await _productService.getRecentActivity();

      if (mounted) {
        setState(() {
          dashboardStats = stats;
          recentActivity = activity;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.primaryColor,
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: _buildHeader(isDark),
              ),

              // Hero Section - Start Scanning Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: StartScanningCardWidget(
                    itemCount: dashboardStats["totalItems"] as int,
                    onTap: () => _navigateToScanner(),
                  ),
                ),
              ),

              // Stats Cards Section
              SliverToBoxAdapter(
                child: _buildStatsSection(isDark),
              ),

              // Recent Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      TextButton(
                        onPressed: () => _navigateToInventoryList(),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Activity List
              _isLoading
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.h),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : recentActivity.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = recentActivity[index];
                              final product =
                                  item['products'] as Map<String, dynamic>?;
                              final user = item['user_profiles']
                                  as Map<String, dynamic>?;

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 0.5.h,
                                ),
                                child: RecentActivityItemWidget(
                                  productName: product?['nama_produk'] ??
                                      'Unknown Product',
                                  barcode: product?['sku'] ?? 'N/A',
                                  category: product?['kategori'] ?? 'Unknown',
                                  quantity: item['quantity'] ?? 0,
                                  timestamp: item['created_at'] ??
                                      DateTime.now().toIso8601String(),
                                  imageUrl: product?['image_url'] ??
                                      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop',
                                  price:
                                      'Rp ${(product?['harga_satuan'] ?? 0).toStringAsFixed(0)}',
                                  onTap: () => _navigateToProductDetail(
                                      item['product_id'] ?? ''),
                                  onEdit: () =>
                                      _handleEditItem(item['product_id'] ?? ''),
                                  onDelete: () => _handleDeleteItem(
                                      item['product_id'] ?? ''),
                                ),
                              );
                            },
                            childCount: recentActivity.length,
                          ),
                        ),

              // Bottom padding for FAB
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
      floatingActionButton: _buildFloatingActionButton(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'SS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StockScan Pro',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Inventory Management',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showNotifications(),
            child: Container(
              width: 10.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                ),
              ),
              child: Center(
                child: Stack(
                  children: [
                    CustomIconWidget(
                      iconName: 'notifications_outlined',
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                      size: 20,
                    ),
                    if (dashboardStats["lowStockItems"] > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.errorLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Container(
      height: 12.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          StatsCardWidget(
            title: 'Today\'s Scans',
            value: dashboardStats["todaysScans"].toString(),
            icon: 'qr_code_scanner',
            color: AppTheme.successLight,
            onTap: () => _showStatsDetail('Today\'s Scans'),
          ),
          SizedBox(width: 3.w),
          StatsCardWidget(
            title: 'Total Items',
            value: _formatNumber(dashboardStats["totalItems"] as int),
            icon: 'inventory_2',
            color: AppTheme.lightTheme.primaryColor,
            onTap: () => _showStatsDetail('Total Items'),
          ),
          SizedBox(width: 3.w),
          StatsCardWidget(
            title: 'Categories',
            value: dashboardStats["categories"].toString(),
            icon: 'category',
            color: AppTheme.warningLight,
            onTap: () => _showStatsDetail('Categories'),
          ),
          SizedBox(width: 3.w),
          StatsCardWidget(
            title: 'Low Stock',
            value: dashboardStats["lowStockItems"].toString(),
            icon: 'warning',
            color: AppTheme.errorLight,
            onTap: () => _showStatsDetail('Low Stock'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),
          CustomIconWidget(
            iconName: 'qr_code_scanner',
            size: 80,
            color:
                isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight,
          ),
          SizedBox(height: 3.h),
          Text(
            'No Items Scanned Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start scanning your first item to see it appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textDisabledDark
                      : AppTheme.textDisabledLight,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => _navigateToScanner(),
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: Colors.white,
              size: 20,
            ),
            label: Text('Scan Your First Item'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: AppTheme.lightTheme.primaryColor,
      unselectedItemColor:
          isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home_outlined',
            size: 24,
            color: _selectedIndex == 0
                ? AppTheme.lightTheme.primaryColor
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
          activeIcon: CustomIconWidget(
            iconName: 'home',
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'qr_code_scanner_outlined',
            size: 24,
            color: _selectedIndex == 1
                ? AppTheme.lightTheme.primaryColor
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
          activeIcon: CustomIconWidget(
            iconName: 'qr_code_scanner',
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'inventory_2_outlined',
            size: 24,
            color: _selectedIndex == 2
                ? AppTheme.lightTheme.primaryColor
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
          activeIcon: CustomIconWidget(
            iconName: 'inventory_2',
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'assessment_outlined',
            size: 24,
            color: _selectedIndex == 3
                ? AppTheme.lightTheme.primaryColor
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
          activeIcon: CustomIconWidget(
            iconName: 'assessment',
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person_outlined',
            size: 24,
            color: _selectedIndex == 4
                ? AppTheme.lightTheme.primaryColor
                : (isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight),
          ),
          activeIcon: CustomIconWidget(
            iconName: 'person',
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(bool isDark) {
    return FloatingActionButton(
      onPressed: () => _navigateToScanner(),
      backgroundColor: AppTheme.lightTheme.primaryColor,
      child: CustomIconWidget(
        iconName: 'qr_code_scanner',
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // Navigation methods
  void _navigateToScanner() {
    Navigator.pushNamed(context, '/barcode-scanner');
  }

  void _navigateToProductDetail(String productId) {
    Navigator.pushNamed(context, '/product-detail', arguments: productId);
  }

  void _navigateToInventoryList() {
    Navigator.pushNamed(context, '/inventory-list');
  }

  void _navigateToSearchManualEntry() {
    Navigator.pushNamed(context, '/search-manual-entry');
  }

  // Event handlers
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        _navigateToScanner();
        break;
      case 2:
        _navigateToInventoryList();
        break;
      case 3:
        // Navigate to reports (not implemented)
        break;
      case 4:
        // Navigate to profile (not implemented)
        break;
    }
  }

  Future<void> _handleRefresh() async {
    await _loadDashboardData();
  }

  void _handleEditItem(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit item: $itemId'),
        action: SnackBarAction(
          label: 'Edit',
          onPressed: () => _navigateToProductDetail(itemId),
        ),
      ),
    );
  }

  void _handleDeleteItem(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content:
            Text('Are you sure you want to delete this item from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _productService.deleteProduct(itemId);
                await _loadDashboardData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Item deleted successfully')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete item: $error'),
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

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            if (dashboardStats["lowStockItems"] > 0)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.warningLight,
                  size: 24,
                ),
                title: Text('Low stock alert'),
                subtitle: Text(
                    '${dashboardStats["lowStockItems"]} items below minimum threshold'),
              ),
            ListTile(
              leading: CustomIconWidget(
                iconName: dashboardStats["syncStatus"] == "success"
                    ? 'sync'
                    : 'sync_problem',
                color: dashboardStats["syncStatus"] == "success"
                    ? AppTheme.successLight
                    : AppTheme.errorLight,
                size: 24,
              ),
              title: Text('Sync ${dashboardStats["syncStatus"]}'),
              subtitle: Text('Data synchronized with server'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDetail(String statType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statType,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Text(
              'Detailed breakdown for $statType will be shown here.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
