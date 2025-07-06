import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../services/firestore_service.dart';

class TopicsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  List<TopicModel> _topics = [];
  bool _isLoading = false;
  String? _errorMessage;

  TopicsProvider(this._firestoreService) {
    _listenToTopics();
  }

  List<TopicModel> get topics => _topics;
  List<TopicModel> get availableTopics => _topics.where((topic) => !topic.isChosen).toList();
  List<TopicModel> get chosenTopics => _topics.where((topic) => topic.isChosen).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _listenToTopics() {
    _firestoreService.getTopics().listen(
          (topics) {
        _topics = topics;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar assuntos: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> chooseTopic(String topicId, String userUid, String userNickname) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateTopic(topicId, {
        'isChosen': true,
        'chosenByUid': userUid,
        'chosenByNickname': userNickname,
      });

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao escolher assunto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unchooseTopic(String topicId, String userUid) async {
    try {
      final topic = _topics.firstWhere((t) => t.id == topicId);
      if (topic.chosenByUid != userUid) {
        _errorMessage = 'Você não pode desmarcar um assunto escolhido por outro aluno.';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateTopic(topicId, {
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      });

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao desmarcar assunto: $e';
      notifyListeners();
      return false;
    }
  }

  bool hasUserChosenTopic(String userUid) {
    return _topics.any((topic) => topic.chosenByUid == userUid);
  }

  TopicModel? getUserChosenTopic(String userUid) {
    try {
      return _topics.firstWhere((topic) => topic.chosenByUid == userUid);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}