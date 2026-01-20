class User {
  final int? id;
  final String role;
  final String username;
  final String firstName;
  final String lastName;
  final String mailId;
  final String phone;
  final String dob;
  final String password;
  final String? confirmPassword;
  final bool isActive;

  User({
    this.id,
    required this.role,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.mailId,
    required this.phone,
    required this.dob,
    required this.password,
    this.confirmPassword,
    this.isActive = true,
  });

  /// JSON → Dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      mailId: json['mailId'],
      phone: json['phone'],
      dob: json['dob'],
      password: json['password'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  /// Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "username": username,
      "firstName": firstName,
      "lastName": lastName,
      "mailId": mailId,
      "phone": phone,
      "dob": dob,
      "password": password,
      "confirmPassword": confirmPassword,
    };
  }
}
