import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_data.dart';

class ResultScreen extends StatelessWidget {
  final XFile imageFile;
  final VoidCallback onNewScan;
  final VoidCallback onBack;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.onNewScan,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // الحصول على آخر سجل تمت إضافته (وهو النتيجة الحالية القادمة من السيرفر)
    final userRecords = AppData().userRecords;
    final latestRecord = userRecords.isNotEmpty
        ? userRecords.first
        : ClassificationRecord(
            name: 'Unknown',
            accuracyValue: 0.0,
            timestamp: DateTime.now(),
            imageUrl: imageFile.path,
            userId: AppData().currentUser,
          );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildResultHeader(context, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border.all(color: theme.dividerColor.withAlpha(20)),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Image.file(File(imageFile.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildConfidenceCard(latestRecord.accuracyValue, isDark),
                  const SizedBox(height: 24),
                  _buildPlantInfoCard(latestRecord, theme, isDark),
                  const SizedBox(height: 20),
                  _buildActionButton(context, 'Start New Classification', Icons.add_a_photo_outlined, isDark, onNewScan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withAlpha(30), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Classification Result',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Analysis complete',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(double confidence, bool isDark) {
    final accentColor = const Color(0xFF06402B);
    final String confidenceText = '${(confidence * 100).toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : accentColor,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.greenAccent.withAlpha(30)) : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Confidence Level', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(confidenceText, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantInfoCard(ClassificationRecord record, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 5), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: isDark ? Colors.greenAccent : const Color(0xFF06402B), size: 20),
              const SizedBox(width: 8),
              Text('Plant Information', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color
                )
              ),
            ],
          ),
          Divider(height: 32, color: theme.dividerColor.withAlpha(50)),
          _buildInfoItem(theme, isDark, 'Detected Plant', record.name),
          _buildInfoItem(theme, isDark, 'Processing Time', '${record.processingTime.toStringAsFixed(2)} seconds'),
          _buildInfoItem(theme, isDark, 'Scan Date', record.date),
        ],
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, bool isDark, String label, String value, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.greenAccent : const Color(0xFF06402B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, bool isDark, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF042016) : Colors.white,
          foregroundColor: isDark ? Colors.white : const Color(0xFF06402B),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: isDark ? BorderSide(color: Colors.greenAccent.withAlpha(50)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
