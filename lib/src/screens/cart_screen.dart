import 'package:flutter/material.dart';

// Model class for cart items
class CartItem {
  final String id;
  final String name;
  final double price;
  final int multiplier;
  int quantity;
  final String weight;
  final String unit;
  final String imagePath;
  final Color backgroundColor;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.multiplier,
    required this.quantity,
    required this.weight,
    required this.unit,
    required this.imagePath,
    required this.backgroundColor,
  });

  double get totalPrice => price * multiplier * quantity;
}

// Model class for cart summary
class CartSummary {
  final double subtotal;
  final double shippingCharges;

  CartSummary({required this.subtotal, required this.shippingCharges});

  double get total => subtotal + shippingCharges;
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      name: 'Fresh Broccoli',
      price: 2.22,
      multiplier: 4,
      quantity: 5,
      weight: '1.50',
      unit: 'lbs',
      imagePath: '🥦',
      backgroundColor: const Color(0xFFE8F5E8),
    ),
    CartItem(
      id: '2',
      name: 'Black Grapes',
      price: 2.22,
      multiplier: 4,
      quantity: 5,
      weight: '5.0',
      unit: 'lbs',
      imagePath: '🍇',
      backgroundColor: const Color(0xFFF5E8F5),
    ),
    CartItem(
      id: '3',
      name: 'Avacoda',
      price: 2.22,
      multiplier: 4,
      quantity: 5,
      weight: '1.50',
      unit: 'lbs',
      imagePath: '🥑',
      backgroundColor: const Color(0xFFF0F8E8),
    ),
    CartItem(
      id: '4',
      name: 'Pineapple',
      price: 2.22,
      multiplier: 4,
      quantity: 5,
      weight: 'dozen',
      unit: '',
      imagePath: '🍍',
      backgroundColor: const Color(0xFFFFF8E1),
    ),
  ];

  static const double shippingCharges = 1.60;
  late AnimationController _checkoutAnimationController;

  @override
  void initState() {
    super.initState();
    _checkoutAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _checkoutAnimationController.dispose();
    super.dispose();
  }

  CartSummary get cartSummary {
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    return CartSummary(subtotal: subtotal, shippingCharges: shippingCharges);
  }

  void _showDeleteConfirmation(CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text('Remove "${item.name}" from your cart?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(item.id);
                Navigator.of(context).pop();
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed from cart'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _updateQuantity(String itemId, int newQuantity) {
    if (newQuantity < 1) return;

    setState(() {
      final index = cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        cartItems[index].quantity = newQuantity;
      }
    });
  }

  void _onCheckout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your cart is empty'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    _checkoutAnimationController.forward();

    // Simulate checkout process
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Order Placed!'),
              content: Text('Total: \$${cartSummary.total.toStringAsFixed(2)}'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _checkoutAnimationController.reverse();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = cartSummary;

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
          'Shopping Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body:
          cartItems.isEmpty
              ? const _EmptyCartWidget()
              : Column(
                children: [
                  // Cart Items List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CartItemCard(
                            item: item,
                            onDelete: () => _showDeleteConfirmation(item),
                            onQuantityChanged:
                                (newQuantity) =>
                                    _updateQuantity(item.id, newQuantity),
                          ),
                        );
                      },
                    ),
                  ),

                  // Cart Summary
                  _CartSummaryWidget(
                    summary: summary,
                    onCheckout: _onCheckout,
                    animationController: _checkoutAnimationController,
                  ),
                ],
              ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onDelete,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete();
        return false; // Don't auto-dismiss, let dialog handle it
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: item.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  item.imagePath,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${item.price.toStringAsFixed(2)} x ${item.multiplier}',
                    style: const TextStyle(
                      color: Color(0xFF7CB342),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            _QuantityControls(
              quantity: item.quantity,
              onQuantityChanged: onQuantityChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _QuantityControls({
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Button
        _QuantityButton(
          icon: Icons.add,
          onPressed: () => onQuantityChanged(quantity + 1),
        ),

        const SizedBox(height: 8),

        // Quantity Display
        Container(
          constraints: const BoxConstraints(minWidth: 24),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Remove Button
        _QuantityButton(
          icon: Icons.remove,
          onPressed:
              quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: onPressed != null ? const Color(0xFF7CB342) : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.grey[500],
          size: 18,
        ),
      ),
    );
  }
}

class _CartSummaryWidget extends StatelessWidget {
  final CartSummary summary;
  final VoidCallback onCheckout;
  final AnimationController animationController;

  const _CartSummaryWidget({
    required this.summary,
    required this.onCheckout,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          _SummaryRow(
            label: 'Subtotal',
            amount: summary.subtotal,
            isTotal: false,
          ),
          const SizedBox(height: 12),

          // Shipping charges
          _SummaryRow(
            label: 'Shipping charges',
            amount: summary.shippingCharges,
            isTotal: false,
          ),
          const SizedBox(height: 20),

          // Total
          _SummaryRow(label: 'Total', amount: summary.total, isTotal: true),
          const SizedBox(height: 24),

          // Checkout Button
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 - (animationController.value * 0.05),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CB342),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.isTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(isTotal ? 1 : 1)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _EmptyCartWidget extends StatelessWidget {
  const _EmptyCartWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
