class PersonView {
  final Person person;
  final Counts counts;

  PersonView({
    required this.person,
    required this.counts,
  });

  factory PersonView.fromJson(Map<String, dynamic> json) {
    return PersonView(
      person: Person.fromJson(json['person']),
      counts: Counts.fromJson(json['counts']),
    );
  }
}

class Person {
  final int id;
  final String name;
  String? avatar;
  final bool banned;
  final String published;
  final String actorId;
  final bool local;
  final bool deleted;
  final bool admin;
  final bool botAccount;
  final int instanceId;

  Person({
    required this.id,
    required this.name,
    this.avatar,
    required this.banned,
    required this.published,
    required this.actorId,
    required this.local,
    required this.deleted,
    required this.admin,
    required this.botAccount,
    required this.instanceId,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      banned: json['banned'],
      published: json['published'],
      actorId: json['actor_id'],
      local: json['local'],
      deleted: json['deleted'],
      admin: json['admin'],
      botAccount: json['bot_account'],
      instanceId: json['instance_id'],
    );
  }
}

class Counts {
  final int id;
  final int personId;
  final int postCount;
  final int postScore;
  final int commentCount;
  final int commentScore;

  Counts({
    required this.id,
    required this.personId,
    required this.postCount,
    required this.postScore,
    required this.commentCount,
    required this.commentScore,
  });

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      id: json['id'],
      personId: json['person_id'],
      postCount: json['post_count'],
      postScore: json['post_score'],
      commentCount: json['comment_count'],
      commentScore: json['comment_score'],
    );
  }
}
