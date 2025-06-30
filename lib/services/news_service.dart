import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../utils/constants.dart';

class NewsService {
  static const String _baseUrl = AppConstants.newsApiBaseUrl;
  static const String _apiKey = AppConstants.newsApiKey;

  // Fetch top headlines
  Future<List<Article>> getTopHeadlines({
    String? country = AppConstants.defaultCountry,
    String? category,
    int pageSize = AppConstants.defaultPageSize,
    int page = 1,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      };

      if (country != null) queryParams['country'] = country;
      if (category != null) queryParams['category'] = category;

      final uri = Uri.parse('$_baseUrl${AppConstants.topHeadlinesEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => Article.fromJson(json))
              .where((article) => article.title != '[Removed]')
              .toList();
        } else {
          throw Exception(data['message'] ?? AppConstants.apiError);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your NewsAPI key.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(AppConstants.noInternetError);
    } on HttpException {
      throw Exception(AppConstants.apiError);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Search articles
  Future<List<Article>> searchArticles({
    required String query,
    String? language = AppConstants.defaultLanguage,
    String? sortBy = 'publishedAt',
    int pageSize = AppConstants.defaultPageSize,
    int page = 1,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'q': query,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
        'sortBy': sortBy ?? 'publishedAt',
      };

      if (language != null) queryParams['language'] = language;

      final uri = Uri.parse('$_baseUrl${AppConstants.everythingEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'ok') {
          final List<dynamic> articlesJson = data['articles'] ?? [];
          return articlesJson
              .map((json) => Article.fromJson(json))
              .where((article) => article.title != '[Removed]')
              .toList();
        } else {
          throw Exception(data['message'] ?? AppConstants.apiError);
        }
      } else {
        throw Exception('Failed to search articles: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(AppConstants.noInternetError);
    } on HttpException {
      throw Exception(AppConstants.apiError);
    } catch (e) {
      throw Exception('Search error: ${e.toString()}');
    }
  }

  // Get articles by category
  Future<List<Article>> getArticlesByCategory({
    required String category,
    String? country = AppConstants.defaultCountry,
    int pageSize = AppConstants.defaultPageSize,
    int page = 1,
  }) async {
    return getTopHeadlines(
      country: country,
      category: category,
      pageSize: pageSize,
      page: page,
    );
  }

  // Check API key validity
  Future<bool> isApiKeyValid() async {
    try {
      await getTopHeadlines(pageSize: 1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
