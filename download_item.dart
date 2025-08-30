import 'package:flutter/material.dart';

import '../../../core/models/episode_model.dart';
import '../../../core/theme/app_theme.dart';

class DownloadItem extends StatelessWidget {
  final EpisodeModel episode;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const DownloadItem({
    Key? key,
    required this.episode,
    required this.isEditing,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onPlay,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isEditing ? onToggleSelection : onPlay,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Selection checkbox (visible in edit mode)
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelection(),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: episode.thumbnailUrl != null
                        ? Image.network(
                            episode.thumbnailUrl!,
                            width: 100,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 56,
                                color: theme.colorScheme.primary.withOpacity(0.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 24,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 100,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.movie_outlined,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  
                  // Download icon
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download_done,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Episode info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show title
                    if (episode.show != null)
                      Text(
                        episode.show!.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    // Episode title
                    Text(
                      episode.episodeTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // File size
                    if (episode.fileSize != null)
                      Text(
                        _formatFileSize(episode.fileSize!),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              
              // Action buttons (visible when not in edit mode)
              if (!isEditing) ...[
                // Play button
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  color: theme.colorScheme.primary,
                  onPressed: onPlay,
                ),
                
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

