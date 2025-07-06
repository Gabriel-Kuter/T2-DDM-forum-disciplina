import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';

class AnnouncementsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<AnnouncementModel> _announcements = [];
  Map<String, List<CommentModel>> _comments = {}; // announcementId -> comments
  bool _isLoading = false;
  String? _errorMessage;

  AnnouncementsProvider(this._firestoreService) {
    _listenToAnnouncements();
  }

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CommentModel> getCommentsForAnnouncement(String announcementId) {
    return _comments[announcementId] ?? [];
  }

  void _listenToAnnouncements() {
    _firestoreService.getAnnouncements().listen(
          (announcements) {
        _announcements = announcements;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar avisos: $error';
        notifyListeners();
      },
    );
  }

  void loadCommentsForAnnouncement(String announcementId) {
    _firestoreService.getComments(announcementId).listen(
          (comments) {
        _comments[announcementId] = comments;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erro ao carregar comentários: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> addComment({
    required String announcementId,
    required String text,
    required String authorUid,
    required String authorNickname,
  }) async {
    try {
      final comment = CommentModel(
        id: '', // Settado pelo Firestore
        text: text,
        authorUid: authorUid,
        authorNickname: authorNickname,
        createdAt: Timestamp.now(),
      );

      await _firestoreService.addComment(announcementId, comment);
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar comentário: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}