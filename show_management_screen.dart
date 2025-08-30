import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/admin_provider.dart';

class ShowManagementScreen extends ConsumerStatefulWidget {
  const ShowManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ShowManagementScreen> createState() => _ShowManagementScreenState();
}

class _ShowManagementScreenState extends ConsumerState<ShowManagementScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCategoryId;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(adminShowsProvider.notifier).loadShows();
      await ref.read(adminCategoriesProvider.notifier).loadCategories();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to load data: ${e.toString()}',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteShow(String showId, String showTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Show'),
        content: Text(
          'Are you sure you want to delete "$showTitle"? '
          'This will also delete all episodes associated with this show.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(adminShowsProvider.notifier).deleteShow(showId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Show deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to delete show: ${e.toString()}',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _filterShows(List<dynamic> shows) {
    if (_searchQuery.isEmpty && _selectedCategoryId == null) {
      return shows;
    }
    
    return shows.where((show) {
      bool matchesSearch = true;
      bool matchesCategory = true;
      
      if (_searchQuery.isNotEmpty) {
        matchesSearch = show.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      if (_selectedCategoryId != null) {
        matchesCategory = show.categoryId == _selectedCategoryId;
      }
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showsState = ref.watch(adminShowsProvider);
    final categoriesState = ref.watch(adminCategoriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shows'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/shows/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Show'),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading shows...')
          : Column(
              children: [
                // Search and filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search shows...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Category filter
                      categoriesState.when(
                        data: (categories) {
                          return DropdownButtonFormField<String?>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              hintText: 'Filter by category',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<String?>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stackTrace) => Center(
                          child: Text(
                            'Failed to load categories',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Shows list
                Expanded(
                  child: showsState.when(
                    data: (shows) {
                      final filteredShows = _filterShows(shows);
                      
                      if (filteredShows.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.tv_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No shows found',
                                style: theme.textTheme.titleLarge,
                              ),
                              if (_searchQuery.isNotEmpty || _selectedCategoryId != null) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _selectedCategoryId = null;
                                    });
                                  },
                                  child: const Text('Clear filters'),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredShows.length,
                        itemBuilder: (context, index) {
                          final show = filteredShows[index];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => context.push('/admin/shows/${show.id}'),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Show thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: show.thumbnailUrl != null
                                          ? Image.network(
                                              show.thumbnailUrl!,
                                              width: 100,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 100,
                                                  height: 150,
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
                                              height: 150,
                                              decoration: BoxDecoration(
                                                gradient: AppTheme.primaryGradient,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.tv,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Show details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          Text(
                                            show.title,
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          
                                          // Category
                                          categoriesState.when(
                                            data: (categories) {
                                              final category = categories.firstWhere(
                                                (c) => c.id == show.categoryId,
                                                orElse: () => null,
                                              );
                                              
                                              return Text(
                                                category != null
                                                    ? 'Category: ${category.name}'
                                                    : 'No category',
                                                style: theme.textTheme.bodyMedium,
                                              );
                                            },
                                            loading: () => const Text('Loading category...'),
                                            error: (error, stackTrace) => const Text(
                                              'Failed to load category',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          
                                          // Episodes count
                                          Text(
                                            '${show.episodeCount} episodes',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          
                                          // Status
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: show.isActive
                                                      ? Colors.green
                                                      : Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                show.isActive ? 'Active' : 'Inactive',
                                                style: theme.textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Action buttons
                                          Row(
                                            children: [
                                              // View episodes
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  context.push('/admin/shows/${show.id}/episodes');
                                                },
                                                icon: const Icon(Icons.video_library),
                                                label: const Text('Episodes'),
                                              ),
                                              const SizedBox(width: 8),
                                              
                                              // Edit show
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  context.push('/admin/shows/${show.id}/edit');
                                                },
                                                icon: const Icon(Icons.edit),
                                                label: const Text('Edit'),
                                              ),
                                              const SizedBox(width: 8),
                                              
                                              // Delete show
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  _deleteShow(show.id, show.title);
                                                },
                                                icon: const Icon(Icons.delete),
                                                label: const Text('Delete'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
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
                            'Failed to load shows',
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
                ),
              ],
            ),
    );
  }
}

