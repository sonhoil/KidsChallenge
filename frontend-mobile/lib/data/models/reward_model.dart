class RewardModel {
  final String id;
  final String familyId;
  final String title;
  final String? description;
  final int pricePoints;
  final String? category;
  final String? iconType;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  RewardModel({
    required this.id,
    required this.familyId,
    required this.title,
    this.description,
    required this.pricePoints,
    this.category,
    this.iconType,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      pricePoints: json['pricePoints'] as int,
      category: json['category'] as String?,
      iconType: json['iconType'] as String?,
      isActive: json['isActive'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class RewardPurchaseModel {
  final String id;
  final String rewardId;
  final String? rewardTitle;
  final String? rewardIconType;
  final String buyerId;
  final String? buyerNickname;
  final String familyId;
  final String status; // 'pending', 'confirmed', 'used', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RewardPurchaseModel({
    required this.id,
    required this.rewardId,
    this.rewardTitle,
    this.rewardIconType,
    required this.buyerId,
    this.buyerNickname,
    required this.familyId,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RewardPurchaseModel.fromJson(Map<String, dynamic> json) {
    return RewardPurchaseModel(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      rewardTitle: json['rewardTitle'] as String?,
      rewardIconType: json['rewardIconType'] as String?,
      buyerId: json['buyerId'] as String,
      buyerNickname: json['buyerNickname'] as String?,
      familyId: json['familyId'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
