class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String branch;
  final String? phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.branch,
    this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String parsedBranch = 'Dubai';
    if (json['branches'] != null) {
      if (json['branches'] is List) {
        parsedBranch = (json['branches'] as List).map((e) => e.toString()).join(', ');
      } else {
        parsedBranch = json['branches'].toString();
      }
    } else if (json['branch'] != null) {
      parsedBranch = json['branch'].toString();
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['name']?.toString() ?? '',
      name: json['name']?.toString() ?? json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Admin',
      branch: parsedBranch,
      phone: json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role,
      'branch': branch,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}
