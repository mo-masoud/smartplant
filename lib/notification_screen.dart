import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'notification_model.dart';
import 'widgets/pressable.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _showDeleteDialog(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          Pressable(
            child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ),
          Pressable(
            child: TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification deleted')));
                }
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Notifications', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          )
        ),
        centerTitle: true,
        leading: Pressable(
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: theme.textTheme.bodyLarge?.color
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: 'mahmoud_massoud')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, 
                    size: 60, 
                    color: theme.hintColor.withAlpha(50)
                  ),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: theme.hintColor)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = NotificationModel.fromFirestore(docs[index]);
              return _buildNotificationItem(context, notification, isDark, theme);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel item, bool isDark, ThemeData theme) {
    return Pressable(
      child: GestureDetector(
      onTap: () {
        FirebaseFirestore.instance.collection('notifications').doc(item.id).update({'isRead': true});
      },
      onLongPress: () => _showDeleteDialog(context, item.id, item.title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead 
              ? theme.cardColor
              : (isDark ? const Color(0xFF06402B).withAlpha(40) : const Color(0xFFE8F5E9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isRead 
              ? Colors.transparent 
              : (isDark ? Colors.greenAccent.withAlpha(50) : const Color(0xFF06402B).withAlpha(100)),
          ),
          boxShadow: [
            if (!item.isRead)
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black12).withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: item.isRead 
                  ? theme.hintColor.withAlpha(30) 
                  : (isDark ? Colors.greenAccent : const Color(0xFF06402B)),
              child: Icon(
                item.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: item.isRead ? theme.hintColor : Colors.white,
                size: 20,
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
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w900,
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Pressable(
                        child: GestureDetector(
                          onTap: () => _showDeleteDialog(context, item.id, item.title),
                          child: Icon(Icons.close_rounded, size: 18, color: theme.hintColor.withAlpha(100)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(200),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('hh:mm a • dd MMM').format(item.timestamp),
                    style: TextStyle(color: theme.hintColor, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
