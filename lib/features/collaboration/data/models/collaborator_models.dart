import 'package:equatable/equatable.dart';
import 'position_models.dart';

enum CollaboratorRole { host, cohost, member }

class Collaborator extends Equatable {
  final String? id;  // Made nullable since host doesn't have collaboration_id
  final String userId;
  final String username;
  final String? profilePictureUrl;
  final String roleTitle;
  final double profitShare;
  final bool isCohost;
  
  const Collaborator({
    this.id,
    required this.userId,
    required this.username,
    this.profilePictureUrl,
    required this.roleTitle,
    required this.profitShare,
    required this.isCohost,
  });

  CollaboratorRole get role {
    if (roleTitle.toLowerCase() == 'host') return CollaboratorRole.host;
    if (isCohost) return CollaboratorRole.cohost;
    return CollaboratorRole.member;
  }

  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      id: json['collaboration_id'] as String?,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      roleTitle: json['role_title'] as String,
      profitShare: (json['profit_share_percentage'] as num).toDouble(),
      isCohost: json['is_cohost'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collaboration_id': id,
      'user_id': userId,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'role_title': roleTitle,
      'profit_share_percentage': profitShare,
      'is_cohost': isCohost,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        profilePictureUrl,
        roleTitle,
        profitShare,
        isCohost,
      ];
}

class CollaborationHubData extends Equatable {
  final List<Collaborator> cohosts;
  final List<Collaborator> teamMembers;
  final List<OpenPosition> openPositions;

  const CollaborationHubData({
    required this.cohosts,
    required this.teamMembers,
    required this.openPositions,
  });

  bool get hasCollaborators => cohosts.isNotEmpty || teamMembers.isNotEmpty;
  bool get hasOpenPositions => openPositions.isNotEmpty;

  @override
  List<Object> get props => [cohosts, teamMembers, openPositions];
}