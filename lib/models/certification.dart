import 'package:json_annotation/json_annotation.dart';

part 'certification.g.dart';

/// A certification as returned by the Django portfolio API.
@JsonSerializable(fieldRename: FieldRename.snake)
class Certification {
  const Certification({
    this.id,
    required this.title,
    required this.description,
    required this.year,
    this.isHighlight = false,
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  // A draft has no ID. Every record read from Django must have one.
  @JsonKey(includeToJson: false, required: true, disallowNullValue: true)
  final int? id;
  final String title;
  final String description;
  final int year;
  final bool isHighlight;

  // These values describe the server's star records and the requesting user.
  @JsonKey(includeToJson: false)
  final int starCount;
  @JsonKey(includeToJson: false)
  final bool isStarred;
  @JsonKey(includeToJson: false)
  final String starredByNames;

  factory Certification.fromJson(Map<String, dynamic> json) =>
      _$CertificationFromJson(json);

  Map<String, dynamic> toJson() => _$CertificationToJson(this);
}
