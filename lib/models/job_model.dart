class Job {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final String category;
  final String url;
  final String companyLogo;
  final DateTime publishedDate;
  final String tags;
  bool isSaved;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.category,
    required this.url,
    required this.companyLogo,
    required this.publishedDate,
    required this.tags,
    this.isSaved = false,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch,
      title: json['title'] ?? 'No Title',
      company: json['company_name'] ?? 'Unknown Company',
      location: json['candidate_required_location'] ?? 'Remote',
      salary: json['salary'] ?? 'Not Specified',
      type: json['job_type'] ?? 'Full-time',
      description: json['description'] ?? 'No description available',
      category: json['category'] ?? 'Other',
      url: json['url'] ?? '',
      companyLogo: json['company_logo'] ?? '',
      publishedDate: json['publication_date'] != null
          ? DateTime.parse(json['publication_date'])
          : DateTime.now(),
      tags: json['tags'] != null
          ? (json['tags'] is List ? (json['tags'] as List).join(', ') : json['tags'].toString())
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company_name': company,
      'candidate_required_location': location,
      'salary': salary,
      'job_type': type,
      'description': description,
      'category': category,
      'url': url,
      'company_logo': companyLogo,
      'publication_date': publishedDate.toIso8601String(),
      'tags': tags,
      'isSaved': isSaved ? 1 : 0,
    };
  }
}