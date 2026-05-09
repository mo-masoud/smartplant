import 'package:flutter/material.dart';
import 'app_data.dart';
import 'main_screen.dart';
import 'user_flow.dart';

/// Global session to store the current user role during development.
class AppSession {
  static String role = 'user';
}

/// A temporary Role Selection screen for development/testing.
/// Use this to toggle between Admin and User flows.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final TextEditingController _usernameController = TextEditingController();

  void _handleLogin(String role, {String? customUsername}) {
    AppSession.role = role;
    
    if (customUsername != null && customUsername.isNotEmpty) {
      final emp = AppData().findEmployeeByUsername(customUsername);
      if (emp != null) {
        // Use the actual role from the "database"
        final dbRole = emp.role.toLowerCase();
        // Admin, Supervisor, Engineer -> Admin Flow
        // Worker -> User Flow
        final isPrivileged = dbRole == 'admin' || dbRole == 'supervisor' || dbRole == 'engineer';
        
        AppData().currentUser = emp.name;
        AppData().currentUserRole = emp.role;
        AppSession.role = isPrivileged ? 'admin' : 'user';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isPrivileged ? const MainScreen() : const UserMainScreen(),
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee username not found!')),
        );
        return;
      }
    }

    // Default quick logins
    AppData().currentUserRole = role == 'admin' ? 'Admin' : 'Worker';
    AppData().currentUser = role == 'admin' ? 'Mahmoud Massoud' : 'Standard Worker';
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => role == 'admin' ? const MainScreen() : const UserMainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF042016), const Color(0xFF06402B)]
              : [const Color(0xFF06402B), const Color(0xFF0A5A3D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.security_rounded, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Role Selection',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 28, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 40),
                
                // --- CUSTOM LOGIN FIELD ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Login with Employee Username',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter username (e.g. ahmed)',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withAlpha(30),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.login_rounded, color: Colors.white),
                            onPressed: () => _handleLogin('', customUsername: _usernameController.text),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text('OR QUICK LOGIN', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 20),

                _buildRoleButton(
                  context,
                  title: 'Quick Admin',
                  subtitle: 'Directly enter Admin Flow',
                  icon: Icons.admin_panel_settings_rounded,
                  role: 'admin',
                ),
                const SizedBox(height: 20),
                _buildRoleButton(
                  context,
                  title: 'Quick Worker',
                  subtitle: 'Directly enter User Flow',
                  icon: Icons.person_rounded,
                  role: 'user',
                ),
                const SizedBox(height: 40),
                const Text(
                  'Admins, Supervisors, and Engineers use Admin Flow.\nWorkers use User Flow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
  }) {
    return GestureDetector(
      onTap: () => _handleLogin(role),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF06402B).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF06402B), size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF06402B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
