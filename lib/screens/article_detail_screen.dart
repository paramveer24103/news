import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article.dart';
import '../providers/bookmark_provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openOriginalArticle(context),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Read Full Article'),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: article.urlToImage != null && article.urlToImage!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: article.urlToImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              )
            : Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(
                  child: Icon(Icons.article, size: 48),
                ),
              ),
      ),
      actions: [
        Consumer<BookmarkProvider>(
          builder: (context, bookmarkProvider, child) {
            final isBookmarked = bookmarkProvider.isBookmarked(article);
            
            return IconButton(
              onPressed: () => bookmarkProvider.toggleBookmark(article),
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            );
          },
        ),
        IconButton(
          onPressed: () => _shareArticle(context),
          icon: const Icon(Icons.share),
          tooltip: 'Share',
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Article metadata
          _buildMetadata(context),
          
          const SizedBox(height: 24),
          
          // Description
          if (article.description != null && article.description!.isNotEmpty) ...[
            Text(
              article.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Content
          if (article.content != null && article.content!.isNotEmpty) ...[
            Text(
              _cleanContent(article.content!),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Read more prompt
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Read the complete article',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the button below to view the full article on ${article.source}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.source,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                article.source,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              timeago.format(article.publishedAt),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              _formatDate(article.publishedAt),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        
        if (article.author != null && article.author!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'By ${article.author}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _cleanContent(String content) {
    // Remove common suffixes from news API content
    final cleanedContent = content
        .replaceAll(RegExp(r'\[\+\d+ chars\]$'), '')
        .replaceAll(RegExp(r'\[Removed\]'), '')
        .trim();
    
    return cleanedContent.isNotEmpty ? cleanedContent : 'Content not available.';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openOriginalArticle(BuildContext context) async {
    try {
      final Uri url = Uri.parse(article.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(context, 'Could not open article');
      }
    } catch (e) {
      _showSnackBar(context, 'Error opening article');
    }
  }

  void _shareArticle(BuildContext context) {
    // Note: For a complete implementation, you would use the share_plus package
    _showSnackBar(context, 'Share functionality would be implemented here');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
