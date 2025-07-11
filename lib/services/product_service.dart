import '../models/product_model.dart';
import './supabase_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  // Get all products with optional filtering
  Future<List<ProductModel>> getProducts({
    String? searchQuery,
    String? kategori,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final client = await _supabaseService.client;
      var query = client
          .from('products')
          .select('*, suppliers(name)');

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'nama_produk.ilike.%$searchQuery%,'
          'sku.ilike.%$searchQuery%,'
          'kode_produk.ilike.%$searchQuery%,'
          'barcode.ilike.%$searchQuery%'
        );
      }

      if (kategori != null && kategori.isNotEmpty) {
        query = query.eq('kategori', kategori);
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      // Apply pagination and execute query
      if (offset != null && limit != null) {
        final response = await query
            .range(offset, offset + limit - 1)
            .order('created_at', ascending: false);
        return response.map((data) => ProductModel.fromJson(data)).toList();
      } else if (limit != null) {
        final response = await query
            .order('created_at', ascending: false)
            .limit(limit);
        return response.map((data) => ProductModel.fromJson(data)).toList();
      } else {
        final response = await query.order('created_at', ascending: false);
        return response.map((data) => ProductModel.fromJson(data)).toList();
      }
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }

  // Get single product by ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('products')
          .select('*, suppliers(name)')
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return ProductModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch product: $error');
    }
  }

  // Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('products')
          .select('*, suppliers(name)')
          .eq('barcode', barcode)
          .maybeSingle();
      
      if (response == null) return null;
      return ProductModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch product by barcode: $error');
    }
  }

  // Create new product
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final client = await _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final productData = product.toJson();
      productData['created_by'] = userId;

      final response = await client
          .from('products')
          .insert(productData)
          .select('*, suppliers(name)')
          .single();

      return ProductModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create product: $error');
    }
  }

  // Update product
  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    try {
      final client = await _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final productData = product.toJson();
      productData['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('products')
          .update(productData)
          .eq('id', id)
          .select('*, suppliers(name)')
          .single();

      return ProductModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    try {
      final client = await _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await client
          .from('products')
          .delete()
          .eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }

  // Get products count
  Future<int> getProductsCount({
    String? searchQuery,
    String? kategori,
    String? status,
  }) async {
    try {
      final client = await _supabaseService.client;
      var query = client
          .from('products')
          .select('*');

      // Apply filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'nama_produk.ilike.%$searchQuery%,'
          'sku.ilike.%$searchQuery%,'
          'kode_produk.ilike.%$searchQuery%,'
          'barcode.ilike.%$searchQuery%'
        );
      }

      if (kategori != null && kategori.isNotEmpty) {
        query = query.eq('kategori', kategori);
      }

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      final response = await query;
      return response.length;
    } catch (error) {
      throw Exception('Failed to get products count: $error');
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('categories')
          .select('name')
          .order('name');

      return response.map((data) => data['name'] as String).toList();
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  // Get sub-categories by category
  Future<List<String>> getSubCategories(String categoryName) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('sub_categories')
          .select('name')
          .eq('category_id', categoryName)
          .order('name');

      return response.map((data) => data['name'] as String).toList();
    } catch (error) {
      throw Exception('Failed to fetch sub-categories: $error');
    }
  }

  // Get suppliers
  Future<List<String>> getSuppliers() async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('suppliers')
          .select('name')
          .order('name');

      return response.map((data) => data['name'] as String).toList();
    } catch (error) {
      throw Exception('Failed to fetch suppliers: $error');
    }
  }

  // Update stock quantities
  Future<void> updateStock(String productId, int partai, int keliling, int ecer, String notes) async {
    try {
      final client = await _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get current product data
      final currentProduct = await getProductById(productId);
      if (currentProduct == null) {
        throw Exception('Product not found');
      }

      final previousTotal = currentProduct.partai + currentProduct.keliling + currentProduct.ecer;
      final newTotal = partai + keliling + ecer;
      final difference = newTotal - previousTotal;

      // Update product stock
      await client
          .from('products')
          .update({
            'partai': partai,
            'keliling': keliling,
            'ecer': ecer,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      // Record inventory transaction
      await client
          .from('inventory_transactions')
          .insert({
            'product_id': productId,
            'transaction_type': difference > 0 ? 'in' : difference < 0 ? 'out' : 'adjustment',
            'quantity': difference.abs(),
            'previous_stock': previousTotal,
            'new_stock': newTotal,
            'notes': notes,
            'created_by': userId,
          });
    } catch (error) {
      throw Exception('Failed to update stock: $error');
    }
  }

  // Get inventory transactions for a product
  Future<List<Map<String, dynamic>>> getInventoryTransactions(String productId) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('inventory_transactions')
          .select('*, user_profiles!created_by(full_name)')
          .eq('product_id', productId)
          .order('created_at', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch inventory transactions: $error');
    }
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final client = await _supabaseService.client;
      
      final results = await Future.wait([
        // Total products count
        client
            .from('products')
            .select('*')
            .eq('status', 'aktif'),
        
        // Products scanned today
        client
            .from('inventory_transactions')
            .select('*')
            .gte('created_at', DateTime.now().subtract(Duration(days: 1)).toIso8601String()),
        
        // Categories count
        client
            .from('categories')
            .select('*'),
        
        // Low stock items
        client
            .from('products')
            .select('*')
            .lt('partai', 10)
            .lt('keliling', 10)
            .lt('ecer', 10)
      ]);

      return {
        'totalItems': results[0].length,
        'todaysScans': results[1].length,
        'categories': results[2].length,
        'lowStockItems': results[3].length,
        'lastSync': DateTime.now().toIso8601String(),
        'syncStatus': 'success',
      };
    } catch (error) {
      throw Exception('Failed to fetch dashboard stats: $error');
    }
  }

  // Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 10}) async {
    try {
      final client = await _supabaseService.client;
      final response = await client
          .from('inventory_transactions')
          .select('*, products!product_id(nama_produk, sku, image_url, harga_satuan, kategori), user_profiles!created_by(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch recent activity: $error');
    }
  }
}