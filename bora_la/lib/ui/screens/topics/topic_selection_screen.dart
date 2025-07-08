import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/topic_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/topics_provider.dart';
import '../../../core/utils/constants.dart';

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

    final success = await topicsProvider.unchooseTopic(topic.id, user.uid, user.role);

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

  Future<void> _handleDeleteTopic(String topicId) async {
    final topicsProvider = context.read<TopicsProvider>();
    final success = await topicsProvider.deleteTopic(topicId);

    if (success && mounted) {
      _showSuccessSnackBar('Tema apagado com sucesso!');
    } else if (mounted) {
      _showErrorSnackBar(topicsProvider.errorMessage ?? 'Erro ao apagar tema.');
    }
  }

  void _showAddTopicDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Tema'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (value) =>
                  value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) =>
                  value!.isEmpty ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final topicsProvider = context.read<TopicsProvider>();
                  final success = await topicsProvider.addTopic(
                    titleController.text,
                    descriptionController.text,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    if (success) {
                      _showSuccessSnackBar('Tema adicionado com sucesso!');
                    } else {
                      _showErrorSnackBar(topicsProvider.errorMessage ?? 'Erro ao criar tema.');
                    }
                  }
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
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
    final user = context.watch<AuthProvider>().user;
    final isProfessor = user?.role == AppConstants.roleProfessor;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Escolha de Temas')),
      body: topicsProvider.isLoading && topicsProvider.topics.isEmpty
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
              user: user,
            ),
            _buildExpansionPanel(
              title: 'Temas Escolhidos (${chosenTopics.length})',
              isExpanded: !_isAvailableExpanded,
              topics: chosenTopics,
              isAvailable: false,
              user: user,
            ),
          ],
        ),
      ),
      floatingActionButton: isProfessor
          ? FloatingActionButton(
        onPressed: _showAddTopicDialog,
        tooltip: 'Adicionar Tema',
        backgroundColor: AppConstants.accentColor,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  ExpansionPanel _buildExpansionPanel({
    required String title,
    required bool isExpanded,
    required List<TopicModel> topics,
    required bool isAvailable,
    required UserModel? user,
  }) {
    final isProfessor = user?.role == AppConstants.roleProfessor;

    return ExpansionPanel(
      backgroundColor: AppConstants.cardColor,
      canTapOnHeader: true,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(title: Text(title, style: AppConstants.heading3));
      },
      body: topics.isEmpty
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
          final canUnchoose = topic.chosenByUid == user?.uid;

          return ListTile(
            title: Text(topic.titulo),
            subtitle: Text(
              isAvailable
                  ? topic.descricao
                  : 'Escolhido por: ${topic.chosenByNickname ?? 'N/A'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: _buildTrailingWidget(
                isProfessor, isAvailable, canUnchoose, topic),
          );
        },
      ),
      isExpanded: isExpanded,
    );
  }

  Widget? _buildTrailingWidget(bool isProfessor, bool isAvailable,
      bool canUnchoose, TopicModel topic) {
    if (isProfessor) {
      if (isAvailable) {
        return IconButton(
          icon: const Icon(Icons.delete_outline, color: AppConstants.errorColor),
          tooltip: 'Apagar Tema',
          onPressed: () => _handleDeleteTopic(topic.id),
        );
      }
      return OutlinedButton(
        onPressed: () => _handleUnchooseTopic(topic),
        child: const Text('Liberar'),
      );
    } else { // Aluno
      if (isAvailable) {
        return ElevatedButton(
          onPressed: () => _handleChooseTopic(topic),
          child: const Text('Escolher'),
        );
      } else if (canUnchoose) {
        return OutlinedButton(
          onPressed: () => _handleUnchooseTopic(topic),
          child: const Text('Desmarcar'),
        );
      }
    }
    return null;
  }
}