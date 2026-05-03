import 'dart:convert';

class User {
  final String username;
  final String? profilePicturePath;

  User({
    required this.username,
    this.profilePicturePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profilePicturePath': profilePicturePath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      profilePicturePath: map['profilePicturePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
