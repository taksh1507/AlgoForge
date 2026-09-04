class UserProfile {
  final String uid;
  final String username;
  final String displayName;
  final String email;
  final int rating;
  final int totalSolved;
  final int easySolved;
  final int mediumSolved;
  final int hardSolved;
  final int streak;
  final int contestRanking;
  final DateTime? syncedAt;
  final DateTime? createdAt;

  UserProfile({
    required this.uid,
    required this.username,
    this.displayName = '',
    this.email = '',
    this.rating = 0,
    this.totalSolved = 0,
    this.easySolved = 0,
    this.mediumSolved = 0,
    this.hardSolved = 0,
    this.streak = 0,
    this.contestRanking = 0,
    this.syncedAt,
    this.createdAt,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      rating: data['rating'] ?? 0,
      totalSolved: data['totalSolved'] ?? 0,
      easySolved: data['easySolved'] ?? 0,
      mediumSolved: data['mediumSolved'] ?? 0,
      hardSolved: data['hardSolved'] ?? 0,
      streak: data['streak'] ?? 0,
      contestRanking: data['contestRanking'] ?? 0,
      syncedAt: data['syncedAt']?.toDate(),
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'displayName': displayName,
      'email': email,
      'rating': rating,
      'totalSolved': totalSolved,
      'easySolved': easySolved,
      'mediumSolved': mediumSolved,
      'hardSolved': hardSolved,
      'streak': streak,
      'contestRanking': contestRanking,
      'syncedAt': syncedAt,
      'createdAt': createdAt,
    };
  }

  UserProfile copyWith({
    String? username,
    String? displayName,
    int? rating,
    int? totalSolved,
    int? easySolved,
    int? mediumSolved,
    int? hardSolved,
    int? streak,
    int? contestRanking,
    DateTime? syncedAt,
  }) {
    return UserProfile(
      uid: uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email,
      rating: rating ?? this.rating,
      totalSolved: totalSolved ?? this.totalSolved,
      easySolved: easySolved ?? this.easySolved,
      mediumSolved: mediumSolved ?? this.mediumSolved,
      hardSolved: hardSolved ?? this.hardSolved,
      streak: streak ?? this.streak,
      contestRanking: contestRanking ?? this.contestRanking,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt,
    );
  }
}
