class PointBalanceModel {
  final String familyId;
  final String userId;
  final int balance;

  PointBalanceModel({
    required this.familyId,
    required this.userId,
    required this.balance,
  });

  factory PointBalanceModel.fromJson(Map<String, dynamic> json) {
    return PointBalanceModel(
      familyId: json['familyId'] as String,
      userId: json['userId'] as String,
      balance: json['balance'] as int,
    );
  }
}

class PointTransactionModel {
  final String id;
  final int amount;
  final String type;
  final String? referenceType;
  final String? referenceId;
  final String? description;
  final DateTime createdAt;

  PointTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    this.referenceType,
    this.referenceId,
    this.description,
    required this.createdAt,
  });

  factory PointTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointTransactionModel(
      id: json['id'] as String,
      amount: json['amount'] as int,
      type: json['type'] as String,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
