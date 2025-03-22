// models/complaint.dart
import 'package:cloud_firestore/cloud_firestore.dart';  // Import this for Timestamp

class Complaint {
  final String userId;
  final String complaintText;
  final DateTime timestamp;

  Complaint({
    required this.userId,
    required this.complaintText,
    required this.timestamp,
  });

  // Convert a Complaint to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'complaintText': complaintText,
      'timestamp': timestamp,
    };
  }

  // Convert Firestore data to a Complaint instance
  factory Complaint.fromFirestore(Map<String, dynamic> data) {
    return Complaint(
      userId: data['userId'],
      complaintText: data['complaintText'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
