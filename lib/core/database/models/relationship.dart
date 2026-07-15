class ContentRelationship {
  final String sourceId;
  final String targetId;
  final String relationshipType;
  final double weight;

  const ContentRelationship({
    required this.sourceId,
    required this.targetId,
    required this.relationshipType,
    required this.weight,
  });

  factory ContentRelationship.fromJson(Map<String, dynamic> json) {
    return ContentRelationship(
      sourceId: json['source_id'] as String? ?? '',
      targetId: json['target_id'] as String? ?? '',
      relationshipType: json['relationship_type'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
