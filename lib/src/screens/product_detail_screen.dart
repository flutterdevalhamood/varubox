import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sample/src/providers/cart_controller.dart';
import 'package:sample/src/providers/favourites_controller.dart';
import 'package:sample/src/providers/product_detail_controller.dart';
// Add this import
import 'package:sample/src/util/app_navigation.dart';
import 'package:sample/src/util/app_routes.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late ProductDetailController _controller;
  late CartController _cartController;
  late FavoritesController _favoritesController;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ProductDetailController>(context, listen: false);
    _cartController = Provider.of<CartController>(context, listen: false);
    _favoritesController = Provider.of<FavoritesController>(
      context,
      listen: false,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Set product ID and fetch details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setProductId(widget.productId);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _toggleFavorite() {
    if (!_controller.hasProductData) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    final productData = _controller.productDetail!;
    final favoriteItem = FavoriteItem(
      id: productData['id'].toString(),
      name: _controller.productName,
      price: _controller.productPrice.replaceAll('\$', ''), // Remove $ symbol
      quantity: 1, // Default quantity when adding to favorites
      weight: '1.0', // You might want to get this from product data
      unit: 'kg', // You might want to get this from product data
      imagePath:
          _controller.productImage.isNotEmpty
              ? _controller.productImage
              : 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      backgroundColor: const Color(0xFFE8F5E8), // Default color
    );

    bool isCurrentlyFavorite = _favoritesController.isFavorite(favoriteItem.id);

    if (isCurrentlyFavorite) {
      _favoritesController.removeFromFavorites(favoriteItem.id);
      _showSnackBar(
        message: 'Removed from favorites',
        icon: Icons.favorite_border,
        color: Colors.grey[600]!,
      );
    } else {
      _favoritesController.addToFavorites(favoriteItem);
      _showSnackBar(
        message: 'Added to favorites',
        icon: Icons.favorite,
        color: Colors.red,
      );
    }
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCart() {
    if (!_controller.hasProductData) return;

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Add product to cart using the cart controller
    _cartController.addToCart(_controller.productDetail!, _quantity);

    // Show success message with cart info
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added $_quantity ${_controller.productName} to cart',
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                NavigationService().pushNavigation(Screenroutes.dashboard);
              },
              child: const Text(
                'VIEW CART',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );

    // Reset quantity to 1 after adding to cart
    setState(() {
      _quantity = 1;
    });
  }

  void _retryLoading() {
    _controller.clearErrors();
    _controller.getProductDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ProductDetailController>(
        builder: (context, controller, child) {
          if (controller.isLoading && !controller.hasProductData) {
            return _buildLoadingState();
          }

          if (controller.errorMessage != null && !controller.hasProductData) {
            return _buildErrorState(controller.errorMessage!);
          }

          if (!controller.hasProductData) {
            return _buildEmptyState();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(controller),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProductInfo(controller),
                      _buildLabelsSection(controller),
                      _buildDescriptionAndFAQSection(controller),
                      _buildQuantitySection(),
                      _buildAddToCartButton(controller),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading product details...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => NavigationService().popNavigation(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Error Loading Product',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _retryLoading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => NavigationService().popNavigation(),
        ),
      ),
      body: const Center(
        child: Text(
          'Product not found',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ProductDetailController controller) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => NavigationService().popNavigation(),
        ),
      ),
      actions: [
        // Cart icon with badge
        Consumer<CartController>(
          builder: (context, cartController, child) {
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.black87,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cartController.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartController.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        // Favorite icon with animation and proper state management
        Consumer<FavoritesController>(
          builder: (context, favoritesController, child) {
            bool isFavorite =
                controller.hasProductData &&
                favoritesController.isFavorite(
                  controller.productDetail!['id'].toString(),
                );

            return Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      color: isFavorite ? Colors.red : Colors.black87,
                      size: 20,
                    ),
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFFF0F8F0), Colors.white.withOpacity(0.9)],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'product_${controller.productDetail?['id']}',
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(
                          controller.productImage.isNotEmpty
                              ? controller.productImage
                              : 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
                        ),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint('Image loading error: $exception');
                        },
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Labels positioned on the image
              if (controller.productLabels.isNotEmpty)
                Positioned(
                  top: 80,
                  left: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        controller.productLabels
                            .map(
                              (label) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _parseColor(
                                    label['color'] ?? '#4CAF50',
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  label['name'] ?? '',
                                  style: TextStyle(
                                    color: _parseColor(
                                      label['text_color'] ?? '#FFFFFF',
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4CAF50); // Default green color
    }
  }

  Widget _buildProductInfo(ProductDetailController controller) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price section with discount
            Row(
              children: [
                Text(
                  controller.productPrice,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                if (controller.hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    controller.originalPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Product Name
            Text(
              controller.productName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Rating Section
            Row(
              children: [
                ...List.generate(
                  _getStarCount(controller.reviewsAverage),
                  (index) => const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                ),
                if (_hasHalfStar(controller.reviewsAverage))
                  const Icon(
                    Icons.star_half,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                ...List.generate(
                  5 -
                      _getStarCount(controller.reviewsAverage) -
                      (_hasHalfStar(controller.reviewsAverage) ? 1 : 0),
                  (index) => const Icon(
                    Icons.star_border,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.reviewsAverage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${controller.reviewsCount} reviews)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelsSection(ProductDetailController controller) {
    if (controller.productLabels.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Labels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  controller.productLabels
                      .map(
                        (label) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _parseColor(label['color'] ?? '#4CAF50'),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            label['name'] ?? '',
                            style: TextStyle(
                              color: _parseColor(
                                label['text_color'] ?? '#FFFFFF',
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  int _getStarCount(String rating) {
    double ratingValue = double.tryParse(rating) ?? 0.0;
    return ratingValue.floor();
  }

  bool _hasHalfStar(String rating) {
    double ratingValue = double.tryParse(rating) ?? 0.0;
    return (ratingValue - ratingValue.floor()) >= 0.5;
  }

  Widget _buildDescriptionAndFAQSection(ProductDetailController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(color: Colors.white),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Color(0xFF4CAF50),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF4CAF50),
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: [Tab(text: 'Description'), Tab(text: 'FAQ')],
            ),
            SizedBox(
              height: 300, // Fixed height for the tab view content
              child: TabBarView(
                children: [
                  _buildDescriptionTab(controller),
                  _buildFAQTab(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionTab(ProductDetailController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.productDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (controller.productContent.isNotEmpty) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'More Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 8),
              children: [
                Text(
                  controller.productContent,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAQTab(ProductDetailController controller) {
    if (controller.productFaqs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No FAQs available for this product.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.productFaqs.length,
      itemBuilder: (context, index) {
        final faq = controller.productFaqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              faq['question'] ?? '',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: const Border(),
            children: [
              Text(
                controller.stripHtmlTags(faq['answer'] ?? ''),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: _decrementQuantity,
                  isEnabled: _quantity > 1,
                ),
                Container(
                  width: 80,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: _incrementQuantity,
                  isEnabled: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isEnabled ? const Color(0xFF4CAF50) : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isEnabled ? onPressed : null,
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(ProductDetailController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer<CartController>(
          builder: (context, cartController, child) {
            bool isInCart =
                controller.hasProductData &&
                cartController.isInCart(controller.productDetail!['id']);

            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _addToCart,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart
                            ? Icons.shopping_bag
                            : Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isInCart ? 'Add More to Cart' : 'Add to Cart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isInCart) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${cartController.getItemQuantity(controller.productDetail!['id'])}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
