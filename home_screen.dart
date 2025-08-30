import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/show_model.dart';
import '../../../core/models/episode_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../providers/home_provider.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/category_list.dart';
import '../widgets/show_card.dart';
import '../widgets/episode_card.dart';
import '../widgets/section_header.dart';
import '../../search/screens/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    ref.read(featuredShowsProvider.notifier).loadFeaturedShows();
    ref.read(categoriesProvider.notifier).loadCategories();
    ref.read(trendingShowsProvider.notifier).loadTrendingShows();
    ref.read(recentlyAddedShowsProvider.notifier).loadRecentlyAddedShows();
    ref.read(continueWatchingProvider.notifier).loadContinueWatching();
    ref.read(recommendedShowsProvider.notifier).loadRecommendedShows();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadData();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get data from providers
    final featuredShows = ref.watch(featuredShowsProvider);
    final categories = ref.watch(categoriesProvider);
    final trendingShows = ref.watch(trendingShowsProvider);
    final recentlyAddedShows = ref.watch(recentlyAddedShowsProvider);
    final continueWatching = ref.watch(continueWatchingProvider);
    final recommendedShows = ref.watch(recommendedShowsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              title: Text(
                AppConstants.appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // Search button
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    context.push('/search');
                  },
                ),
                // Notifications button
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    context.push('/profile/notifications');
                  },
                ),
              ],
            ),
            
            // Content
            SliverToBoxAdapter(
              child: _isRefreshing
                  ? const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: LoadingIndicator(message: 'Refreshing content...'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Featured Carousel
                        featuredShows.when(
                          data: (shows) => shows.isNotEmpty
                              ? FeaturedCarousel(shows: shows)
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 250,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Categories
                        categories.when(
                          data: (cats) => cats.isNotEmpty
                              ? CategoryList(categories: cats)
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Continue Watching
                        continueWatching.when(
                          data: (episodes) => episodes.isNotEmpty
                              ? _buildContinueWatchingSection(episodes)
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Trending Shows
                        trendingShows.when(
                          data: (shows) => shows.isNotEmpty
                              ? _buildShowsSection(
                                  'Trending Now',
                                  shows,
                                  'See all trending shows',
                                  () => context.push('/category/trending'),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Recently Added
                        recentlyAddedShows.when(
                          data: (shows) => shows.isNotEmpty
                              ? _buildShowsSection(
                                  'Recently Added',
                                  shows,
                                  'See all new shows',
                                  () => context.push('/category/recent'),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Recommended For You
                        recommendedShows.when(
                          data: (shows) => shows.isNotEmpty
                              ? _buildShowsSection(
                                  'Recommended For You',
                                  shows,
                                  'See all recommendations',
                                  () => context.push('/category/recommended'),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => const SizedBox.shrink(),
                        ),
                        
                        // Bottom padding
                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/downloads');
              break;
            case 2:
              context.push('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_outlined),
            activeIcon: Icon(Icons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingSection(List<EpisodeModel> episodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Continue Watching',
          actionText: 'See all',
          onActionTap: () => context.push('/profile/history'),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: EpisodeCard(
                  episode: episode,
                  onTap: () {
                    context.push('/player/${episode.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShowsSection(
    String title,
    List<ShowModel> shows,
    String actionText,
    VoidCallback onActionTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          actionText: actionText,
          onActionTap: onActionTap,
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shows.length,
            itemBuilder: (context, index) {
              final show = shows[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ShowCard(
                  show: show,
                  onTap: () {
                    context.push('/show/${show.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

