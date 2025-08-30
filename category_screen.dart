import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/show_model.dart';
import '../../../core/models/category_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/home_provider.dart';
import '../widgets/show_card.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryScreen({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  String _categoryName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryName();
  }

  Future<void> _loadCategoryName() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Handle special category IDs
      if (widget.categoryId == 'trending') {
        _categoryName = 'Trending Shows';
      } else if (widget.categoryId == 'recent') {
        _categoryName = 'Recently Added';
      } else if (widget.categoryId == 'recommended') {
        _categoryName = 'Recommended For You';
      } else {
        // Load category name from database
        final categories = await ref.read(categoriesProvider.future);
        final category = categories.firstWhere(
          (c) => c.id == widget.categoryId,
          orElse: () => CategoryModel(
            id: widget.categoryId,
            name: 'Category',
          ),
        );
        _categoryName = category.name;
      }
    } catch (e) {
      _categoryName = 'Category';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get shows for this category
    final shows = ref.watch(showsByCategoryProvider(widget.categoryId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _categoryName),
        centerTitle: true,
      ),
      body: shows.when(
        data: (showsList) => showsList.isEmpty
            ? _buildEmptyState(theme)
            : _buildShowsGrid(showsList),
        loading: () => const LoadingIndicator(message: 'Loading shows...'),
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
                onPressed: () {
                  ref.read(showsByCategoryProvider(widget.categoryId).notifier)
                      .loadShowsByCategory(widget.categoryId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No shows found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'There are no shows in this category yet',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildShowsGrid(List<ShowModel> shows) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(showsByCategoryProvider(widget.categoryId).notifier)
            .loadShowsByCategory(widget.categoryId);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return ShowCard(
            show: show,
            onTap: () => context.push('/show/${show.id}'),
            width: double.infinity,
            height: 200,
          );
        },
      ),
    );
  }
}

