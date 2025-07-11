import 'package:flutter/material.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/barcode_scanner/barcode_scanner.dart';
import '../presentation/inventory_list/inventory_list.dart';
import '../presentation/search_manual_entry/search_manual_entry.dart';
import '../presentation/product_detail/product_detail.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboardHome = '/dashboard-home';
  static const String barcodeScanner = '/barcode-scanner';
  static const String inventoryList = '/inventory-list';
  static const String searchManualEntry = '/search-manual-entry';
  static const String productDetail = '/product-detail';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const DashboardHome(),
    dashboardHome: (context) => const DashboardHome(),
    barcodeScanner: (context) => const BarcodeScanner(),
    inventoryList: (context) => const InventoryList(),
    searchManualEntry: (context) => const SearchManualEntry(),
    productDetail: (context) => const ProductDetail(),
    // TODO: Add your other routes here
  };
}
