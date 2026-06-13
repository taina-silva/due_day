import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;
  final String? themePreference;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.createdAt,
    this.name,
    this.photoUrl,
    this.themePreference,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    String? themePreference,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  @override
  List<Object?> get props => [uid, email, name, photoUrl, createdAt, themePreference];
}
