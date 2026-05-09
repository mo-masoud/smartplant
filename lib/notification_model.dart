import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle potential null or missing timestamp
    DateTime parsedTime;
    var rawTimestamp = data['timestamp'];
    if (rawTimestamp != null && rawTimestamp is Timestamp) {
      parsedTime = rawTimestamp.toDate();
    } else {
      parsedTime = DateTime.now();
    }

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: parsedTime,
      isRead: data['isRead'] ?? false,
    );
  }
}
