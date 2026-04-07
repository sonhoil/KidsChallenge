class UserModel {
  final String id;
  final String username;
  final String? email;
  final String? nickname;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.nickname,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nickname': nickname,
    };
  }
}
