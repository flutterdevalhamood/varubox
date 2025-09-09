import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/rest_client.dart';
import '../repo/auth_repo.dart';

class ProductDetailController with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  int? id;

  // Product detail specific properties
  Map<String, dynamic>? productDetail;
  bool get hasProductData => productDetail != null;

  // Computed properties from API response
  String get productName => productDetail?['Name'] ?? 'Unknown Product';
  String get productPrice =>
      '\$${productDetail?['sale_price'] ?? productDetail?['price'] ?? '0.00'}';
  String get originalPrice => '\$${productDetail?['price'] ?? '0.00'}';
  String get productImage => productDetail?['primary_image'] ?? '';
  String get productDescription =>
      _stripHtmlTags(productDetail?['description'] ?? '');
  String get productContent => _stripHtmlTags(productDetail?['content'] ?? '');
  String get reviewsCount => productDetail?['reviews_count']?.toString() ?? '0';
  String get reviewsAverage =>
      productDetail?['reviews_avg']?.toString() ?? '0.0';
  List<dynamic> get productImages => productDetail?['product_images'] ?? [];

  // New properties for labels and FAQs
  List<dynamic> get productLabels => productDetail?['labels'] ?? [];
  List<dynamic> get productFaqs => productDetail?['faqs'] ?? [];

  // Check if product has sale price
  bool get hasDiscount =>
      productDetail?['sale_price'] != null &&
      productDetail?['sale_price'] != productDetail?['price'];

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

  Future<void> getProductDetail() async {
    if (!await _checkToken()) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (id == null) {
        throw Exception("Product ID is required");
      }

      final productDetailData = await restApi.getProductDetail(
        id: id,
        token: _getAuthHeader(),
      );

      if (productDetailData['IsSuccess'] == true) {
        productDetail = productDetailData['Data'] as Map<String, dynamic>;
        debugPrint("Product detail loaded: ${productDetail?['Name']}");
        debugPrint("Labels count: ${productLabels.length}");
        debugPrint("FAQs count: ${productFaqs.length}");
      } else {
        errorMessage =
            productDetailData['Message'] ?? 'Failed to fetch product details';
      }
    } catch (e) {
      _handleApiError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to strip HTML tags from description
  String _stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';

    // Remove HTML tags
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String result = htmlString.replaceAll(exp, '');

    // Replace common HTML entities
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&quot;', '"');

    // Clean up extra whitespace
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }

  // Public method to strip HTML tags (used in the UI)
  String stripHtmlTags(String htmlString) {
    return _stripHtmlTags(htmlString);
  }

  // Helper method to get label by status
  List<dynamic> getPublishedLabels() {
    return productLabels
        .where((label) => label['status'] == 'published')
        .toList();
  }

  // Helper method to get FAQ by status
  List<dynamic> getPublishedFaqs() {
    return productFaqs.where((faq) => faq['status'] == 'published').toList();
  }

  // Helper method to check if product has any labels
  bool get hasLabels => productLabels.isNotEmpty;

  // Helper method to check if product has any FAQs
  bool get hasFaqs => productFaqs.isNotEmpty;

  // Helper method to get label colors
  Color getLabelBackgroundColor(Map<String, dynamic> label) {
    try {
      String colorString = label['color'] ?? '#4CAF50';
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4CAF50); // Default green color
    }
  }

  Color getLabelTextColor(Map<String, dynamic> label) {
    try {
      String colorString = label['text_color'] ?? '#FFFFFF';
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFFFFFFFF); // Default white color
    }
  }

  // Standardized error handling
  void _handleApiError(dynamic e) {
    if (e is DioException) {
      debugPrint("Dio Exception: ${e.message}");

      // Handle redirect to login (authentication failure)
      if (e.response?.statusCode == 302 ||
          (e.response?.data is String &&
              (e.response?.data as String).contains('login'))) {
        debugPrint("Authentication failed - redirected to login page");
        errorMessage = 'Authentication failed. Please log in again.';
        AuthRepo.handleAuthError();
        return;
      }

      // Handle different status codes
      switch (e.response?.statusCode) {
        case 404:
          errorMessage = 'Product not found';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      // Log detailed response information
      if (e.response != null) {
        debugPrint('Response status: ${e.response?.statusCode}');
        debugPrint('Response data: ${e.response?.data}');
      }
    } else {
      debugPrint("Error: $e");
      errorMessage = 'Error: ${e.toString()}';
    }
  }

  // Clear error messages
  void clearErrors() {
    errorMessage = null;
    notifyListeners();
  }

  // Reset product data
  void resetProductData() {
    productDetail = null;
    errorMessage = null;
    id = null;
    notifyListeners();
  }

  // Set product ID and fetch details
  void setProductId(int productId) {
    // Clear previous product data immediately when switching products
    if (id != productId) {
      productDetail = null;
      errorMessage = null;
      notifyListeners();
    }

    id = productId;
    getProductDetail();
  }
}
