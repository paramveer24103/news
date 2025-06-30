import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/bookmark_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // App Info Section
          _buildSectionHeader(context, 'App Information'),
          _buildAppInfoTile(context),
          
          const Divider(),
          
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSelector(context),
          
          const Divider(),
          
          // Data Section
          _buildSectionHeader(context, 'Data & Storage'),
          _buildBookmarksInfo(context),
          _buildClearDataTile(context),
          
          const Divider(),
          
          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutTile(context),
          _buildPrivacyTile(context),
          _buildTermsTile(context),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildAppInfoTile(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.article,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: const Text(AppConstants.appName),
      subtitle: Text('Version ${AppConstants.appVersion}'),
      trailing: const Icon(Icons.info_outline),
      onTap: () => _showAppInfo(context),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              subtitle: Text('Current: ${themeProvider.themeModeDisplayName}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeSelector(context, themeProvider),
            ),
            SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode 
                    ? Icons.dark_mode 
                    : Icons.light_mode,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeProvider.themeMode == ThemeMode.system
                    ? 'Following system setting'
                    : themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
              ),
              value: themeProvider.isDarkMode,
              onChanged: themeProvider.themeMode == ThemeMode.system
                  ? null
                  : (value) => themeProvider.toggleTheme(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookmarksInfo(BuildContext context) {
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        return ListTile(
          leading: const Icon(Icons.bookmark_outline),
          title: const Text('Bookmarks'),
          subtitle: Text('${bookmarkProvider.bookmarksCount} saved articles'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to bookmarks screen
            DefaultTabController.of(context)?.animateTo(2);
          },
        );
      },
    );
  }

  Widget _buildClearDataTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.clear_all, color: Colors.red),
      title: const Text('Clear All Data'),
      subtitle: const Text('Remove all bookmarks and search history'),
      onTap: () => _showClearDataDialog(context),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('About InfoPulse'),
      subtitle: const Text('Learn more about this app'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(context),
    );
  }

  Widget _buildPrivacyTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: const Text('Privacy Policy'),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _showComingSoon(context, 'Privacy Policy'),
    );
  }

  Widget _buildTermsTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Terms of Service'),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _showComingSoon(context, 'Terms of Service'),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            const Text('A modern news aggregator app built with Flutter.'),
            const SizedBox(height: 8),
            const Text('Stay informed with the latest news from around the world.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your bookmarks and search history. This action cannot be undone.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.article,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text('A modern news aggregator app that keeps you informed with the latest news from around the world.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Global news coverage'),
        const Text('• Category-based filtering'),
        const Text('• Bookmark articles'),
        const Text('• Search functionality'),
        const Text('• Dark/Light theme'),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature - Coming Soon!')),
    );
  }
}
