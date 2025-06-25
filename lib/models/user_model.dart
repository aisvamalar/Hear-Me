class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final List<String>? searchHistory;
  final DateTime? lastSearchAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    this.searchHistory,
    this.lastSearchAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'searchHistory': searchHistory ?? [],
      'lastSearchAt': lastSearchAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'],
      createdAt: DateTime.parse(map['createdAt']),
      searchHistory: List<String>.from(map['searchHistory'] ?? []),
      lastSearchAt: map['lastSearchAt'] != null
          ? DateTime.parse(map['lastSearchAt'])
          : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    List<String>? searchHistory,
    DateTime? lastSearchAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      searchHistory: searchHistory ?? this.searchHistory,
      lastSearchAt: lastSearchAt ?? this.lastSearchAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL, createdAt: $createdAt)';
  }
}