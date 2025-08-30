import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/exceptions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  
  // User preferences
  String _selectedLanguage = 'english';
  final List<String> _selectedGenres = [];
  final List<String> _selectedCategories = [];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Update user preferences
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateProfile(
        preferredLanguage: _selectedLanguage,
      );
      
      // In a real app, we would also save the genre and category preferences
      
      if (mounted) {
        // Navigate to home screen
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to save preferences. Please try again.',
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
  
  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }
  
  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Page content
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildWelcomePage(theme),
                _buildLanguagePage(theme),
                _buildPreferencesPage(theme),
              ],
            ),
            
            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    _currentPage > 0
                        ? TextButton(
                            onPressed: _previousPage,
                            child: Text(
                              'Back',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : const SizedBox(width: 80),
                    
                    // Page indicators
                    Row(
                      children: List.generate(
                        3,
                        (index) => Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    
                    // Next/Finish button
                    SizedBox(
                      width: 80,
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: _nextPage,
                              child: Text(
                                _currentPage < 2 ? 'Next' : 'Finish',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Welcome text
          Text(
            'Welcome to ${AppConstants.appName}!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Your gateway to the best Indian TV serials, daily soaps, and reality shows.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Features list
          ..._buildFeatureItem(
            theme,
            Icons.movie_outlined,
            'Unlimited access to premium content',
          ),
          ..._buildFeatureItem(
            theme,
            Icons.download_outlined,
            'Download episodes for offline viewing',
          ),
          ..._buildFeatureItem(
            theme,
            Icons.notifications_outlined,
            'Get notified about new episodes',
          ),
          ..._buildFeatureItem(
            theme,
            Icons.favorite_outline,
            'Create your personalized watchlist',
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildFeatureItem(ThemeData theme, IconData icon, String text) {
    return [
      const SizedBox(height: 16),
      Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ];
  }
  
  Widget _buildLanguagePage(ThemeData theme) {
    final languages = AppConstants.supportedLanguages;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Choose Your Language',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Select your preferred language for content and app interface.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          
          // Language options
          Expanded(
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                final isSelected = _selectedLanguage == language['code'];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  elevation: isSelected ? 2 : 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language['code']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Radio button
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          
                          // Language name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language['name']!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                language['nativeName']!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreferencesPage(ThemeData theme) {
    final genres = [
      'Drama',
      'Comedy',
      'Romance',
      'Action',
      'Thriller',
      'Horror',
      'Mythology',
      'Historical',
      'Family',
      'Crime',
    ];
    
    final categories = AppConstants.contentCategories.map((c) => c['name']!).toList();
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          
          // Title
          Text(
            'Your Preferences',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Select your favorite genres and categories to personalize your experience.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Genres section
          Text(
            'Favorite Genres',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Genre chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              
              return FilterChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (_) => _toggleGenre(genre),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Categories section
          Text(
            'Content Categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Category chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => _toggleCategory(category),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Note
          Text(
            'You can always change these preferences later in your profile settings.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

