// categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> categories = [
    {
      'image': 'assets/images/vegetable_cat.jpg',
      'color': const Color(0xFFE8F5E8),
      'label': 'Vegetables',
    },
    {
      'image': 'assets/images/fruits_cat.jpg',
      'color': const Color(0xFFFFEBEE),
      'label': 'Fruits',
    },
    {
      'image': 'assets/images/beverage_cat.jpg',
      'color': const Color(0xFFFFF3E0),
      'label': 'Beverages',
    },
    {
      'image': 'assets/images/grocery_cat.jpg',
      'color': const Color(0xFFF3E5F5),
      'label': 'Grocery',
    },
    {
      'image': 'assets/images/edibleoil_cat.jpg',
      'color': const Color(0xFFE3F2FD),
      'label': 'Edible oil',
    },
    {
      'image': 'assets/images/household_cat.jpg',
      'color': const Color(0xFFFCE4EC),
      'label': 'Household',
    },
    {
      'image': 'assets/images/babycare_cat.jpg',
      'color': const Color(0xFFE1F5FE),
      'label': 'Babycare',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    HapticFeedback.lightImpact();

    // Show category selection feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${category['label']} category'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );

    // Here you can navigate to category products screen
    // Navigator.pushNamed(context, '/category-products', arguments: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(position: _slideAnimation, child: _buildBody()),
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
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        'Categories',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: Colors.black87, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Handle filter action
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final double staggerDelay = (index * 0.1).clamp(0.0, 0.4);
                    final double startInterval = 0.2 + staggerDelay;
                    final double endInterval = (0.8 + staggerDelay).clamp(
                      0.0,
                      1.0,
                    );
                    // Stagger animation for each item
                    final itemAnimation = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          startInterval,
                          endInterval,
                          curve: Curves.elasticOut,
                        ),
                      ),
                    );

                    return Transform.scale(
                      scale: itemAnimation.value,
                      child: _buildCategoryCard(categories[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Container
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                category['image'],
                width: 30,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a colored container with text if image fails to load
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: category['color'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        category['label'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Category Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                category['label'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
