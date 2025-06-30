# InfoPulse - Flutter News Aggregator App

A modern, cross-platform mobile news aggregator app built with Flutter that fetches real-time news and current affairs from global news APIs.

## Features

### Core Features
- ✅ **Clean Splash Screen** with animated app logo and name
- ✅ **Onboarding Screens** (3 slides) describing the app's purpose
- ✅ **Bottom Navigation Bar** with tabs: Home, Categories, Bookmarks, Settings
- ✅ **Home Screen** displaying latest global headlines with image, title, source, and time
- ✅ **Category Screen** filtering news by topics (Business, Sports, Tech, Health, etc.)
- ✅ **Search Functionality** to find news articles by keywords
- ✅ **News Detail Page** with full article content, author, published date, and external link
- ✅ **Bookmark Feature** to save and manage favorite articles locally
- ✅ **Settings Screen** with light/dark mode toggle
- ✅ **Responsive Layout** for both Android and iOS

### Technical Features
- ✅ **Flutter 3+** and Dart
- ✅ **Provider** for state management
- ✅ **HTTP package** for API calls
- ✅ **SharedPreferences** for local storage
- ✅ **Clean project structure** (models/, services/, screens/, widgets/)
- ✅ **Material Design** principles
- ✅ **Pull to refresh** functionality
- ✅ **Shimmer loading effects**
- ✅ **Comprehensive error handling**
- ✅ **Offline state management**

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── article.dart         # Article model with JSON serialization
│   └── category.dart        # News category model
├── providers/               # State management
│   ├── news_provider.dart   # News data and API state
│   ├── theme_provider.dart  # Theme management
│   └── bookmark_provider.dart # Bookmark management
├── services/                # API and external services
│   └── news_service.dart    # NewsAPI integration
├── screens/                 # UI screens
│   ├── splash_screen.dart   # Animated splash screen
│   ├── onboarding_screen.dart # 3-slide onboarding
│   ├── main_screen.dart     # Bottom navigation container
│   ├── home_screen.dart     # Latest headlines
│   ├── categories_screen.dart # Category-based news
│   ├── search_screen.dart   # Search functionality
│   ├── article_detail_screen.dart # Article details
│   ├── bookmarks_screen.dart # Saved articles
│   └── settings_screen.dart # App settings
├── widgets/                 # Reusable UI components
│   ├── news_card.dart       # Article card widget
│   ├── loading_shimmer.dart # Loading animations
│   └── error_widget.dart    # Error handling widgets
└── utils/                   # Utilities and constants
    ├── constants.dart       # App constants and API keys
    └── app_theme.dart       # Theme definitions
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- NewsAPI.org account (for API key)

### Installation

1. **Clone or download the project**
   ```bash
   # If using git
   git clone <repository-url>
   cd infopulse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Get your NewsAPI key**
   - Visit [NewsAPI.org](https://newsapi.org/)
   - Sign up for a free account
   - Get your API key from the dashboard

4. **Configure API key**
   - Open `lib/utils/constants.dart`
   - Replace `YOUR_NEWS_API_KEY_HERE` with your actual API key:
   ```dart
   static const String newsApiKey = 'your_actual_api_key_here';
   ```

5. **Run the app**
   ```bash
   # For development
   flutter run
   
   # For release build
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## API Configuration

The app uses NewsAPI.org by default. You can also configure it to use GNews.io:

1. **For NewsAPI.org** (default):
   - Get API key from [newsapi.org](https://newsapi.org/)
   - Update `newsApiKey` in `constants.dart`

2. **For GNews.io** (alternative):
   - Uncomment GNews configuration in `constants.dart`
   - Update the service implementation in `news_service.dart`

## Key Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.1              # State management
  http: ^1.1.0                  # HTTP requests
  shared_preferences: ^2.2.2    # Local storage
  cached_network_image: ^3.3.0  # Image caching
  url_launcher: ^6.2.1          # External links
  shimmer: ^3.0.0               # Loading animations
  timeago: ^3.6.0               # Time formatting
  html: ^0.15.4                 # HTML parsing
```

## Features Walkthrough

### 1. Splash Screen
- Animated logo and app name
- Smooth transitions
- Automatic navigation to onboarding/main screen

### 2. Onboarding
- 3 informative slides
- Skip functionality
- Smooth page transitions

### 3. Home Screen
- Latest global headlines
- Pull-to-refresh
- Infinite scrolling
- Loading shimmer effects

### 4. Categories
- Filter by Business, Sports, Technology, Health, etc.
- Category chips with icons
- Separate loading states per category

### 5. Search
- Real-time search
- Search history
- Debounced API calls
- Clear search functionality

### 6. Article Details
- Full article content
- Author and publication info
- External link to original article
- Bookmark toggle
- Share functionality

### 7. Bookmarks
- Local storage using SharedPreferences
- Search within bookmarks
- Sort options (date, title)
- Clear all functionality

### 8. Settings
- Light/Dark/System theme toggle
- App information
- Data management
- About section

## Error Handling

The app includes comprehensive error handling for:
- Network connectivity issues
- API rate limits
- Invalid API responses
- Image loading failures
- Local storage errors

## Performance Optimizations

- **Image Caching**: Using `cached_network_image` for efficient image loading
- **Lazy Loading**: ListView.builder for efficient scrolling
- **State Persistence**: Maintaining scroll positions and data across navigation
- **Debounced Search**: Preventing excessive API calls during search
- **Shimmer Loading**: Providing visual feedback during data loading

## Customization

### Themes
- Modify `lib/utils/app_theme.dart` to customize colors and typography
- Both light and dark themes are fully customizable

### API Integration
- Extend `lib/services/news_service.dart` to add more news sources
- Modify `lib/models/article.dart` for different data structures

### UI Components
- All widgets in `lib/widgets/` are reusable and customizable
- Easy to modify card layouts, loading states, and error displays

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **API Key Error**
   - Ensure you've replaced the placeholder API key in `constants.dart`
   - Verify your NewsAPI account is active

2. **Network Issues**
   - Check internet connectivity
   - Verify API endpoints are accessible

3. **Build Issues**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For issues and questions:
- Check the troubleshooting section
- Review the code comments
- Create an issue in the repository

---

**InfoPulse** - Stay Informed, Stay Ahead 📰
