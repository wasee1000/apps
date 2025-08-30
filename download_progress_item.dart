import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/download_progress_model.dart';

class DownloadProgressItem extends StatelessWidget {
  final DownloadProgressModel downloadProgress;
  final VoidCallback onCancel;

  const DownloadProgressItem({
    Key? key,
    required this.downloadProgress,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                // Thumbnail
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: downloadProgress.thumbnailUrl != null
                          ? Image.network(
                              downloadProgress.thumbnailUrl!,
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
                          Icons.download,
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
                      if (downloadProgress.showTitle != null)
                        Text(
                          downloadProgress.showTitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      // Episode title
                      Text(
                        downloadProgress.episodeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Status
                      Row(
                        children: [
                          _buildStatusIndicator(downloadProgress.status),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusText(downloadProgress.status),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Cancel button
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  color: Colors.red,
                  onPressed: onCancel,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Progress bar
            LinearProgressIndicator(
              value: downloadProgress.progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(downloadProgress.status, theme),
              ),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
            
            const SizedBox(height: 8),
            
            // Progress details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Downloaded size / Total size
                Text(
                  '${downloadProgress.downloadedSize} / ${downloadProgress.totalSize}',
                  style: theme.textTheme.bodySmall,
                ),
                
                // Progress percentage
                Text(
                  downloadProgress.progressPercentage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Download speed and estimated time
                if (downloadProgress.status == 'downloading')
                  Text(
                    '${downloadProgress.downloadSpeed} • ${downloadProgress.estimatedTimeRemaining} left',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            
            // Error message
            if (downloadProgress.status == 'failed' && downloadProgress.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  downloadProgress.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    
    switch (status) {
      case 'downloading':
        color = Colors.blue;
        break;
      case 'paused':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'downloading':
        return 'Downloading';
      case 'paused':
        return 'Paused';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'downloading':
        return theme.colorScheme.primary;
      case 'paused':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

