import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);
      if (newsProvider.topHeadlines.isEmpty) {
        newsProvider.fetchTopHeadlines();
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
        newsProvider.loadMoreHeadlines();
      }
    }
  }

  Future<void> _onRefresh() async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    await newsProvider.fetchTopHeadlines(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoPulse'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          return _buildBody(newsProvider);
        },
      ),
    );
  }

  Widget _buildBody(NewsProvider newsProvider) {
    switch (newsProvider.state) {
      case NewsState.initial:
      case NewsState.loading:
        if (newsProvider.topHeadlines.isEmpty) {
          return const LoadingShimmer();
        }
        return _buildNewsList(newsProvider);
        
      case NewsState.loaded:
        if (newsProvider.topHeadlines.isEmpty) {
          return EmptyStateWidget(
            message: 'No news available',
            subtitle: 'Pull to refresh or try again later',
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
        if (newsProvider.topHeadlines.isEmpty) {
          return CustomErrorWidget(
            message: newsProvider.errorMessage ?? 'Failed to load news',
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
        itemCount: newsProvider.topHeadlines.length + 
                   (newsProvider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < newsProvider.topHeadlines.length) {
            final article = newsProvider.topHeadlines[index];
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
