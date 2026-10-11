class TagEntity {
  const TagEntity({
    required this.id,
    required this.name,
    this.color = 0,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int color;
  final DateTime createdAt;

  TagEntity copyWith({int? id, String? name, int? color, DateTime? createdAt}) {
    return TagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, name, color, createdAt);

  @override
  String toString() => 'TagEntity(id: $id, name: "$name", color: $color)';
}
