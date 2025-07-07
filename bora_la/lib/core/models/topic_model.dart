class TopicModel {
  final String id;
  final String titulo;
  final String descricao;
  final bool isChosen;
  final String? chosenByUid;
  final String? chosenByNickname;

  TopicModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.isChosen = false,
    this.chosenByUid,
    this.chosenByNickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'isChosen': isChosen,
      'chosenByUid': chosenByUid,
      'chosenByNickname': chosenByNickname,
    };
  }

  /// O 'id' é pego do documento do Firestore
  factory TopicModel.fromJson(Map<String, dynamic> json, String documentId) {
    return TopicModel(
      id: documentId,
      titulo: json['titulo'],
      descricao: json['descricao'],
      isChosen: json['isChosen'] ?? false,
      chosenByUid: json['chosenByUid'],
      chosenByNickname: json['chosenByNickname'],
    );
  }
}