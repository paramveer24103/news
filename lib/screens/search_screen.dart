import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.hasMoreData && 
          !newsProvider.isLoadingMore && 
          newsProvider.searchQuery.isNotEmpty) {
        newsProvider.searchArticles(newsProvider.searchQuery);
      }
    }
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      newsProvider.searchArticles(query.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : const Icon(Icons.search),
          ),
          onSubmitted: _performSearch,
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide clear button
          },
        ),
        elevation: 0,
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.searchQuery.isEmpty) {
            return _buildSearchSuggestions(newsProvider);
          }
          return _buildSearchResults(newsProvider);
        },
      ),
    );
  }

  Widget _buildSearchSuggestions(NewsProvider newsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search suggestions
        if (newsProvider.searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    newsProvider.clearSearchHistory();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: newsProvider.searchHistory.length,
              itemBuilder: (context, index) {
                final query = newsProvider.searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      newsProvider.removeFromSearchHistory(query);
                    },
                  ),
                  onTap: () {
                    _searchController.text = query;
                    _performSearch(query);
                  },
                );
              },
            ),
          ),
        ] else
          const Expanded(
            child: EmptyStateWidget(
              message: 'Start searching for news',
              subtitle: 'Enter keywords to find relevant articles',
              icon: Icons.search,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults(NewsProvider newsProvider) {
    switch (newsProvider.state) {
      case NewsState.initial:
      case NewsState.loading:
        if (newsProvider.searchResults.isEmpty) {
          return const SearchShimmer();
        }
        return _buildResultsList(newsProvider);
        
      case NewsState.loaded:
        if (newsProvider.searchResults.isEmpty) {
          return EmptyStateWidget(
            message: 'No results found',
            subtitle: 'Try different keywords or check your spelling',
            icon: Icons.search_off,
            action: ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
          );
        }
        return _buildResultsList(newsProvider);
        
      case NewsState.error:
        return CustomErrorWidget(
          message: newsProvider.errorMessage ?? 'Search failed',
          onRetry: () => _performSearch(newsProvider.searchQuery),
        );
    }
  }

  Widget _buildResultsList(NewsProvider newsProvider) {
    return Column(
      children: [
        // Results count
        if (newsProvider.searchResults.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Text(
              '${newsProvider.searchResults.length} results for "${newsProvider.searchQuery}"',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        
        // Results list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: newsProvider.searchResults.length + 
                       (newsProvider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < newsProvider.searchResults.length) {
                final article = newsProvider.searchResults[index];
                return NewsCard(article: article);
              } else {
                // Loading more indicator
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
