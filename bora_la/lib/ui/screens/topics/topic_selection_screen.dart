import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/topic_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/topics_provider.dart';
import '../../../core/utils/constants.dart';

/*
 TODO:
  - Criar FAB (FloatingActionButton) para criar novos temas;
    Veja o FloatingActionButton da home_screen (cria avisos) para exemplo.
    Somente o professor pode criar novos temas. (FAB visível somente para ele)
  - Criar botão para apagar temas (somente professor).
  - Garantir que a tela atualiza com novos temas/temas apagados ao executar as ações.
*/

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  bool _isAvailableExpanded = true;

  Future<void> _handleChooseTopic(TopicModel topic) async {
    final topicsProvider = context.read<TopicsProvider>();
    final user = context.read<AuthProvider>().user;

    if (user == null) return;

    if (topicsProvider.hasUserChosenTopic(user.uid)) {
      _showErrorSnackBar(
        'Você já escolheu um tema. Desmarque o atual para escolher outro.',
      );
      return;
    }

    final success = await topicsProvider.chooseTopic(
      topic.id,
      user.uid,
      user.nickname ?? user.nome,
    );

    if (success && mounted) {
      _showSuccessSnackBar(AppConstants.topicChosenMessage);
      setState(() {
        _isAvailableExpanded = false;
      });
    } else if (mounted) {
      _showErrorSnackBar(
        topicsProvider.errorMessage ?? 'Erro ao escolher tema.',
      );
    }
  }

  Future<void> _handleUnchooseTopic(TopicModel topic) async {
    final topicsProvider = context.read<TopicsProvider>();
    final user = context.read<AuthProvider>().user;

    if (user == null) return;

    final success = await topicsProvider.unchooseTopic(topic.id, user.uid);

    if (success && mounted) {
      _showSuccessSnackBar(AppConstants.topicUnchosenMessage);
      setState(() {
        _isAvailableExpanded = true;
      });
    } else if (mounted) {
      _showErrorSnackBar(
        topicsProvider.errorMessage ?? 'Erro ao desmarcar tema.',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topicsProvider = context.watch<TopicsProvider>();
    final availableTopics = topicsProvider.availableTopics;
    final chosenTopics = topicsProvider.chosenTopics;
    final user = context.read<AuthProvider>().user;
    final userRole = user?.role ?? AppConstants.roleStudent;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Escolha de Temas')),
      body:
          topicsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: ExpansionPanelList(
                  elevation: 2,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isAvailableExpanded = !_isAvailableExpanded;
                    });
                  },
                  children: [
                    _buildExpansionPanel(
                      title: 'Temas Disponíveis (${availableTopics.length})',
                      isExpanded: _isAvailableExpanded,
                      topics: availableTopics,
                      isAvailable: true,
                      userRole: userRole,
                      user: user,
                    ),
                    _buildExpansionPanel(
                      title: 'Temas Escolhidos (${chosenTopics.length})',
                      isExpanded: !_isAvailableExpanded,
                      topics: chosenTopics,
                      isAvailable: false,
                      userRole: userRole,
                      user: user,
                    ),
                  ],
                ),
              ),
    );
  }

  ExpansionPanel _buildExpansionPanel({
    required String title,
    required bool isExpanded,
    required List<TopicModel> topics,
    required bool isAvailable,
    required String userRole,
    required dynamic user,
  }) {
    return ExpansionPanel(
      backgroundColor: AppConstants.cardColor,
      canTapOnHeader: true,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(title: Text(title, style: AppConstants.heading3));
      },
      body:
          topics.isEmpty
              ? const Padding(
                padding: EdgeInsets.all(AppConstants.paddingMedium),
                child: Text('Nenhum tema nesta categoria.'),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final canUnchoose =
                      userRole == AppConstants.roleStudent &&
                      topic.chosenByUid == user?.uid;

                  return ListTile(
                    title: Text(topic.titulo),
                    subtitle: Text(
                      isAvailable
                          ? topic.descricao
                          : 'Escolhido por: ${topic.chosenByNickname ?? 'N/A'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        userRole == AppConstants.roleStudent
                            ? (isAvailable
                                ? ElevatedButton(
                                  onPressed: () => _handleChooseTopic(topic),
                                  child: const Text('Escolher'),
                                )
                                : (canUnchoose
                                    ? OutlinedButton(
                                      onPressed:
                                          () => _handleUnchooseTopic(topic),
                                      child: const Text('Desmarcar'),
                                    )
                                    : null))
                            : null,
                  );
                },
              ),
      isExpanded: isExpanded,
    );
  }
}
