import 'package:flutter/material.dart';

import '../models/storage_info_model.dart';

class StorageInfoCard extends StatelessWidget {
  final StorageInfoModel storageInfo;

  const StorageInfoCard({
    Key? key,
    required this.storageInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.storage),
                const SizedBox(width: 8),
                Text(
                  'Storage',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${storageInfo.downloadCount} ${storageInfo.downloadCount == 1 ? 'download' : 'downloads'}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Storage bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 16,
                child: Stack(
                  children: [
                    // Total space
                    Container(
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    
                    // Used space (excluding downloads)
                    FractionallySizedBox(
                      widthFactor: (storageInfo.usedSpace - storageInfo.downloadedVideosSpace) / 
                          storageInfo.totalSpace,
                      child: Container(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    
                    // Downloaded videos space
                    FractionallySizedBox(
                      widthFactor: storageInfo.downloadedVideosSpacePercentage,
                      child: Container(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Legend
            Row(
              children: [
                // Downloaded videos
                _buildLegendItem(
                  context,
                  color: theme.colorScheme.primary,
                  label: 'Downloads',
                  value: storageInfo.downloadedVideosSpaceFormatted,
                ),
                
                const SizedBox(width: 16),
                
                // Other used space
                _buildLegendItem(
                  context,
                  color: Colors.grey.withOpacity(0.5),
                  label: 'Other',
                  value: _formatBytes(storageInfo.usedSpace - storageInfo.downloadedVideosSpace),
                ),
                
                const SizedBox(width: 16),
                
                // Free space
                _buildLegendItem(
                  context,
                  color: Colors.grey.withOpacity(0.2),
                  label: 'Free',
                  value: storageInfo.availableSpaceFormatted,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Total space
            Text(
              'Total: ${storageInfo.totalSpaceFormatted}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
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

