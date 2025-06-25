class SearchHistory {
  final String id;
  final String query;
  final DateTime timestamp;
  final String userId;

  SearchHistory({
    required this.id,
    required this.query,
    required this.timestamp,
    required this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Create from Firestore document
  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'] ?? '',
      query: map['query'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      userId: map['userId'] ?? '',
    );
  }

  // Create from Firestore DocumentSnapshot
  factory SearchHistory.fromFirestore(Map<String, dynamic> data, String documentId) {
    return SearchHistory(
      id: documentId,
      query: data['query'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0),
      userId: data['userId'] ?? '',
    );
  }
}