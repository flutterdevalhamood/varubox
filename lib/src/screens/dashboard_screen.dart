// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sample/src/providers/dashboard_controller.dart';
import 'package:sample/src/screens/cart_screen.dart';
import 'package:sample/src/screens/favourites_screen.dart';
import 'package:sample/src/screens/filter_screen.dart';
import 'package:sample/src/util/app_navigation.dart';
import 'package:sample/src/util/app_routes.dart';
import 'package:sample/src/util/snack.dart';

// Import your separate account screen file
import 'account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardContent(),
    const AccountScreen(),
    const FavoritesScreen(),
    const CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey[400],
          elevation: 0,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: '',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 6,
        child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late DashboardController _dashboardController;

  @override
  void initState() {
    super.initState();
    _dashboardController = Provider.of<DashboardController>(
      context,
      listen: false,
    );
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _dashboardController.getProductData();
  }

  Future<void> _refreshProducts() async {
    await _dashboardController.refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        color: const Color(0xFF4CAF50),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildPromotionBanner(),
              _buildCategoriesSection(),
              _buildFeaturedProductsSection(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: const Text(
        'Home',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () async {
          final String? searchQuery = await NavigationService().pushNavigation(
            Screenroutes.searchScreen,
          );

          if (searchQuery != null && searchQuery.isNotEmpty) {
            // Handle search with products from controller
            final searchResults = _dashboardController.searchProducts(
              searchQuery,
            );
            // You can navigate to search results screen or show results
          }
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Search keywords..',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final FilterData? filters = await NavigationService()
                      .pushNavigation(Screenroutes.filterScreen);

                  if (filters != null) {
                    _handleFiltersApplied(filters);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.tune, color: Colors.grey, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFiltersApplied(FilterData filters) {
    // Implement your filter logic here using the controller
    print('Applied filters: $filters');

    // You can filter products based on price range, etc.
    // final filteredProducts = _dashboardController.filterProductsByPrice(
    //   filters.minPrice ?? 0.0,
    //   filters.maxPrice ?? double.infinity
    // );

    showSuccessSnack('Filter Applied Successfully');
  }

  Widget _buildPromotionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '20% off on your',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'first purchase',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {
        'icon': Icons.eco,
        'color': const Color(0xFFE8F5E8),
        'iconColor': const Color(0xFF4CAF50),
        'label': 'Vegetables',
      },
      {
        'icon': Icons.apple,
        'color': const Color(0xFFFFEBEE),
        'iconColor': const Color(0xFFE91E63),
        'label': 'Fruits',
      },
      {
        'icon': Icons.local_drink,
        'color': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFFF9800),
        'label': 'Beverages',
      },
      {
        'icon': Icons.shopping_basket,
        'color': const Color(0xFFF3E5F5),
        'iconColor': const Color(0xFF9C27B0),
        'label': 'Grocery',
      },
      {
        'icon': Icons.opacity,
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF2196F3),
        'label': 'Edible oil',
      },
      {
        'icon': Icons.home,
        'color': const Color(0xFFFCE4EC),
        'iconColor': const Color(0xFFE91E63),
        'label': 'Household',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  NavigationService().pushNavigation(
                    Screenroutes.categoryScreen,
                  );
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(
                category['icon'] as IconData,
                category['color'] as Color,
                category['iconColor'] as Color,
                category['label'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Loading state
              if (controller.isProductsLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),

              // Error state
              if (controller.productsErrorMessage != null &&
                  !controller.isProductsLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Text(
                          controller.productsErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Products grid
              if (!controller.isProductsLoading &&
                  controller.productsErrorMessage == null)
                controller.featuredProducts.isEmpty
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No products available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                    : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: controller.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.featuredProducts[index];
                        return _buildProductCard(product, context);
                      },
                    ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Screenroutes.navigateToProductDetail(context, product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with badges and labels
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          product.primaryImage.isNotEmpty
                              ? product.primaryImage
                              : 'https://via.placeholder.com/300x200?text=No+Image',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Product Labels
                  if (product.publishedLabels.isNotEmpty)
                    Positioned(
                      top: product.hasDiscount ? 32 : 8,
                      left: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            product.publishedLabels
                                .take(
                                  2,
                                ) // Show maximum 2 labels to avoid overcrowding
                                .map(
                                  (label) => Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: label.backgroundColor,
                                      borderRadius: BorderRadius.circular(4),
                                      border:
                                          label.backgroundColor == Colors.white
                                              ? Border.all(
                                                color: Colors.grey.withOpacity(
                                                  0.3,
                                                ),
                                                width: 1,
                                              )
                                              : null,
                                    ),
                                    child: Text(
                                      label.name,
                                      style: TextStyle(
                                        color: label.foregroundColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),

                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price section with strike-through for original price
                    Row(
                      children: [
                        Text(
                          '\$${product.salePrice}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.price}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Reviews section
                    if (product.reviewsCount != '0')
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${product.reviewsAvg} (${product.reviewsCount})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No reviews yet',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    const Spacer(),
                    // Add to cart section
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xFF4CAF50),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Add to cart',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
