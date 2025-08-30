import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/admin_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recent_activity_item.dart';
import '../widgets/stats_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ref.read(adminDashboardProvider.notifier).loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardState = ref.watch(adminDashboardProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: _buildAdminDrawer(),
      body: dashboardState.when(
        data: (dashboard) {
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome, ${dashboard.adminName}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Here\'s what\'s happening today',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatsCard(
                        title: 'Total Shows',
                        value: dashboard.totalShows.toString(),
                        icon: Icons.tv,
                        color: Colors.blue,
                        onTap: () => context.push('/admin/shows'),
                      ),
                      StatsCard(
                        title: 'Total Episodes',
                        value: dashboard.totalEpisodes.toString(),
                        icon: Icons.video_library,
                        color: Colors.purple,
                        onTap: () => context.push('/admin/episodes'),
                      ),
                      StatsCard(
                        title: 'Total Users',
                        value: dashboard.totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.green,
                        onTap: () => context.push('/admin/users'),
                      ),
                      StatsCard(
                        title: 'Subscribers',
                        value: dashboard.totalSubscribers.toString(),
                        icon: Icons.card_membership,
                        color: Colors.orange,
                        onTap: () => context.push('/admin/subscribers'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Upload Video',
                          icon: Icons.upload_file,
                          color: theme.colorScheme.primary,
                          onTap: () => context.push('/admin/upload'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'Add Show',
                          icon: Icons.add_to_queue,
                          color: Colors.green,
                          onTap: () => context.push('/admin/shows/add'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Manage Categories',
                          icon: Icons.category,
                          color: Colors.amber.shade700,
                          onTap: () => context.push('/admin/categories'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'View Analytics',
                          icon: Icons.analytics,
                          color: Colors.purple,
                          onTap: () => context.push('/admin/analytics'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Recent activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/admin/activity'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (dashboard.recentActivities.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No recent activity',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboard.recentActivities.length,
                      itemBuilder: (context, index) {
                        final activity = dashboard.recentActivities[index];
                        return RecentActivityItem(activity: activity);
                      },
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Popular content
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Content',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/admin/analytics/popular'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (dashboard.popularContent.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No popular content data available',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboard.popularContent.length,
                      itemBuilder: (context, index) {
                        final content = dashboard.popularContent[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: content.thumbnailUrl != null
                                ? Image.network(
                                    content.thumbnailUrl!,
                                    width: 60,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 40,
                                    color: theme.colorScheme.primary,
                                    child: const Icon(
                                      Icons.movie,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          title: Text(content.title),
                          subtitle: Text('${content.views} views'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            if (content.type == 'show') {
                              context.push('/admin/shows/${content.id}');
                            } else {
                              context.push('/admin/episodes/${content.id}');
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading dashboard data...'),
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
                'Failed to load dashboard data',
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
    );
  }

  Widget _buildAdminDrawer() {
    final theme = Theme.of(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 32,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your content',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => context.go('/admin'),
          ),
          _buildDrawerItem(
            icon: Icons.tv,
            title: 'Shows',
            onTap: () => context.push('/admin/shows'),
          ),
          _buildDrawerItem(
            icon: Icons.video_library,
            title: 'Episodes',
            onTap: () => context.push('/admin/episodes'),
          ),
          _buildDrawerItem(
            icon: Icons.category,
            title: 'Categories',
            onTap: () => context.push('/admin/categories'),
          ),
          _buildDrawerItem(
            icon: Icons.upload_file,
            title: 'Upload',
            onTap: () => context.push('/admin/upload'),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Users',
            onTap: () => context.push('/admin/users'),
          ),
          _buildDrawerItem(
            icon: Icons.card_membership,
            title: 'Subscriptions',
            onTap: () => context.push('/admin/subscribers'),
          ),
          _buildDrawerItem(
            icon: Icons.analytics,
            title: 'Analytics',
            onTap: () => context.push('/admin/analytics'),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => context.push('/admin/settings'),
          ),
          _buildDrawerItem(
            icon: Icons.exit_to_app,
            title: 'Exit Admin',
            onTap: () => context.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

