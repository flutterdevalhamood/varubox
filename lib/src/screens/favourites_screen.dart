import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteItem> favoriteItems = [
    FavoriteItem(
      id: '1',
      name: 'Fresh Broccoli',
      price: '2.22',
      quantity: 5,
      weight: '1.50',
      unit: 'lbs',
      imagePath: '🥦',
      backgroundColor: const Color(0xFFE8F5E8),
    ),
    FavoriteItem(
      id: '2',
      name: 'Black Grapes',
      price: '2.22',
      quantity: 5,
      weight: '5.0',
      unit: 'lbs',
      imagePath: '🍇',
      backgroundColor: const Color(0xFFF5E8F5),
    ),
    FavoriteItem(
      id: '3',
      name: 'Avacoda',
      price: '2.22',
      quantity: 5,
      weight: '1.50',
      unit: 'lbs',
      imagePath: '🥑',
      backgroundColor: const Color(0xFFF0F8E8),
    ),
    FavoriteItem(
      id: '4',
      name: 'Pineapple',
      price: '2.22',
      quantity: 5,
      weight: 'dozen',
      unit: '',
      imagePath: '🍍',
      backgroundColor: const Color(0xFFFFF8E1),
    ),
  ];

  void _showDeleteConfirmation(FavoriteItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to remove "${item.name}" from your favorites?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(item.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String itemId) {
    setState(() {
      favoriteItems.removeWhere((item) => item.id == itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _incrementQuantity(String itemId) {
    setState(() {
      final index = favoriteItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = favoriteItems[index];
        favoriteItems[index] = FavoriteItem(
          id: item.id,
          name: item.name,
          price: item.price,
          quantity: item.quantity + 1,
          weight: item.weight,
          unit: item.unit,
          imagePath: item.imagePath,
          backgroundColor: item.backgroundColor,
        );
      }
    });
  }

  void _decrementQuantity(String itemId) {
    setState(() {
      final index = favoriteItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        final item = favoriteItems[index];
        if (item.quantity > 1) {
          favoriteItems[index] = FavoriteItem(
            id: item.id,
            name: item.name,
            price: item.price,
            quantity: item.quantity - 1,
            weight: item.weight,
            unit: item.unit,
            imagePath: item.imagePath,
            backgroundColor: item.backgroundColor,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          favoriteItems.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add items to your favorites to see them here',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  final item = favoriteItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FavoriteItemCard(
                      item: item,
                      onDelete: () => _showDeleteConfirmation(item),
                      onIncrement: () => _incrementQuantity(item.id),
                      onDecrement: () => _decrementQuantity(item.id),
                    ),
                  );
                },
              ),
    );
  }
}

class FavoriteItemCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onDelete;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const FavoriteItemCard({
    Key? key,
    required this.item,
    required this.onDelete,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // Don't auto-dismiss, show confirmation dialog instead
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: item.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.imagePath,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${item.price}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        ' x 4',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.unit.isNotEmpty
                        ? '${item.weight} ${item.unit}'
                        : item.weight,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                // Add Button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onIncrement,
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),

                const SizedBox(height: 8),

                // Quantity Display
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                // Remove Button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: item.quantity > 1 ? onDecrement : null,
                    icon: Icon(
                      Icons.remove,
                      color: item.quantity > 1 ? Colors.white : Colors.white54,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
}
