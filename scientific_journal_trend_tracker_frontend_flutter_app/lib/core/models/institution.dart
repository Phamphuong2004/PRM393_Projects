/// Lightweight model for the institution catalog (used in register/profile dropdowns).
class Institution {
  final String id;
  final String name;
  final String? country;
  final String? city;
  final String? website;

  const Institution({
    required this.id,
    required this.name,
    this.country,
    this.city,
    this.website,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      country: json['country'] as String?,
      city: json['city'] as String?,
      website: json['website'] as String?,
    );
  }
}
