import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import '../utils/constants.dart';

class BookmarkProvider with ChangeNotifier {
  List<Article> _bookmarkedArticles = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  bool get isInitialized => _isInitialized;

  BookmarkProvider() {
    _loadBookmarks();
  }

  // Load bookmarks from SharedPreferences
  Future<void> _loadBookmarks() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final String? bookmarksJson = _prefs.getString(AppConstants.keyBookmarks);
      
      if (bookmarksJson != null) {
        final List<dynamic> bookmarksList = json.decode(bookmarksJson);
        _bookmarkedArticles = bookmarksList
            .map((json) => Article.fromJson(json))
            .toList();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save bookmarks to SharedPreferences
  Future<void> _saveBookmarks() async {
    try {
      final List<Map<String, dynamic>> bookmarksJson = 
          _bookmarkedArticles.map((article) => article.toJson()).toList();
      await _prefs.setString(AppConstants.keyBookmarks, json.encode(bookmarksJson));
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }

  // Check if article is bookmarked
  bool isBookmarked(Article article) {
    return _bookmarkedArticles.any((bookmarked) => bookmarked.url == article.url);
  }

  // Add article to bookmarks
  Future<void> addBookmark(Article article) async {
    if (!isBookmarked(article)) {
      _bookmarkedArticles.insert(0, article); // Add to beginning
      await _saveBookmarks();
      notifyListeners();
    }
  }

  // Remove article from bookmarks
  Future<void> removeBookmark(Article article) async {
    _bookmarkedArticles.removeWhere((bookmarked) => bookmarked.url == article.url);
    await _saveBookmarks();
    notifyListeners();
  }

  // Toggle bookmark status
  Future<void> toggleBookmark(Article article) async {
    if (isBookmarked(article)) {
      await removeBookmark(article);
    } else {
      await addBookmark(article);
    }
  }

  // Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    _bookmarkedArticles.clear();
    await _saveBookmarks();
    notifyListeners();
  }

  // Get bookmarks count
  int get bookmarksCount => _bookmarkedArticles.length;

  // Search bookmarks
  List<Article> searchBookmarks(String query) {
    if (query.trim().isEmpty) return _bookmarkedArticles;
    
    final String lowerQuery = query.toLowerCase();
    return _bookmarkedArticles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
             (article.description?.toLowerCase().contains(lowerQuery) ?? false) ||
             article.source.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get bookmarks by date range
  List<Article> getBookmarksByDateRange(DateTime startDate, DateTime endDate) {
    return _bookmarkedArticles.where((article) {
      return article.publishedAt.isAfter(startDate) && 
             article.publishedAt.isBefore(endDate);
    }).toList();
  }

  // Sort bookmarks
  void sortBookmarks({bool byDate = true, bool ascending = false}) {
    if (byDate) {
      _bookmarkedArticles.sort((a, b) {
        return ascending 
            ? a.publishedAt.compareTo(b.publishedAt)
            : b.publishedAt.compareTo(a.publishedAt);
      });
    } else {
      _bookmarkedArticles.sort((a, b) {
        return ascending 
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title);
      });
    }
    notifyListeners();
  }
}
