class Workspace {
  final String id;
  final String name;
  final String description;
  final String visibility;
  final String plan;
  final dynamic owner;
  final List<dynamic> members;

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
    required this.plan,
    this.owner,
    this.members = const [],
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      visibility: json['visibility'] ?? 'team',
      plan: json['plan'] ?? 'free',
      owner: json['owner'],
      members: json['members'] ?? [],
    );
  }
}
