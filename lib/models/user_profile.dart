class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatarUrl;
  final String? ntrpRating;
  final String status;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.role = 'player',
    this.ntrpRating,
    this.status = 'active',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    return email.isNotEmpty ? email : 'Unknown User';
  }

  String get displayName {
    if (firstName.trim().isNotEmpty) return firstName.trim();
    if (lastName.trim().isNotEmpty) return lastName.trim();
    return email.isNotEmpty ? email : 'User';
  }
  bool get isAdmin => role == 'admin';

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String firstName = json['first_name'] as String? ?? '';
    String lastName = json['last_name'] as String? ?? '';
    final String? fullName = json['full_name'] as String?;

    // Fallback: If specific name fields are missing but full_name exists, parse it
    if (firstName.isEmpty && lastName.isEmpty && fullName != null && fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    }

    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'player',
      ntrpRating: json['ntrp_rating']?.toString(), // Handle numeric or string
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'role': role,
      'ntrp_rating': ntrpRating,
      'status': status,
    };
  }
}

