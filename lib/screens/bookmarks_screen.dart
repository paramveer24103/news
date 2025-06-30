import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../models/article.dart';
import '../widgets/news_card.dart';
import '../widgets/error_widget.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Article> _filteredBookmarks = [];
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    
    setState(() {
      if (query.isEmpty) {
        _filteredBookmarks = bookmarkProvider.bookmarkedArticles;
        _isSearching = false;
      } else {
        _filteredBookmarks = bookmarkProvider.searchBookmarks(query);
        _isSearching = true;
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSortBottomSheet(),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Bookmarks'),
        content: const Text(
          'Are you sure you want to remove all bookmarked articles? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<BookmarkProvider>(context, listen: false)
                  .clearAllBookmarks();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              if (bookmarkProvider.bookmarkedArticles.isNotEmpty) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'sort':
                        _showSortOptions();
                        break;
                      case 'clear':
                        _showClearConfirmation();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'sort',
                      child: ListTile(
                        leading: Icon(Icons.sort),
                        title: Text('Sort'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'clear',
                      child: ListTile(
                        leading: Icon(Icons.clear_all),
                        title: Text('Clear All'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (!bookmarkProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookmarkProvider.bookmarkedArticles.isEmpty) {
            return const EmptyStateWidget(
              message: 'No bookmarks yet',
              subtitle: 'Start bookmarking articles to see them here',
              icon: Icons.bookmark_outline,
            );
          }

          return Column(
            children: [
              // Search bar
              _buildSearchBar(),
              
              // Bookmarks count
              _buildBookmarksCount(bookmarkProvider),
              
              // Bookmarks list
              Expanded(
                child: _buildBookmarksList(bookmarkProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search bookmarks...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBookmarksCount(BookmarkProvider bookmarkProvider) {
    final count = _isSearching 
        ? _filteredBookmarks.length 
        : bookmarkProvider.bookmarksCount;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        _isSearching 
            ? '$count results found'
            : '$count bookmarked ${count == 1 ? 'article' : 'articles'}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBookmarksList(BookmarkProvider bookmarkProvider) {
    final articles = _isSearching 
        ? _filteredBookmarks 
        : bookmarkProvider.bookmarkedArticles;

    if (articles.isEmpty && _isSearching) {
      return const EmptyStateWidget(
        message: 'No bookmarks found',
        subtitle: 'Try different search terms',
        icon: Icons.search_off,
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return NewsCard(
          article: article,
          showBookmarkButton: true,
        );
      },
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort Bookmarks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Newest First'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<BookmarkProvider>(context, listen: false)
                  .sortBookmarks(byDate: true, ascending: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Oldest First'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<BookmarkProvider>(context, listen: false)
                  .sortBookmarks(byDate: true, ascending: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Title A-Z'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<BookmarkProvider>(context, listen: false)
                  .sortBookmarks(byDate: false, ascending: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Title Z-A'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<BookmarkProvider>(context, listen: false)
                  .sortBookmarks(byDate: false, ascending: false);
            },
          ),
        ],
      ),
    );
  }
}
