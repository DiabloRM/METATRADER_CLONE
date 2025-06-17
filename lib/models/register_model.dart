class RegisterModel {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String country;
  final String city;
  final String zipCode;
  final String phone;

  RegisterModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.name,
    required this.country,
    required this.city,
    required this.zipCode,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'name': name,
      'country': country,
      'city': city,
      'zipCode': zipCode,
      'phone': phone,
    };
  }

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      zipCode: json['zipCode'] as String,
      phone: json['phone'] as String,
    );
  }
}
