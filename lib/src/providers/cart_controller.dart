import 'package:flutter/material.dart';

// Updated CartItem model to work with API data
class CartItem {
  final int id;
  final String name;
  final double price;
  final double salePrice;
  int quantity;
  final String primaryImage;
  final String unit;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.salePrice,
    required this.quantity,
    required this.primaryImage,
    this.unit = '',
  });

  double get effectivePrice => salePrice > 0 ? salePrice : price;
  double get totalPrice => effectivePrice * quantity;
  bool get hasDiscount => salePrice > 0 && salePrice < price;

  // Convert to/from JSON for persistence if needed
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'salePrice': salePrice,
    'quantity': quantity,
    'primaryImage': primaryImage,
    'unit': unit,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    salePrice: json['salePrice'],
    quantity: json['quantity'],
    primaryImage: json['primaryImage'],
    unit: json['unit'] ?? '',
  );

  // Create CartItem from API product data
  factory CartItem.fromProductData(
    Map<String, dynamic> productData,
    int quantity,
  ) {
    return CartItem(
      id: productData['id'],
      name: productData['Name'] ?? productData['name'] ?? 'Unknown Product',
      price: double.tryParse(productData['price']?.toString() ?? '0') ?? 0.0,
      salePrice:
          double.tryParse(productData['sale_price']?.toString() ?? '0') ?? 0.0,
      quantity: quantity,
      primaryImage: productData['primary_image'] ?? productData['image'] ?? '',
      unit: productData['unit'] ?? '',
    );
  }
}

class CartController with ChangeNotifier {
  List<CartItem> _cartItems = [];
  static const double shippingCharges = 1.60;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal + shippingCharges;

  // Add item to cart
  void addToCart(Map<String, dynamic> productData, int quantity) {
    final productId = productData['id'];

    // Check if item already exists in cart
    final existingIndex = _cartItems.indexWhere((item) => item.id == productId);

    if (existingIndex >= 0) {
      // Update existing item quantity
      _cartItems[existingIndex].quantity += quantity;
    } else {
      // Add new item to cart
      final cartItem = CartItem.fromProductData(productData, quantity);
      _cartItems.add(cartItem);
    }

    notifyListeners();
    debugPrint('Added to cart: ${productData['Name']} x $quantity');
  }

  // Update item quantity
  void updateQuantity(int productId, int newQuantity) {
    if (newQuantity < 1) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      _cartItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Remove item from cart
  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
    debugPrint('Removed from cart: Product ID $productId');
  }

  // Clear entire cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    debugPrint('Cart cleared');
  }

  // Get quantity of specific item in cart
  int getItemQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.id == productId,
      orElse:
          () => CartItem(
            id: -1,
            name: '',
            price: 0,
            salePrice: 0,
            quantity: 0,
            primaryImage: '',
          ),
    );
    return item.id == -1 ? 0 : item.quantity;
  }

  // Check if product is in cart
  bool isInCart(int productId) {
    return _cartItems.any((item) => item.id == productId);
  }

  // Get cart item by product ID
  CartItem? getCartItem(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Simulate checkout process
  Future<bool> checkout() async {
    try {
      // Here you would normally send cart data to your API
      await Future.delayed(const Duration(seconds: 2));

      // Clear cart after successful checkout
      clearCart();

      return true;
    } catch (e) {
      debugPrint('Checkout error: $e');
      return false;
    }
  }
}
