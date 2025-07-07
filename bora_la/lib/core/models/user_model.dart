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
}