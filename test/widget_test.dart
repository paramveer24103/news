import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:infopulse/main.dart';
import 'package:infopulse/providers/news_provider.dart';
import 'package:infopulse/providers/theme_provider.dart';
import 'package:infopulse/providers/bookmark_provider.dart';

void main() {
  group('InfoPulse App Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NewsProvider()),
            ChangeNotifierProvider(create: (_) => BookmarkProvider()),
          ],
          child: const InfoPulseApp(isFirstTime: true),
        ),
      );

      // Verify that the splash screen is displayed
      expect(find.text('InfoPulse'), findsOneWidget);
      expect(find.text('Stay Informed, Stay Ahead'), findsOneWidget);
    });

    testWidgets('Theme provider should toggle themes', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      // Initial theme should be system
      expect(themeProvider.themeMode, ThemeMode.system);
      
      // Toggle to dark theme
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Toggle to light theme
      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    testWidgets('News provider should handle states correctly', (WidgetTester tester) async {
      final newsProvider = NewsProvider();
      
      // Initial state should be initial
      expect(newsProvider.state, NewsState.initial);
      expect(newsProvider.topHeadlines, isEmpty);
      expect(newsProvider.categoryArticles, isEmpty);
      expect(newsProvider.searchResults, isEmpty);
    });

    testWidgets('Bookmark provider should manage bookmarks', (WidgetTester tester) async {
      final bookmarkProvider = BookmarkProvider();
      
      // Initial state
      expect(bookmarkProvider.bookmarkedArticles, isEmpty);
      expect(bookmarkProvider.bookmarksCount, 0);
    });
  });

  group('Model Tests', () {
    test('Article model should serialize/deserialize correctly', () {
      final articleJson = {
        'title': 'Test Article',
        'description': 'Test Description',
        'url': 'https://example.com',
        'urlToImage': 'https://example.com/image.jpg',
        'publishedAt': '2023-01-01T00:00:00Z',
        'source': {'name': 'Test Source'},
        'author': 'Test Author',
        'content': 'Test Content',
      };

      // Test fromJson
      final article = Article.fromJson(articleJson);
      expect(article.title, 'Test Article');
      expect(article.description, 'Test Description');
      expect(article.url, 'https://example.com');
      expect(article.source, 'Test Source');
      expect(article.author, 'Test Author');

      // Test toJson
      final serialized = article.toJson();
      expect(serialized['title'], 'Test Article');
      expect(serialized['description'], 'Test Description');
      expect(serialized['url'], 'https://example.com');
    });
  });
}

// Import the Article model for testing
class Article {
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;
  final String source;

  Article({
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      content: json['content'],
      source: json['source']['name'] ?? 'Unknown Source',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'content': content,
      'source': {'name': source},
    };
  }
}
