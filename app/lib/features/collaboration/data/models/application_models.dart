import 'package:equatable/equatable.dart';

enum ApplicationStatus { pending, accepted, declined, withdrawn }

class Application extends Equatable {
  final String id;
  final String positionId;
  final String userId;
  final String username;
  final String? profilePictureUrl;
  final String? bio;
  final String? instagramHandle;
  final String? personalWebsite;
  final String applicationMessage;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const Application({
    required this.id,
    required this.positionId,
    required this.userId,
    required this.username,
    this.profilePictureUrl,
    this.bio,
    this.instagramHandle,
    this.personalWebsite,
    required this.applicationMessage,
    required this.status,
    required this.appliedAt,
  });

  // Helper for message preview (first 2-3 lines)
  String get messagePreview {
    const maxLength = 100;
    if (applicationMessage.length <= maxLength) return applicationMessage;
    return '${applicationMessage.substring(0, maxLength)}...';
  }

  bool get hasSocialLinks => 
      (instagramHandle?.isNotEmpty ?? false) || 
      (personalWebsite?.isNotEmpty ?? false);

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      positionId: json['position_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      bio: json['bio'] as String?,
      instagramHandle: json['instagram_handle'] as String?,
      personalWebsite: json['personal_website'] as String?,
      applicationMessage: json['application_message'] as String,
      status: ApplicationStatus.values.byName(json['status'] as String),
      appliedAt: DateTime.parse(json['applied_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position_id': positionId,
      'user_id': userId,
      'username': username,
      'profile_picture_url': profilePictureUrl,
      'bio': bio,
      'instagram_handle': instagramHandle,
      'personal_website': personalWebsite,
      'application_message': applicationMessage,
      'status': status.name,
      'applied_at': appliedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        positionId,
        userId,
        username,
        profilePictureUrl,
        bio,
        instagramHandle,
        personalWebsite,
        applicationMessage,
        status,
        appliedAt,
      ];
}