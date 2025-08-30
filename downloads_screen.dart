import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/episode_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../providers/downloads_provider.dart';
import '../widgets/download_item.dart';
import '../widgets/download_progress_item.dart';
import '../widgets/storage_info_card.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  bool _isEditing = false;
  final Set<String> _selectedEpisodes = {};

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    ref.read(downloadsProvider.notifier).loadDownloads();
    ref.read(downloadProgressProvider.notifier).loadDownloadProgress();
    ref.read(storageInfoProvider.notifier).loadStorageInfo();
  }

  void _toggleSelection(String episodeId) {
    setState(() {
      if (_selectedEpisodes.contains(episodeId)) {
        _selectedEpisodes.remove(episodeId);
      } else {
        _selectedEpisodes.add(episodeId);
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _selectedEpisodes.clear();
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedEpisodes.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Downloads'),
        content: Text(
          'Are you sure you want to delete ${_selectedEpisodes.length} downloaded ${_selectedEpisodes.length == 1 ? 'episode' : 'episodes'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(downloadsProvider.notifier).deleteDownloads(_selectedEpisodes.toList());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloads deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          
          setState(() {
            _selectedEpisodes.clear();
            _isEditing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(
              title: 'Error',
              message: 'Failed to delete downloads: ${e.toString()}',
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get data from providers
    final downloads = ref.watch(downloadsProvider);
    final downloadProgress = ref.watch(downloadProgressProvider);
    final storageInfo = ref.watch(storageInfoProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          // Edit button
          if (downloads.hasValue && downloads.value!.isNotEmpty)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDownloads,
        child: CustomScrollView(
          slivers: [
            // Storage info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: storageInfo.when(
                  data: (info) => StorageInfoCard(storageInfo: info),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
            
            // Downloads in progress
            downloadProgress.when(
              data: (progressList) => progressList.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Downloading',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: progressList.length,
                            itemBuilder: (context, index) {
                              final progress = progressList[index];
                              return DownloadProgressItem(
                                downloadProgress: progress,
                                onCancel: () {
                                  ref.read(downloadProgressProvider.notifier)
                                      .cancelDownload(progress.episodeId);
                                },
                              );
                            },
                          ),
                          const Divider(height: 32),
                        ],
                      ),
                    ),
              loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (error, stackTrace) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            
            // Downloaded episodes
            downloads.when(
              data: (episodes) => episodes.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(theme),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text(
                            'Downloaded Episodes',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...episodes.map((episode) => _buildDownloadItem(episode)).toList(),
                      ]),
                    ),
              loading: () => const SliverFillRemaining(
                child: LoadingIndicator(message: 'Loading downloads...'),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: Center(
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
                        'Failed to load downloads',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDownloads,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Delete button when in edit mode
      floatingActionButton: _isEditing && _selectedEpisodes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete),
              label: Text('Delete (${_selectedEpisodes.length})'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Downloads',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Download episodes to watch offline',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Browse Content'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(EpisodeModel episode) {
    final isSelected = _selectedEpisodes.contains(episode.id);
    
    return DownloadItem(
      episode: episode,
      isEditing: _isEditing,
      isSelected: isSelected,
      onToggleSelection: () => _toggleSelection(episode.id),
      onPlay: () => context.push('/player/${episode.id}'),
      onDelete: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Download'),
            content: Text(
              'Are you sure you want to delete "${episode.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await ref.read(downloadsProvider.notifier).deleteDownloads([episode.id]);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download deleted successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  title: 'Error',
                  message: 'Failed to delete download: ${e.toString()}',
                ),
              );
            }
          }
        }
      },
    );
  }
}

