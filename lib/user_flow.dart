import 'dart:io';
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'scan_screen.dart';
import 'records_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';

/// UserMainScreen: The main entry point for the User role, adapted from MainScreen.
class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => UserMainScreenState();
}

class UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void setIndex(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          UserHomeScreen(),
          ScanScreen(),
          RecordsScreen(isUserRole: true), // Serving as Recent Activity/History
          FavoritesScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 15),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', isDark),
              _buildNavItem(1, Icons.camera_rounded, 'Scan', isDark),
              _buildNavItem(2, Icons.history_rounded, 'History', isDark),
              _buildNavItem(3, Icons.favorite_rounded, 'Favorites', isDark),
              _buildNavItem(4, Icons.settings_rounded, 'Settings', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06402B) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// UserHomeScreen: Adapted from DashboardScreen but with user-only actions.
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  Route _createSimpleRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 1) return 'just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes} mins ago';
    if (duration.inHours < 24) return '${duration.inHours} hours ago';
    return '${duration.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF042016), const Color(0xFF06402B)]
                  : [const Color(0xFF06402B), const Color(0xFF0A5A3D)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(44),
                bottomRight: Radius.circular(44),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildUserBadge(),
                  const SizedBox(height: 40),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildActionGrid(context, isDark),
                        const SizedBox(height: 24),
                        _buildRecentActivitySection(context, isDark),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, _createSimpleRoute(const ProfileScreen())),
          child: Row(
            children: [
              ListenableBuilder(
                listenable: AppData(),
                builder: (context, _) {
                  final path = AppData().profileImageFor(AppData().currentUser);
                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white24,
                    backgroundImage: path != null ? FileImage(File(path)) : null,
                    child: path == null
                        ? const Icon(Icons.person, color: Colors.white, size: 35)
                        : null,
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    AppData().currentUser,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, _createSimpleRoute(const NotificationScreen())),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildUserBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.white),
          const SizedBox(width: 8),
          const Text('Standard User', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCardWrapper('New Scan', Icons.camera_alt_outlined, const Color(0xFF06402B), Colors.white, true, () => Navigator.push(context, _createSimpleRoute(const ScanScreen()))),
        _buildActionCardWrapper('My Favorites', Icons.favorite_border_rounded, isDark ? const Color(0xFF1E1E1E) : Colors.white, isDark ? Colors.white : Colors.black87, false, () => Navigator.push(context, _createSimpleRoute(const FavoritesScreen()))),
        _buildActionCardWrapper('History', Icons.history_rounded, isDark ? const Color(0xFF1E1E1E) : Colors.white, isDark ? Colors.white : Colors.black87, false, () => Navigator.push(context, _createSimpleRoute(const RecordsScreen(isUserRole: true)))),
        _buildActionCardWrapper('Browse Plants', Icons.search_rounded, isDark ? const Color(0xFF1E1E1E) : Colors.white, isDark ? Colors.white : Colors.black87, false, () {
          // Placeholder for Plant Library
        }),
      ],
    );
  }

  Widget _buildActionCardWrapper(String title, IconData icon, Color bgColor, Color textColor, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(isSelected ? 20 : 8), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 36),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, bool isDark) {
    return ListenableBuilder(
      listenable: AppData(),
      builder: (context, _) {
        final activities = AppData().activities;
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 5), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, size: 22, color: isDark ? Colors.greenAccent : const Color(0xFF06402B)),
                  const SizedBox(width: 10),
                  Text(
                    'My Recent Activity',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: theme.textTheme.bodyLarge?.color),
                  ),
                ],
              ),
              Divider(height: 32, thickness: 0.5, color: isDark ? Colors.white10 : Colors.grey.shade200),
              if (activities.isEmpty)
                Center(child: Text('No activity yet', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)))
              else
                ...activities.take(5).map((activity) => _buildActivityItem(activity.text, _getTimeAgo(activity.timestamp), isDark, theme)),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActivityItem(String text, String time, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.greenAccent : const Color(0xFF06402B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// FavoritesScreen: Simplified list view using existing card design.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No favorites yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

/// Simple helper to route based on role
Widget getRootScreenByRole(String role) {
  if (role.toLowerCase() == 'admin') {
    // This would be your existing MainScreen/DashboardScreen for admins
    return const Scaffold(body: Center(child: Text('Redirecting to Admin...')));
  } else {
    return const UserMainScreen();
  }
}
