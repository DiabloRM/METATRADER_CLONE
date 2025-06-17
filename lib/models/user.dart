class User {
  final String login;
  final String email;
  final String name;
  final String? phone;
  final String? country;
  final String? city;
  final String? zipCode;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.login,
    required this.email,
    required this.name,
    this.phone,
    this.country,
    this.city,
    this.zipCode,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      login: json['login'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      zipCode: json['zipCode'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'email': email,
      'name': name,
      'phone': phone,
      'country': country,
      'city': city,
      'zipCode': zipCode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
