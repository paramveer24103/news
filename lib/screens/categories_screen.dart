import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../models/category.dart';
import '../widgets/news_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch initial data for the first category
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.categoryArticles.isEmpty) {
        newsProvider.fetchArticlesByCategory(NewsCategory.categories.first);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.hasMoreData && !newsProvider.isLoadingMore) {
        newsProvider.fetchArticlesByCategory(
          newsProvider.selectedCategory,
          refresh: false,
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.fetchArticlesByCategory(
      newsProvider.selectedCategory,
      refresh: true,
    );
  }

  void _onCategorySelected(NewsCategory category) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.fetchArticlesByCategory(category);
    
    // Reset scroll position
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category tabs
          _buildCategoryTabs(),
          
          // News list
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                return _buildBody(newsProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: NewsCategory.categories.length,
            itemBuilder: (context, index) {
              final category = NewsCategory.categories[index];
              final isSelected = newsProvider.selectedCategory.id == category.id;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected 
                            ? Colors.white 
                            : category.color,
                      ),
                      const SizedBox(width: 6),
                      Text(category.displayName),
                    ],
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onCategorySelected(category);
                    }
                  },
                  selectedColor: category.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(NewsProvider newsProvider) {
    switch (newsProvider.state) {
      case NewsState.initial:
      case NewsState.loading:
        if (newsProvider.categoryArticles.isEmpty) {
          return const LoadingShimmer();
        }
        return _buildNewsList(newsProvider);
        
      case NewsState.loaded:
        if (newsProvider.categoryArticles.isEmpty) {
          return EmptyStateWidget(
            message: 'No articles found',
            subtitle: 'Try selecting a different category or refresh',
            icon: Icons.article_outlined,
            action: ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          );
        }
        return _buildNewsList(newsProvider);
        
      case NewsState.error:
        if (newsProvider.categoryArticles.isEmpty) {
          return CustomErrorWidget(
            message: newsProvider.errorMessage ?? 'Failed to load articles',
            onRetry: _onRefresh,
          );
        }
        return _buildNewsList(newsProvider);
    }
  }

  Widget _buildNewsList(NewsProvider newsProvider) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: newsProvider.categoryArticles.length + 
                   (newsProvider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < newsProvider.categoryArticles.length) {
            final article = newsProvider.categoryArticles[index];
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
    );
  }
}
