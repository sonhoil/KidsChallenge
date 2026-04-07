class FamilyModel {
  final String id;
  final String name;
  final String? inviteCode;
  final String? role; // 'parent' or 'child'
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyModel({
    required this.id,
    required this.name,
    this.inviteCode,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['inviteCode'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class FamilyMemberModel {
  final String id;
  final String familyId;
  // userId 는 null 일 수 있다 (소셜/이메일 계정과 아직 연결되지 않은 아이 멤버)
  final String? userId;
  final String role; // 'parent' or 'child'
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;

  FamilyMemberModel({
    required this.id,
    required this.familyId,
    this.userId,
    required this.role,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      userId: json['userId'] as String?,
      role: json['role'] as String,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
