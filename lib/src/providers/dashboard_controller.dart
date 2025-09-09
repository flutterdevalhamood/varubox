import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/rest_client.dart';
import '../repo/auth_repo.dart';

// Label model for product labels
class ProductLabel {
  final int id;
  final String name;
  final String color;
  final String textColor;
  final String status;

  ProductLabel({
    required this.id,
    required this.name,
    required this.color,
    required this.textColor,
    required this.status,
  });

  factory ProductLabel.fromJson(Map<String, dynamic> json) {
    return ProductLabel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#ffffff',
      textColor: json['text_color'] ?? '#000000',
      status: json['status'] ?? 'published',
    );
  }

  // Convert hex color string to Color object
  Color get backgroundColor {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.white;
    }
  }

  Color get foregroundColor {
    try {
      return Color(int.parse(textColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.black;
    }
  }
}

// Product model to handle API response
class Product {
  final int id;
  final String name;
  final String primaryImage;
  final String price;
  final String salePrice;
  final String isFeatured;
  final String reviewsCount;
  final String reviewsAvg;
  final List<ProductLabel> labels;

  Product({
    required this.id,
    required this.name,
    required this.primaryImage,
    required this.price,
    required this.salePrice,
    required this.isFeatured,
    required this.reviewsCount,
    required this.reviewsAvg,
    required this.labels,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse labels
    List<ProductLabel> labelsList = [];
    if (json['labels'] != null && json['labels'] is List) {
      labelsList =
          (json['labels'] as List)
              .map((labelJson) => ProductLabel.fromJson(labelJson))
              .toList();
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['Name'] ?? '',
      primaryImage: json['primary_image'] ?? '',
      price: json['price'] ?? '0.00',
      salePrice: json['sale_price'] ?? '0.00',
      isFeatured: json['is_featured'] ?? '0',
      reviewsCount: json['reviews_count'] ?? '0',
      reviewsAvg: json['reviews_avg'] ?? '0',
      labels: labelsList,
    );
  }

  // Helper methods for price formatting
  double get priceDouble => double.tryParse(price) ?? 0.0;
  double get salePriceDouble => double.tryParse(salePrice) ?? 0.0;
  bool get hasDiscount => salePriceDouble < priceDouble;
  double get discountPercentage =>
      hasDiscount ? ((priceDouble - salePriceDouble) / priceDouble * 100) : 0.0;

  // Check if product is featured
  bool get isProductFeatured => isFeatured == '1';

  // Get published labels only
  List<ProductLabel> get publishedLabels =>
      labels.where((label) => label.status == 'published').toList();
}

class DashboardController with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  int currentPage = 1;
  final int totalPages = 10;
  bool hasMore = true;
  int? id;

  // Product data
  List<Product> products = [];
  bool isProductsLoading = false;
  String? productsErrorMessage;

  Future<bool> _checkToken() async {
    final token = AuthRepo.token;

    // Check if token is valid
    if (token == null || token.isEmpty) {
      debugPrint("No token available - auth failed");
      // Handle missing token
      AuthRepo.handleAuthError();
      return false;
    }

    // Check if token is expired (if implementation supports it)
    if (AuthRepo.isTokenExpired()) {
      debugPrint("Token expired - auth failed");
      // Handle expired token
      AuthRepo.handleAuthError();
      return false;
    }

    return true;
  }

  // Format the token with Bearer prefix
  String _getAuthHeader() {
    return 'Bearer ${AuthRepo.token}';
  }

  Future<void> getProductData() async {
    if (!await _checkToken()) return;

    isProductsLoading = true;
    productsErrorMessage = null;
    notifyListeners();

    try {
      final dashboardProductData = await restApi.getDashboardProduct(
        currentPage,
        totalPages,
        _getAuthHeader(),
      );

      if (dashboardProductData['IsSuccess'] == true) {
        debugPrint('Product data fetched successfully');

        // Parse the products from API response
        final List<dynamic> productList = dashboardProductData['Data'] ?? [];
        products =
            productList
                .map((productJson) => Product.fromJson(productJson))
                .toList();

        debugPrint('Loaded ${products.length} products');

        // Update hasMore based on data availability
        hasMore = products.length >= totalPages;
      } else {
        debugPrint('API call failed: ${dashboardProductData['Message']}');
        productsErrorMessage =
            dashboardProductData['Message'] ?? 'Failed to fetch product data';
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isProductsLoading = false;
      notifyListeners();
    }
  }

  // Method to refresh products
  Future<void> refreshProducts() async {
    currentPage = 1;
    products.clear();
    await getProductData();
  }

  // Method to load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (!hasMore || isProductsLoading) return;

    currentPage++;
    await getProductData();
  }

  // Get product by ID
  Product? getProductById(int productId) {
    try {
      return products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Search products by name
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return products;

    return products
        .where(
          (product) => product.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Filter products by price range
  List<Product> filterProductsByPrice(double minPrice, double maxPrice) {
    return products
        .where(
          (product) =>
              product.salePriceDouble >= minPrice &&
              product.salePriceDouble <= maxPrice,
        )
        .toList();
  }

  // Get featured products (only products with is_featured = "1")
  List<Product> get featuredProducts {
    List<Product> featured =
        products.where((product) => product.isProductFeatured).toList();

    // Sort by discount percentage for better display
    featured.sort(
      (a, b) => b.discountPercentage.compareTo(a.discountPercentage),
    );

    debugPrint('Featured products count: ${featured.length}');
    return featured;
  }

  // Standardized error handling
  dynamic _handleApiError(dynamic e) {
    if (e is DioException) {
      debugPrint("Dio Exception: ${e.message}");

      // Handle redirect to login (authentication failure)
      if (e.response?.statusCode == 302 ||
          (e.response?.data is String &&
              (e.response?.data as String).contains('login'))) {
        debugPrint("Authentication failed - redirected to login page");
        productsErrorMessage = 'Authentication failed. Please log in again.';
        AuthRepo.handleAuthError();
        return false;
      }

      // Log detailed response information
      if (e.response != null) {
        debugPrint('Response status: ${e.response?.statusCode}');
        debugPrint('Response data: ${e.response?.data}');
      }

      productsErrorMessage = 'Network error: ${e.message}';
    } else {
      debugPrint("Error: $e");
      productsErrorMessage = 'Error: ${e.toString()}';
    }
    return false;
  }

  // Clear error messages
  void clearErrors() {
    errorMessage = null;
    productsErrorMessage = null;
    notifyListeners();
  }
}
