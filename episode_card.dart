import 'package:flutter/material.dart';

import '../../../core/models/episode_model.dart';
import '../../../core/theme/app_theme.dart';

class EpisodeCard extends StatelessWidget {
  final EpisodeModel episode;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double borderRadius;
  final bool showProgress;

  const EpisodeCard({
    Key? key,
    required this.episode,
    required this.onTap,
    this.width = 240,
    this.height = 135,
    this.borderRadius = 12,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate progress percentage (mock data for now)
    // In a real app, this would come from the episode's watch progress
    final progressPercentage = 0.65; // 65% watched
    
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with progress
            Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: episode.thumbnailUrl != null
                      ? Image.network(
                          episode.thumbnailUrl!,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(borderRadius),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.movie_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                
                // Premium Badge
                if (episode.isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
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
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Duration
                if (episode.videoDuration != null)
                  Positioned(
                    bottom: showProgress ? 16 : 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
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
                
                // Play Button Overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                // Progress Bar
                if (showProgress)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(borderRadius),
                        bottomRight: Radius.circular(borderRadius),
                      ),
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        backgroundColor: Colors.grey.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Episode Info
            const SizedBox(height: 8),
            Row(
              children: [
                // Show thumbnail if available
                if (episode.show?.thumbnailUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      episode.show!.thumbnailUrl!,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Show title
                Expanded(
                  child: Text(
                    episode.show?.title ?? 'Unknown Show',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              episode.episodeTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

