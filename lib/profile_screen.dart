import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_data.dart';
import 'widgets/pressable.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  String? _pendingImagePath;
  bool _isSaving = false;
  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    _imagePath = AppData().profileImageFor(AppData().currentUser);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _pendingImagePath = pickedFile.path;
          _imagePath = pickedFile.path;
          _showSaveButton = true;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_pendingImagePath == null) return;
    setState(() => _isSaving = true);

    try {
      await AppData().setProfileImage(AppData().currentUser, _pendingImagePath!);
      _imagePath = AppData().profileImageFor(AppData().currentUser);
      _pendingImagePath = null;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isSaving = false);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _showSaveButton = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout from your account?'),
          actions: [
            Pressable(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),
            Pressable(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData();
    final userName = appData.currentUser;
    final userRole = appData.currentUserRole;
    
    String email = 'user@company.com';
    try {
      final firstName = userName.split(' ')[0].toLowerCase();
      final emp = appData.findEmployeeByUsername(firstName);
      if (emp != null) email = emp.email;
    } catch (_) {}

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, userName, userRole),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildInfoSection(context, email, isDark),
                  const SizedBox(height: 40),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06402B), Color(0xFF0A5A3D)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Pressable(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              // SAVE BUTTON APPEARS HERE WHEN PHOTO CHOSEN AND DISAPPEARS AFTER CLICK
              _showSaveButton
                ? Pressable(
                    child: TextButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                : const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 30),
          Pressable(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                      child: _imagePath == null
                          ? const Icon(Icons.person, size: 70, color: Color(0xFF06402B))
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF06402B)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(role, style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String email, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 5), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Icons.email_outlined, 'Email Address', email),
          Divider(height: 32, color: Theme.of(context).dividerColor),
          _buildInfoRow(context, Icons.phone_android_outlined, 'Mobile Number', '+20 123 456 789'),
          Divider(height: 32, color: Theme.of(context).dividerColor),
          _buildInfoRow(context, Icons.location_on_outlined, 'Department', 'Quality Control Lab'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(20), 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Pressable(
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => _showLogoutConfirmation(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            foregroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded),
              SizedBox(width: 12),
              Text('Logout from Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
