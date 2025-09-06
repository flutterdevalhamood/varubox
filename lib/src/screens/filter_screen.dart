// filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Price range controllers
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Star rating
  int _selectedStarRating = 4;

  // Filter options
  bool _hasDiscount = false;
  bool _freeShipping = true;
  bool _sameDayDelivery = true;

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceRangeSection(),
                  const SizedBox(height: 32),
                  _buildStarRatingSection(),
                  const SizedBox(height: 32),
                  _buildOthersSection(),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
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
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 24),
      ),
      title: const Text(
        'Apply Filters',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _resetFilters,
          icon: const Icon(Icons.refresh, color: Colors.black87, size: 24),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                controller: _minPriceController,
                hintText: 'Min.',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPriceInput(
                controller: _maxPriceController,
                hintText: 'Max.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStarRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Star Rating',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStarRating = index + 1;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.star,
                        color:
                            index < _selectedStarRating
                                ? const Color(0xFFFFC107)
                                : Colors.grey[300],
                        size: 28,
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Text(
                '$_selectedStarRating stars',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOthersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Others',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildFilterOption(
          icon: Icons.local_offer_outlined,
          title: 'Discount',
          value: _hasDiscount,
          onChanged: (value) {
            setState(() {
              _hasDiscount = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildFilterOption(
          icon: Icons.local_shipping_outlined,
          title: 'Free shipping',
          value: _freeShipping,
          onChanged: (value) {
            setState(() {
              _freeShipping = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildFilterOption(
          icon: Icons.access_time,
          title: 'Same day delivery',
          value: _sameDayDelivery,
          onChanged: (value) {
            setState(() {
              _sameDayDelivery = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? const Color(0xFF4CAF50) : Colors.transparent,
                border: Border.all(
                  color: value ? const Color(0xFF4CAF50) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child:
                  value
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Apply filter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
      _selectedStarRating = 4;
      _hasDiscount = false;
      _freeShipping = true;
      _sameDayDelivery = true;
    });
  }

  void _applyFilters() {
    // Create filter object to pass back
    final filters = FilterData(
      minPrice:
          _minPriceController.text.isNotEmpty
              ? double.tryParse(_minPriceController.text)
              : null,
      maxPrice:
          _maxPriceController.text.isNotEmpty
              ? double.tryParse(_maxPriceController.text)
              : null,
      starRating: _selectedStarRating,
      hasDiscount: _hasDiscount,
      freeShipping: _freeShipping,
      sameDayDelivery: _sameDayDelivery,
    );

    // Return filters to previous screen
    Navigator.pop(context, filters);
  }
}

// Data model for filters
class FilterData {
  final double? minPrice;
  final double? maxPrice;
  final int starRating;
  final bool hasDiscount;
  final bool freeShipping;
  final bool sameDayDelivery;

  FilterData({
    this.minPrice,
    this.maxPrice,
    required this.starRating,
    required this.hasDiscount,
    required this.freeShipping,
    required this.sameDayDelivery,
  });

  @override
  String toString() {
    return 'FilterData(minPrice: $minPrice, maxPrice: $maxPrice, starRating: $starRating, hasDiscount: $hasDiscount, freeShipping: $freeShipping, sameDayDelivery: $sameDayDelivery)';
  }
}
