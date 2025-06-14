class RegisterModel {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String country;
  final String? state;
  final String city;
  final String zipCode;
  final String phone;
  final String? address;

  RegisterModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.name,
    required this.country,
    this.state,
    required this.city,
    required this.zipCode,
    required this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'name': name,
        'country': country,
        'state': state,
        'city': city,
        'zipCode': zipCode,
        'phone': phone,
        'address': address,
      };
}
