import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.projectUrl,
    this.projectImageUrl = '',
  });

  /// DRF assigns the UUID on creation.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String techStack;
  final String projectUrl;
  @JsonKey(defaultValue: '')
  final String projectImageUrl;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
