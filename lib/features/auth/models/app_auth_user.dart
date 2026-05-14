class AppAuthUser {
  const AppAuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.emailVerified,
    required this.hasActiveSession,
    required this.provider,
    required this.createdAt,
    required this.lastLoginAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final bool emailVerified;
  final bool hasActiveSession;
  final String provider;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  static const String defaultRole = 'apprenant';

  AppAuthUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? role,
    bool? emailVerified,
    bool? hasActiveSession,
    String? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AppAuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      hasActiveSession: hasActiveSession ?? this.hasActiveSession,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role,
      'emailVerified': emailVerified,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  factory AppAuthUser.fromJson(Map<String, dynamic> json) {
    return AppAuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      role:
          json['role'] as String? ?? inferRole(json['email'] as String? ?? ''),
      emailVerified: json['emailVerified'] as bool? ?? false,
      hasActiveSession: json['hasActiveSession'] as bool? ?? false,
      provider: json['provider'] as String? ?? 'password',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lastLoginAt:
          DateTime.tryParse(json['lastLoginAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static String inferRole(String _) {
    return defaultRole;
  }

  static String fallbackDisplayName(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Apprenant DriveAuto';
    }

    final normalized = localPart
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.isEmpty) {
      return 'Apprenant DriveAuto';
    }

    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
