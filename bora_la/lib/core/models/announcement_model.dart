import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String titulo;
  final String corpo;
  final Timestamp dataCriacao;

  AnnouncementModel({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.dataCriacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'corpo': corpo,
      'dataCriacao': dataCriacao,
    };
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json, String documentId) {
    return AnnouncementModel(
      id: documentId,
      titulo: json['titulo'],
      corpo: json['corpo'],
      dataCriacao: json['dataCriacao'],
    );
  }
}