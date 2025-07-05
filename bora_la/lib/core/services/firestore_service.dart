import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/topic_model.dart';
import '../models/announcement_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      print('Erro ao salvar usuário: $e');
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
    return null;
  }

  // Stream atualiza a lista automaticamente quando há mudanças.
  Stream<List<TopicModel>> getTopics() {
    return _db.collection('topics').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TopicModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateTopic(String topicId, Map<String, dynamic> data) async {
    try {
      await _db.collection('topics').doc(topicId).update(data);
    } catch (e) {
      print('Erro ao atualizar tópico: $e');
    }
  }


  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _db
        .collection('announcements')
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AnnouncementModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addComment(String announcementId, CommentModel comment) async {
    try {
      await _db
          .collection('announcements')
          .doc(announcementId)
          .collection('comments')
          .add(comment.toJson());
    } catch (e) {
      print('Erro ao adicionar comentário: $e');
    }
  }

  Stream<List<CommentModel>> getComments(String announcementId) {
    return _db
        .collection('announcements')
        .doc(announcementId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }
}
