import 'package:flutter/material.dart';

import '../../../core/models/show_model.dart';
import '../../../core/theme/app_theme.dart';

class ShowCard extends StatelessWidget {
  final ShowModel show;
  final VoidCallback onTap;
  final bool showTitle;
  final bool showRating;
  final double width;
  final double height;
  final double borderRadius;

  const ShowCard({
    Key? key,
    required this.show,
    required this.onTap,
    this.showTitle = true,
    this.showRating = true,
    this.width = 140,
    this.height = 200,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: show.thumbnailUrl != null
                      ? Image.network(
                          show.thumbnailUrl!,
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
                if (show.isPremium)
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

                // Rating
                if (showRating && show.rating > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            show.ratingString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
              ],
            ),

            // Title and Info
            if (showTitle) ...[
              const SizedBox(height: 8),
              Text(
                show.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              if (show.genre.isNotEmpty)
                Text(
                  show.genre.first,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

