class Community {
  final String communityId;
  final String accountId;
  final String community;
  final DateTime? createdAt;
  final DateTime? removedAt;

  Community({
    required this.communityId,
    required this.accountId,
    required this.community,
    this.createdAt,
    this.removedAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      communityId: json['communityId'],
      accountId: json['accountId'],
      community: json['community'],
      createdAt: DateTime.parse(json['createdAt']),
      removedAt: json['removedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'accountId': accountId,
      'community': community,
      'createdAt': createdAt,
      'removedAt': removedAt,
    };
  }
}
