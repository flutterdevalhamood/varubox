import 'dart:ui';

import 'package:flutter/foundation.dart';

class FavoritesController extends ChangeNotifier {
  final List<FavoriteItem> _favoriteItems = [];

  // Getter for favorite items
  List<FavoriteItem> get favoriteItems => List.unmodifiable(_favoriteItems);

  // Get the count of favorite items
  int get favoriteCount => _favoriteItems.length;

  // Check if an item is in favorites
  bool isFavorite(String productId) {
    return _favoriteItems.any((item) => item.id == productId);
  }

  // Add item to favorites
  void addToFavorites(FavoriteItem item) {
    if (!isFavorite(item.id)) {
      _favoriteItems.add(item);
      notifyListeners();
    }
  }

  // Remove item from favorites
  void removeFromFavorites(String productId) {
    _favoriteItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  // Toggle favorite status
  bool toggleFavorite(FavoriteItem item) {
    if (isFavorite(item.id)) {
      removeFromFavorites(item.id);
      return false; // Removed from favorites
    } else {
      addToFavorites(item);
      return true; // Added to favorites
    }
  }

  // Get a specific favorite item by ID
  FavoriteItem? getFavoriteItem(String productId) {
    try {
      return _favoriteItems.firstWhere((item) => item.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Update quantity of a favorite item
  void updateFavoriteQuantity(String productId, int newQuantity) {
    final index = _favoriteItems.indexWhere((item) => item.id == productId);
    if (index != -1 && newQuantity > 0) {
      final item = _favoriteItems[index];
      _favoriteItems[index] = FavoriteItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: newQuantity,
        weight: item.weight,
        unit: item.unit,
        imagePath: item.imagePath,
        backgroundColor: item.backgroundColor,
      );
      notifyListeners();
    }
  }

  // Increment quantity of a favorite item
  void incrementQuantity(String productId) {
    final item = getFavoriteItem(productId);
    if (item != null) {
      updateFavoriteQuantity(productId, item.quantity + 1);
    }
  }

  // Decrement quantity of a favorite item
  void decrementQuantity(String productId) {
    final item = getFavoriteItem(productId);
    if (item != null && item.quantity > 1) {
      updateFavoriteQuantity(productId, item.quantity - 1);
    }
  }

  // Clear all favorites
  void clearAllFavorites() {
    _favoriteItems.clear();
    notifyListeners();
  }

  // Get total value of all favorite items
  double getTotalFavoritesValue() {
    double total = 0.0;
    for (var item in _favoriteItems) {
      double price = double.tryParse(item.price) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  // Check if favorites is empty
  bool get isEmpty => _favoriteItems.isEmpty;

  // Check if favorites is not empty
  bool get isNotEmpty => _favoriteItems.isNotEmpty;
}

class FavoriteItem {
  final String id;
  final String name;
  final String price;
  final int quantity;
  final String weight;
  final String unit;
  final String imagePath;
  final Color backgroundColor;

  FavoriteItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.weight,
    required this.unit,
    required this.imagePath,
    required this.backgroundColor,
  });

  // Create a copy of the item with updated values
  FavoriteItem copyWith({
    String? id,
    String? name,
    String? price,
    int? quantity,
    String? weight,
    String? unit,
    String? imagePath,
    Color? backgroundColor,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      imagePath: imagePath ?? this.imagePath,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FavoriteItem{id: $id, name: $name, price: $price, quantity: $quantity}';
  }
}
