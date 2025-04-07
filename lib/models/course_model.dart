class Course {
  final String uuid;
  final String title;
  final String url;
  final String duration;
  final String programType;
  final String rating;
  final String subCategory;
  final String site;
  final String skills;

  Course({
    required this.uuid,
    required this.title,
    required this.url,
    required this.duration,
    required this.programType,
    required this.rating,
    required this.subCategory,
    required this.site,
    required this.skills,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        uuid: json['uuid'] ?? '',
        title: json['title'] ?? 'Untitled Course',
        url: json['url'] ?? '',
        duration: json['duration'] ?? '',
        programType: json['programType'] ?? '',
        rating: json['rating'] ?? '',
        subCategory: json['subCategory'] ?? '',
        site: json['site'] ?? '',
        skills: json['skills'] ?? '',
      );
    } catch (e) {
      print("Error parsing course: $e");
      print("Problematic JSON: $json");
      // Return a default course to avoid crashes
      return Course(
        uuid: '',
        title: 'Error Loading Course',
        url: '',
        duration: '',
        programType: '',
        rating: '',
        subCategory: '',
        site: '',
        skills: '',
      );
    }
  }

  @override
  String toString() {
    return 'Course{uuid: $uuid, title: $title, site: $site}';
  }
}
