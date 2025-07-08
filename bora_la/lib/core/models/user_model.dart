class UserModel {
  final String uid;
  final String email;
  final String nome;
  final String? nickname;
  final String? avatarUrl;
  final String role; // 'aluno' ou 'professor'
  final String matricula;

  UserModel({
    required this.uid,
    required this.email,
    required this.nome,
    this.nickname,
    this.avatarUrl,
    required this.role,
    required this.matricula,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'nome': nome,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'role': role,
      'matricula': matricula,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      nome: json['nome'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      role: json['role'],
      matricula: json['matricula'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nome,
    String? nickname,
    String? avatarUrl,
    String? role,
    String? matricula,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      matricula: matricula ?? this.matricula,
    );
  }

  String get displayName => nickname?.isNotEmpty == true ? nickname! : nome;

  String get initials {
    if (nickname?.isNotEmpty == true) {
      return nickname!.substring(0, 1).toUpperCase();
    }
    return nome.substring(0, 1).toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.nome == nome &&
        other.nickname == nickname &&
        other.avatarUrl == avatarUrl &&
        other.role == role &&
        other.matricula == matricula;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
    email.hashCode ^
    nome.hashCode ^
    nickname.hashCode ^
    avatarUrl.hashCode ^
    role.hashCode ^
    matricula.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, nome: $nome, nickname: $nickname, avatarUrl: $avatarUrl, role: $role, matricula: $matricula)';
  }
}