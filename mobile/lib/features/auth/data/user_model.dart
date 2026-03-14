class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;         // "passenger" | "operator" | "admin"
  final String? busId;       // operators only
  final String? fcmToken;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.busId,
    this.fcmToken,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid:       json['uid'] as String,
      name:      json['name'] as String,
      email:     json['email'] as String,
      phone:     json['phone'] as String,
      role:      json['role'] as String? ?? 'passenger',
      busId:     json['busId'] as String?,
      fcmToken:  json['fcmToken'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid':       uid,
    'name':      name,
    'email':     email,
    'phone':     phone,
    'role':      role,
    'busId':     busId,
    'fcmToken':  fcmToken,
  };
}
