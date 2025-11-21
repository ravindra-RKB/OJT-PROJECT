import 'package:hive/hive.dart';

class FarmDiaryEntry extends HiveObject {
  String id;
  String title;
  String description;
  DateTime date;
  String? cropType;
  String? fieldLocation;
  List<String>? imagePaths;
  Map<String, dynamic>? additionalData;

  FarmDiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.cropType,
    this.fieldLocation,
    this.imagePaths,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'cropType': cropType,
      'fieldLocation': fieldLocation,
      'imagePaths': imagePaths,
      'additionalData': additionalData,
    };
  }

  factory FarmDiaryEntry.fromJson(Map<String, dynamic> json) {
    return FarmDiaryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      cropType: json['cropType'] as String?,
      fieldLocation: json['fieldLocation'] as String?,
      imagePaths: json['imagePaths'] != null
          ? List<String>.from(json['imagePaths'] as List)
          : null,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }
}

