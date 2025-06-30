class AppConstants {
  // API Configuration
  static const String newsApiKey = 'c5d243bcb042421e877457617b4a988e'; // Replace with your actual API key
  static const String newsApiBaseUrl = 'https://newsapi.org/v2';
  
  // Alternative API (GNews.io) - Uncomment to use
  // static const String gnewsApiKey = 'YOUR_GNEWS_API_KEY_HERE';
  // static const String gnewsApiBaseUrl = 'https://gnews.io/api/v4';
  
  // App Configuration
  static const String appName = 'InfoPulse';
  static const String appVersion = '1.0.0';
  
  // SharedPreferences Keys
  static const String keyIsFirstTime = 'isFirstTime';
  static const String keyThemeMode = 'themeMode';
  static const String keyBookmarks = 'bookmarks';
  static const String keySearchHistory = 'searchHistory';
  
  // API Endpoints
  static const String topHeadlinesEndpoint = '/top-headlines';
  static const String everythingEndpoint = '/everything';
  static const String sourcesEndpoint = '/sources';
  
  // Default Values
  static const int defaultPageSize = 20;
  static const String defaultCountry = 'us';
  static const String defaultLanguage = 'en';
  
  // Error Messages
  static const String noInternetError = 'No internet connection. Please check your network.';
  static const String apiError = 'Failed to fetch news. Please try again later.';
  static const String generalError = 'Something went wrong. Please try again.';
  static const String noArticlesFound = 'No articles found.';
  
  // Image Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  
  // Animation Assets
  static const String loadingAnimationPath = 'assets/animations/loading.json';
  static const String errorAnimationPath = 'assets/animations/error.json';
  static const String emptyAnimationPath = 'assets/animations/empty.json';
}
