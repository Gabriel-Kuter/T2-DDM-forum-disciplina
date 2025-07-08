import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorUid;
  final String authorNickname;
  final String? authorAvatarUrl;
  final Timestamp createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorUid,
    required this.authorNickname,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorUid': authorUid,
      'authorNickname': authorNickname,
      'authorAvatarUrl': authorAvatarUrl,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json, String documentId) {
    return CommentModel(
      id: documentId,
      text: json['text'],
      authorUid: json['authorUid'],
      authorNickname: json['authorNickname'],
      authorAvatarUrl: json['authorAvatarUrl'],
      createdAt: json['createdAt'],
    );
  }
}