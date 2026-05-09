import 'package:flutter/material.dart';
import 'app_data.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppData(),
      builder: (context, _) {
        final appData = AppData();
        final userName = appData.currentUser;
        final userRole = appData.currentUserRole;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              // Header without Back Arrow
              _buildHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Profile Card
                      _buildProfileCard(userName, userRole),
                      const SizedBox(height: 24),
                      
                      // Language Section
                      _buildSectionCard(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildToggleButton('English', appData.language == 'English', () {
                                appData.setLanguage('English');
                              }),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildToggleButton('العربية', appData.language == 'العربية', () {
                                appData.setLanguage('العربية');
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Display Section
                      _buildSectionCard(
                        icon: Icons.dark_mode_outlined,
                        title: 'Display',
                        child: _buildSwitchTile(
                          title: 'Dark Mode',
                          subtitle: 'Enable dark theme',
                          value: appData.isDarkMode,
                          onChanged: (val) => appData.toggleDarkMode(val),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Notifications Section
                      _buildSectionCard(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('View Notifications', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                              subtitle: const Text('Browse all previous alerts', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              title: 'Classification Alerts',
                              subtitle: 'New classifications',
                              value: appData.classificationAlerts,
                              onChanged: (val) => appData.setClassificationAlerts(val),
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              title: 'Report Notifications',
                              subtitle: 'Report generation',
                              value: appData.reportNotifications,
                              onChanged: (val) => appData.setReportNotifications(val),
                            ),
                            const Divider(height: 1),
                            _buildSwitchTile(
                              title: 'System Updates',
                              subtitle: 'System changes',
                              value: appData.systemUpdates,
                              onChanged: (val) => appData.setSystemUpdates(val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // System Information Section
                      _buildSectionCard(
                        icon: Icons.info_outline_rounded,
                        title: 'System Information',
                        child: Column(
                          children: [
                            _buildInfoRow('Version', '2.4.1'),
                            _buildInfoRow('Build', '20251204'),
                            _buildInfoRow('Database', 'Connected', valueColor: Colors.teal),
                            _buildInfoRow('Last Sync', 'Just now'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Logout Button
                      _buildLogoutButton(context),
                      const SizedBox(height: 24),

                      // Footer
                      const Text(
                        'Industrial Plant Classification System',
                        style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '© 2025 All Rights Reserved',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'System configuration',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: const Icon(Icons.person, size: 40, color: Color(0xFF06402B)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF06402B), size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06402B) : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF06402B).withAlpha(100),
            activeColor: const Color(0xFF06402B),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
