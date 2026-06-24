import 'dart:io';
import 'package:flutter/material.dart';
import 'app_data.dart';
import 'widgets/pressable.dart';

class RecordsScreen extends StatefulWidget {
  final bool isUserRole;
  const RecordsScreen({super.key, this.isUserRole = false});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  void _showDeleteDialog(BuildContext context, ClassificationRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete the classification for ${record.name}?'),
        actions: [
          Pressable(
            child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ),
          Pressable(
            child: TextButton(
              onPressed: () {
                final globalIndex = AppData().records.indexOf(record);
                if (globalIndex != -1) AppData().removeRecord(globalIndex);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record deleted')));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: ListenableBuilder(
              listenable: AppData(),
              builder: (context, _) {
                final records = widget.isUserRole ? AppData().userRecords : AppData().records;
                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 64, color: theme.hintColor.withAlpha(50)),
                        const SizedBox(height: 16),
                        Text('No records found', style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: records.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildRecordItem(records[index], isDark, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF042016) : const Color(0xFF06402B),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(44),
          bottomRight: Radius.circular(44),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isUserRole ? 'History' : 'Records',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isUserRole ? 'Your recent classifications' : 'Classification history',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(ClassificationRecord record, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 5), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: record.imageUrl.isNotEmpty
                ? Image.file(File(record.imageUrl), width: 80, height: 80, fit: BoxFit.cover)
                : Container(
                    width: 80, height: 80, 
                    color: isDark ? Colors.white.withAlpha(10) : const Color(0xFFF5F7F6),
                    child: Icon(Icons.eco_rounded, 
                      color: isDark ? Colors.greenAccent : const Color(0xFF06402B), 
                      size: 35),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 17,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    // Only show delete option for Admin flow
                    if (!widget.isUserRole)
                      Pressable(
                        child: GestureDetector(
                          onTap: () => _showDeleteDialog(context, record),
                          child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withAlpha(150), size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06402B).withAlpha(isDark ? 60 : 20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        record.accuracy,
                        style: TextStyle(
                          color: isDark ? Colors.greenAccent : const Color(0xFF06402B), 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        record.date,
                        style: TextStyle(color: theme.hintColor, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
