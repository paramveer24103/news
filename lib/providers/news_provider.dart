import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../models/category.dart';
import '../services/news_service.dart';

enum NewsState { initial, loading, loaded, error }

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  
  // State management
  NewsState _state = NewsState.initial;
  String? _errorMessage;
  
  // Articles data
  List<Article> _topHeadlines = [];
  List<Article> _categoryArticles = [];
  List<Article> _searchResults = [];
  
  // Pagination
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  
  // Current category
  NewsCategory _selectedCategory = NewsCategory.categories.first;
  
  // Search
  String _searchQuery = '';
  List<String> _searchHistory = [];

  // Getters
  NewsState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Article> get topHeadlines => _topHeadlines;
  List<Article> get categoryArticles => _categoryArticles;
  List<Article> get searchResults => _searchResults;
  NewsCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get searchHistory => _searchHistory;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  // Set state helper
  void _setState(NewsState newState, {String? error}) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  // Fetch top headlines
  Future<void> fetchTopHeadlines({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _topHeadlines.clear();
    }

    if (_state == NewsState.loading && !refresh) return;

    _setState(NewsState.loading);

    try {
      final articles = await _newsService.getTopHeadlines(
        page: _currentPage,
        pageSize: 20,
      );

      if (refresh) {
        _topHeadlines = articles;
      } else {
        _topHeadlines.addAll(articles);
      }

      _hasMoreData = articles.length >= 20;
      _currentPage++;
      _setState(NewsState.loaded);
    } catch (e) {
      _setState(NewsState.error, error: e.toString());
    }
  }

  // Load more headlines
  Future<void> loadMoreHeadlines() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final articles = await _newsService.getTopHeadlines(
        page: _currentPage,
        pageSize: 20,
      );

      _topHeadlines.addAll(articles);
      _hasMoreData = articles.length >= 20;
      _currentPage++;
    } catch (e) {
      // Handle error silently for pagination
      debugPrint('Error loading more headlines: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Fetch articles by category
  Future<void> fetchArticlesByCategory(NewsCategory category, {bool refresh = false}) async {
    if (_selectedCategory != category || refresh) {
      _selectedCategory = category;
      _categoryArticles.clear();
      _currentPage = 1;
      _hasMoreData = true;
    }

    _setState(NewsState.loading);

    try {
      final articles = await _newsService.getArticlesByCategory(
        category: category.name,
        page: _currentPage,
        pageSize: 20,
      );

      if (refresh || _categoryArticles.isEmpty) {
        _categoryArticles = articles;
      } else {
        _categoryArticles.addAll(articles);
      }

      _hasMoreData = articles.length >= 20;
      _currentPage++;
      _setState(NewsState.loaded);
    } catch (e) {
      _setState(NewsState.error, error: e.toString());
    }
  }

  // Search articles
  Future<void> searchArticles(String query, {bool refresh = false}) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _searchQuery = '';
      notifyListeners();
      return;
    }

    if (_searchQuery != query || refresh) {
      _searchQuery = query;
      _searchResults.clear();
      _currentPage = 1;
      _hasMoreData = true;
      
      // Add to search history
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }
    }

    _setState(NewsState.loading);

    try {
      final articles = await _newsService.searchArticles(
        query: query,
        page: _currentPage,
        pageSize: 20,
      );

      if (refresh || _searchResults.isEmpty) {
        _searchResults = articles;
      } else {
        _searchResults.addAll(articles);
      }

      _hasMoreData = articles.length >= 20;
      _currentPage++;
      _setState(NewsState.loaded);
    } catch (e) {
      _setState(NewsState.error, error: e.toString());
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _setState(NewsState.initial);
  }

  // Clear search history
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  // Remove from search history
  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }

  // Retry last operation
  Future<void> retry() async {
    if (_searchQuery.isNotEmpty) {
      await searchArticles(_searchQuery, refresh: true);
    } else if (_selectedCategory != NewsCategory.categories.first) {
      await fetchArticlesByCategory(_selectedCategory, refresh: true);
    } else {
      await fetchTopHeadlines(refresh: true);
    }
  }
}
