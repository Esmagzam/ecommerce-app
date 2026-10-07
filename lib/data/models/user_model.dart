class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_admin': isAdmin,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    bool? isAdmin,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
