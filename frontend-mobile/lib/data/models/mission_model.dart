class MissionModel {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final int defaultPoints;
  final String? iconType;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionModel({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.defaultPoints,
    this.iconType,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      defaultPoints: json['defaultPoints'] as int,
      iconType: json['iconType'] as String?,
      isActive: json['isActive'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class MissionAssignmentModel {
  final String id;
  final String missionId;
  final String? missionTitle;
  final String? missionIconType;
  final bool? oneOff;
  final bool? recentlyRejected;
  final String assigneeId;
  final String? assigneeNickname;
  final String assignedBy;
  final String familyId;
  final DateTime? dueDate;
  final String status; // 'todo', 'pending', 'approved', 'rejected', 'cancelled'
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionAssignmentModel({
    required this.id,
    required this.missionId,
    this.missionTitle,
    this.missionIconType,
    this.oneOff,
    this.recentlyRejected,
    required this.assigneeId,
    this.assigneeNickname,
    required this.assignedBy,
    required this.familyId,
    this.dueDate,
    required this.status,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissionAssignmentModel.fromJson(Map<String, dynamic> json) {
    return MissionAssignmentModel(
      id: json['id'] as String,
      missionId: json['missionId'] as String,
      missionTitle: json['missionTitle'] as String?,
      missionIconType: json['missionIconType'] as String?,
      oneOff: json['oneOff'] as bool?,
      recentlyRejected: json['recentlyRejected'] as bool?,
      assigneeId: json['assigneeId'] as String,
      assigneeNickname: json['assigneeNickname'] as String?,
      assignedBy: json['assignedBy'] as String,
      familyId: json['familyId'] as String,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      status: json['status'] as String,
      points: json['points'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
