import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorUid;
  final String authorNickname;
  final Timestamp createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorUid,
    required this.authorNickname,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorUid': authorUid,
      'authorNickname': authorNickname,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromJson(Map<String, dynamic> json, String documentId) {
    return CommentModel(
      id: documentId,
      text: json['text'],
      authorUid: json['authorUid'],
      authorNickname: json['authorNickname'],
      createdAt: json['createdAt'],
    );
  }
}
