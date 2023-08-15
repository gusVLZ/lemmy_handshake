class Community {
  int? id;
  final String externalId;
  int? accountId;
  final String community;
  final DateTime? createdAt;
  final DateTime? removedAt;

  Community({
    this.id,
    required this.externalId,
    this.accountId,
    required this.community,
    this.createdAt,
    this.removedAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      externalId: json['communityId'],
      accountId: json['accountId'],
      community: json['community'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ""),
      removedAt: DateTime.tryParse(json['removedAt'] ?? ""),
    );
  }

  factory Community.fromDb(Map<String, dynamic> json) {
    return Community(
      id: json['id'],
      externalId: json['externalId'],
      accountId: json['accountId'],
      community: json['community'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? ""),
      removedAt: DateTime.tryParse(json['removedAt'] ?? ""),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'externalId': externalId,
      'accountId': accountId,
      'community': community,
      'createdAt': createdAt?.toIso8601String(),
      'removedAt': removedAt?.toIso8601String(),
    };
  }
}
