import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/category_model.dart';
import '../../../core/theme/app_theme.dart';

class CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryList({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CategoryCard(category: category),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => context.push('/category/${category.id}'),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getGradientForCategory(category.name),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            if (category.iconUrl != null)
              Image.network(
                category.iconUrl!,
                width: 40,
                height: 40,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.category,
                    size: 40,
                    color: Colors.white,
                  );
                },
              )
            else
              _getCategoryIcon(category.name),
            const SizedBox(height: 8),
            
            // Name
            Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  LinearGradient _getGradientForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'drama':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade700, Colors.purple.shade900],
        );
      case 'comedy':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.orange.shade700],
        );
      case 'romance':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink.shade300, Colors.pink.shade700],
        );
      case 'mythology':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade600, Colors.amber.shade900],
        );
      case 'reality':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade800],
        );
      case 'crime':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade700, Colors.red.shade900],
        );
      case 'thriller':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal.shade700, Colors.teal.shade900],
        );
      case 'family':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.green.shade700],
        );
      case 'historical':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.brown.shade600, Colors.brown.shade800],
        );
      default:
        return AppTheme.primaryGradient;
    }
  }
  
  Widget _getCategoryIcon(String categoryName) {
    IconData iconData;
    
    switch (categoryName.toLowerCase()) {
      case 'drama':
        iconData = Icons.theater_comedy;
        break;
      case 'comedy':
        iconData = Icons.sentiment_very_satisfied;
        break;
      case 'romance':
        iconData = Icons.favorite;
        break;
      case 'mythology':
        iconData = Icons.auto_stories;
        break;
      case 'reality':
        iconData = Icons.live_tv;
        break;
      case 'crime':
        iconData = Icons.local_police;
        break;
      case 'thriller':
        iconData = Icons.psychology;
        break;
      case 'family':
        iconData = Icons.family_restroom;
        break;
      case 'historical':
        iconData = Icons.history_edu;
        break;
      default:
        iconData = Icons.category;
    }
    
    return Icon(
      iconData,
      size: 40,
      color: Colors.white,
    );
  }
}

