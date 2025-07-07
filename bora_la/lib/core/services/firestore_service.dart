import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/topic_model.dart';
import '../models/announcement_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> validateEnrollment(String cpf, String email) async {
    try {
      final doc = await _db.collection('enrollments').doc(cpf).get();

      if (doc.exists && doc.data()?['ativo'] == true) {
        final enrollmentData = doc.data()!;

        if (enrollmentData['email']?.toString().toLowerCase() == email.toLowerCase()) {
          return enrollmentData;
        }
      }
    } catch (e) {
      print('Erro ao validar matrícula: $e');
    }
    return null;
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

  Future<void> setUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      print('Erro ao salvar usuário: $e');
    }
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

  Future<void> deleteComment(String announcementId, String commentId) async {
    try {
      await _db
          .collection('announcements')
          .doc(announcementId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print('Erro ao apagar comentário: $e');
      rethrow;
    }
  }

  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    try {
      await _db.collection('announcements').add(data);
    } catch (e) {
      print('Erro ao criar anúncio: $e');
      rethrow;
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

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('announcements').doc(id).update(data);
    } catch (e) {
      print('Erro ao atualizar anúncio: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await deleteDocumentWithSubcollections(
        'announcements',
        announcementId,
        ['comments'],
      );
    } catch (e) {
      print('Erro ao apagar anúncio: $e');
      rethrow;
    }
  }

  Future<void> deleteDocumentWithSubcollections(
      String collection,
      String documentId,
      List<String> subcollectionNames,
      ) async {
    try {
      final docRef = _db.collection(collection).doc(documentId);

      for (final subcollectionName in subcollectionNames) {
        await deleteSubcollection(docRef, subcollectionName);
      }

      await docRef.delete();

      print('Documento $documentId deletado com subcoleções: ${subcollectionNames.join(', ')}');

    } catch (e) {
      print('Erro ao deletar documento com subcoleções: $e');
      rethrow;
    }
  }

  Future<void> deleteSubcollection(
      DocumentReference docRef,
      String subcollectionName,
      ) async {
    try {
      final subcollectionSnapshot = await docRef
          .collection(subcollectionName)
          .get();

      if (subcollectionSnapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in subcollectionSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        print('Subcoleção $subcollectionName deletada com ${subcollectionSnapshot.docs.length} documentos');
      }
    } catch (e) {
      print('Erro ao deletar subcoleção $subcollectionName: $e');
      rethrow;
    }
  }
}