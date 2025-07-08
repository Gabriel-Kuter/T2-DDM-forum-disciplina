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
    _isLoading = true;
    _firestoreService.getTopics().listen(
          (topics) {
        _topics = topics;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar temas: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> addTopic(String title, String description) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newTopic = TopicModel(
        id: '', // O ID será gerado pelo Firestore
        titulo: title,
        descricao: description,
      );

      await _firestoreService.addTopic(newTopic.toJson());

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao adicionar tema: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTopic(String topicId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.deleteTopic(topicId);

      _isLoading = false;
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao deletar tema: $e';
      notifyListeners();
      return false;
    }
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
      _errorMessage = 'Erro ao escolher tema: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unchooseTopic(String topicId, String userUid, String userRole) async {
    try {
      final topic = _topics.firstWhere((t) => t.id == topicId);

      if (userRole != 'professor' && topic.chosenByUid != userUid) {
        _errorMessage = 'Você não pode desmarcar um tema escolhido por outro aluno.';
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
      _errorMessage = 'Erro ao desmarcar tema: $e';
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