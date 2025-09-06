// search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Search history data - In real app, this would come from local storage/database
  List<String> _searchHistory = [
    'Fresh Grocery',
    'Bananas',
    'cheetos',
    'vegetables',
    'Fruits',
    'discounted items',
    'Fresh vegetables',
  ];

  // Discover more suggestions
  List<String> _discoverMore = [
    'Fresh Grocery',
    'Bananas',
    'cheetos',
    'vegetables',
    'Fruits',
    'discounted items',
    'Fresh vegetables',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSearchHistorySection(),
                  const SizedBox(height: 32),
                  _buildDiscoverMoreSection(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
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
      title: _buildSearchField(),
      titleSpacing: 0,
      actions: [
        IconButton(
          onPressed: _openFilterScreen,
          icon: const Icon(Icons.tune, color: Colors.grey, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search keywords..',
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: _performSearch,
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildSearchHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Search History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: _clearSearchHistory,
              child: const Text(
                'clear',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchTags(_searchHistory),
      ],
    );
  }

  Widget _buildDiscoverMoreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Discover more',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: _clearDiscoverMore,
              child: const Text(
                'clear',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSearchTags(_discoverMore),
      ],
    );
  }

  Widget _buildSearchTags(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildSearchTag(tag)).toList(),
    );
  }

  Widget _buildSearchTag(String text) {
    return GestureDetector(
      onTap: () => _selectSearchTag(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
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
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.camera_alt_outlined,
              label: 'Image Search',
              onTap: _openImageSearch,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.mic_outlined,
              label: 'Voice Search',
              onTap: _openVoiceSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    // Add to search history if not already present
    if (!_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        // Keep only last 10 searches
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
    }

    // Navigate back with search results or to results screen
    Navigator.pop(context, query);
  }

  void _onSearchChanged(String query) {
    // Implement real-time search suggestions if needed
    // This could filter the discover more section based on query
  }

  void _selectSearchTag(String tag) {
    _searchController.text = tag;
    _performSearch(tag);
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });

    _showSnackBar('Search history cleared');
  }

  void _clearDiscoverMore() {
    setState(() {
      _discoverMore.clear();
    });

    _showSnackBar('Discover more cleared');
  }

  void _openFilterScreen() {
    // Navigate to filter screen
    // You can implement this based on your filter screen
    print('Opening filter screen');
  }

  void _openImageSearch() {
    // Implement image search functionality
    // Could open camera or gallery
    _showSnackBar('Image search feature');
  }

  void _openVoiceSearch() {
    // Implement voice search functionality
    // Could integrate with speech recognition
    _showSnackBar('Voice search feature');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Extension to integrate with your dashboard
extension DashboardIntegration on SearchScreen {
  static Future<String?> openSearch(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }
}
