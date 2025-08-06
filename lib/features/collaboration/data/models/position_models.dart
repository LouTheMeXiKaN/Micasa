import 'package:equatable/equatable.dart';

enum PositionStatus { open, filled }

class OpenPosition extends Equatable {
  final String id;
  final String eventId;
  final String roleTitle;
  final String description;
  final double? profitSharePercentage;
  final PositionStatus status;
  final int applicantCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OpenPosition({
    required this.id,
    required this.eventId,
    required this.roleTitle,
    required this.description,
    this.profitSharePercentage,
    required this.status,
    required this.applicantCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasApplications => applicantCount > 0;
  bool get canDelete => applicantCount == 0;

  factory OpenPosition.fromJson(Map<String, dynamic> json) {
    // Handle both backend formats - from /team endpoint and from direct position endpoints
    final positionId = json['position_id'] ?? json['id'];
    
    return OpenPosition(
      id: positionId as String,
      eventId: json['event_id'] as String? ?? json['eventId'] as String? ?? '',
      roleTitle: json['role_title'] as String,
      description: json['description'] as String? ?? '',
      profitSharePercentage: json['profit_share_percentage'] != null 
          ? (json['profit_share_percentage'] as num).toDouble() 
          : null,
      status: json['status'] != null 
          ? PositionStatus.values.byName(json['status'] as String)
          : PositionStatus.open,
      applicantCount: json['applicant_count'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'role_title': roleTitle,
      'description': description,
      'profit_share_percentage': profitSharePercentage,
      'status': status.name,
      'applicant_count': applicantCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        roleTitle,
        description,
        profitSharePercentage,
        status,
        applicantCount,
        createdAt,
        updatedAt,
      ];
}

class CreatePositionRequest extends Equatable {
  final String eventId;
  final String roleTitle;
  final String description;
  final double? profitSharePercentage;

  const CreatePositionRequest({
    required this.eventId,
    required this.roleTitle,
    required this.description,
    this.profitSharePercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'role_title': roleTitle,
      'description': description,
      'profit_share_percentage': profitSharePercentage,
    };
  }

  @override
  List<Object?> get props => [eventId, roleTitle, description, profitSharePercentage];
}

class UpdatePositionRequest extends Equatable {
  final String roleTitle;
  final String description;
  final double? profitSharePercentage;

  const UpdatePositionRequest({
    required this.roleTitle,
    required this.description,
    this.profitSharePercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'role_title': roleTitle,
      'description': description,
      'profit_share_percentage': profitSharePercentage,
    };
  }

  @override
  List<Object?> get props => [roleTitle, description, profitSharePercentage];
}