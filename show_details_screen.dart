import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/show_model.dart';
import '../../../core/models/episode_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../providers/show_details_provider.dart';
import '../widgets/episode_card.dart';
import '../widgets/section_header.dart';

class ShowDetailsScreen extends ConsumerStatefulWidget {
  final String showId;

  const ShowDetailsScreen({
    Key? key,
    required this.showId,
  }) : super(key: key);

  @override
  ConsumerState<ShowDetailsScreen> createState() => _ShowDetailsScreenState();
}

class _ShowDetailsScreenState extends ConsumerState<ShowDetailsScreen> {
  bool _isInWatchlist = false;
  bool _isInFavorites = false;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ref.read(showDetailsProvider(widget.showId).notifier).loadShowDetails();
    ref.read(showEpisodesProvider(widget.showId).notifier).loadEpisodes();
    ref.read(similarShowsProvider(widget.showId).notifier).loadSimilarShows();
    
    // Check if show is in watchlist and favorites
    final isInWatchlist = await ref.read(isShowInWatchlistProvider(widget.showId).future);
    final isInFavorites = await ref.read(isShowInFavoritesProvider(widget.showId).future);
    
    if (mounted) {
      setState(() {
        _isInWatchlist = isInWatchlist;
        _isInFavorites = isInFavorites;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    try {
      final result = await ref.read(showDetailsProvider(widget.showId).notifier).toggleWatchlist();
      
      if (mounted) {
        setState(() {
          _isInWatchlist = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Added to watchlist'
                  : 'Removed from watchlist',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update watchlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final result = await ref.read(showDetailsProvider(widget.showId).notifier).toggleFavorite();
      
      if (mounted) {
        setState(() {
          _isInFavorites = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectSeason(int season) {
    setState(() {
      _selectedSeason = season;
    });
    
    ref.read(showEpisodesProvider(widget.showId).notifier).filterBySeason(season);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Get data from providers
    final showDetails = ref.watch(showDetailsProvider(widget.showId));
    final episodes = ref.watch(showEpisodesProvider(widget.showId));
    final similarShows = ref.watch(similarShowsProvider(widget.showId));
    
    return Scaffold(
      body: showDetails.when(
        data: (show) => _buildContent(context, show, episodes, similarShows),
        loading: () => const LoadingIndicator(message: 'Loading show details...'),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load show details',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ShowModel show,
    AsyncValue<List<EpisodeModel>> episodes,
    AsyncValue<List<ShowModel>> similarShows,
  ) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Get unique seasons from episodes
    final List<int> seasons = [];
    if (episodes.hasValue && episodes.value!.isNotEmpty) {
      for (final episode in episodes.value!) {
        if (!seasons.contains(episode.seasonNumber)) {
          seasons.add(episode.seasonNumber);
        }
      }
      seasons.sort();
    }
    
    return CustomScrollView(
      slivers: [
        // App Bar with Banner Image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Banner Image
                show.bannerUrl != null
                    ? Image.network(
                        show.bannerUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.movie_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            // Watchlist Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isInWatchlist
                      ? Icons.playlist_add_check
                      : Icons.playlist_add,
                ),
              ),
              onPressed: _toggleWatchlist,
            ),
            
            // Favorite Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isInFavorites
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _isInFavorites ? Colors.red : null,
                ),
              ),
              onPressed: _toggleFavorite,
            ),
            
            // Share Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share),
              ),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
        ),
        
        // Show Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    if (show.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          show.thumbnailUrl!,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 16),
                    
                    // Title and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            show.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Info Row
                          Row(
                            children: [
                              // Rating
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    show.ratingString,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              
                              // Year
                              if (show.releaseYear != null)
                                Text(
                                  show.yearString,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              const SizedBox(width: 16),
                              
                              // Episodes
                              Text(
                                '${show.totalEpisodes} Episodes',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Genre
                          if (show.genre.isNotEmpty)
                            Text(
                              'Genre: ${show.genreString}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          const SizedBox(height: 8),
                          
                          // Language
                          Text(
                            'Language: ${show.language.toUpperCase()}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          // Watch Button
                          if (episodes.hasValue && episodes.value!.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () {
                                context.push('/player/${episodes.value!.first.id}');
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Watch Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description
                if (show.description != null && show.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    show.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Cast
                if (show.cast.isNotEmpty) ...[
                  Text(
                    'Cast',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    show.castString,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Director
                if (show.director != null && show.director!.isNotEmpty) ...[
                  Text(
                    'Director',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    show.director!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Trailer
                if (show.trailerUrl != null && show.trailerUrl!.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // Play trailer
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('Watch Trailer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Season Selector
                if (seasons.isNotEmpty) ...[
                  Text(
                    'Episodes',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: seasons.map((season) {
                        final isSelected = season == _selectedSeason;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('Season $season'),
                            selected: isSelected,
                            onSelected: (_) => _selectSeason(season),
                            backgroundColor: theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
        
        // Episodes List
        episodes.when(
          data: (episodesList) => episodesList.isEmpty
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No episodes available'),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final episode = episodesList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _buildEpisodeListItem(episode),
                      );
                    },
                    childCount: episodesList.length,
                  ),
                ),
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, stackTrace) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Failed to load episodes'),
              ),
            ),
          ),
        ),
        
        // Similar Shows
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Similar Shows',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: similarShows.when(
                  data: (shows) => shows.isEmpty
                      ? const Center(
                          child: Text('No similar shows available'),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: shows.length,
                          itemBuilder: (context, index) {
                            final similarShow = shows[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  context.push('/show/${similarShow.id}');
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: similarShow.thumbnailUrl != null
                                          ? Image.network(
                                              similarShow.thumbnailUrl!,
                                              width: 120,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 120,
                                              height: 180,
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.2),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported_outlined,
                                                  size: 40,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Title
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        similarShow.title,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => const Center(
                    child: Text('Failed to load similar shows'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeListItem(EpisodeModel episode) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          context.push('/player/${episode.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: episode.thumbnailUrl != null
                        ? Image.network(
                            episode.thumbnailUrl!,
                            width: 120,
                            height: 68,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 120,
                            height: 68,
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                Icons.movie_outlined,
                                size: 24,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                  ),
                  
                  // Play Button
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  // Duration
                  if (episode.videoDuration != null)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          episode.durationString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Episode Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Episode Number and Title
                    Text(
                      episode.episodeTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    if (episode.description != null)
                      Text(
                        episode.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    
                    // Air Date
                    if (episode.airDate != null)
                      Text(
                        'Air Date: ${episode.airDateString}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Premium Badge
              if (episode.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

