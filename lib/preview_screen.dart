import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PreviewScreen extends StatefulWidget {
  final XFile imageFile;
  final bool isFromCamera;
  final VoidCallback onSelectDifferent;
  final Future<void> Function() onSubmit;

  const PreviewScreen({
    super.key,
    required this.imageFile,
    required this.isFromCamera,
    required this.onSelectDifferent,
    required this.onSubmit,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isAnalyzing = false;

  Future<void> _handlePressSubmit() async {
    setState(() => _isAnalyzing = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(isDark, 'Image Preview', 'Verify your plant image'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 40 : 5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image_outlined, 
                              color: isDark ? Colors.greenAccent : const Color(0xFF06402B), 
                              size: 20
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Image Preview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: isDark ? Colors.greenAccent : const Color(0xFF06402B)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 300,
                                width: double.infinity,
                                color: isDark ? Colors.black.withAlpha(50) : Colors.grey[200],
                                child: Image.file(File(widget.imageFile.path), fit: BoxFit.cover),
                              ),
                              if (_isAnalyzing)
                                Container(
                                  height: 300,
                                  width: double.infinity,
                                  color: Colors.black.withAlpha(150),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: isDark ? Colors.greenAccent : Colors.white,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Analyzing Image...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(
                    context, 
                    _isAnalyzing ? 'Processing...' : 'Submit for Classification', 
                    Icons.analytics_outlined, 
                    true, 
                    isDark, 
                    _isAnalyzing ? null : _handlePressSubmit
                  ),
                  const SizedBox(height: 12),
                  if (!_isAnalyzing)
                    _buildActionButton(
                      context,
                      widget.isFromCamera ? 'Scan Again' : 'Select Different Image', 
                      widget.isFromCamera ? Icons.camera_alt_outlined : Icons.photo_library_outlined, 
                      false, 
                      isDark,
                      widget.onSelectDifferent
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 8, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
            onPressed: _isAnalyzing ? null : widget.onSelectDifferent,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, bool isPrimary, bool isDark, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary 
              ? (isDark ? const Color(0xFF042016) : const Color(0xFF06402B)) 
              : (isDark ? Colors.white.withAlpha(10) : Colors.white),
          foregroundColor: isPrimary ? Colors.white : (isDark ? Colors.greenAccent : const Color(0xFF06402B)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: !isPrimary && isDark ? BorderSide(color: Colors.greenAccent.withAlpha(50)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onTap == null)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
