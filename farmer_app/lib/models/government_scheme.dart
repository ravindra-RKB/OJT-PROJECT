class GovernmentScheme {
  final String id;
  final String title;
  final String description;
  final String? eligibility;
  final String? benefits;
  final String? applicationLink;
  final DateTime? deadline;
  final String? category;

  GovernmentScheme({
    required this.id,
    required this.title,
    required this.description,
    this.eligibility,
    this.benefits,
    this.applicationLink,
    this.deadline,
    this.category,
  });

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) {
    return GovernmentScheme(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      eligibility: json['eligibility'] as String?,
      benefits: json['benefits'] as String?,
      applicationLink: json['applicationLink'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eligibility': eligibility,
      'benefits': benefits,
      'applicationLink': applicationLink,
      'deadline': deadline?.toIso8601String(),
      'category': category,
    };
  }
}

