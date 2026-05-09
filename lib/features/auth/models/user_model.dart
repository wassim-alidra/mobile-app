class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? wilaya;
  final String? profileImage;
  final String approvalStatus;
  final bool hasActiveMission;
  final Map<String, dynamic>? profile;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.wilaya,
    this.profileImage,
    required this.approvalStatus,
    this.hasActiveMission = false,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      wilaya: json['wilaya'] as String?,
      profileImage: json['profile_image'] as String?,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      hasActiveMission: json['has_active_mission'] as bool? ?? false,
      profile: json['profile'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role,
    'wilaya': wilaya,
    'profile_image': profileImage,
    'approval_status': approvalStatus,
    'has_active_mission': hasActiveMission,
    'profile': profile,
  };

  // Transporter profile convenience getters
  String get vehicleType => profile?['vehicle_type'] as String? ?? '—';
  String get licensePlate => profile?['license_plate'] as String? ?? '—';
  double get capacity => (profile?['capacity'] as num?)?.toDouble() ?? 0.0;

  String get displayName {
    final parts = username.split('_');
    return parts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
  }

  bool get isApproved => approvalStatus == 'approved';
}
