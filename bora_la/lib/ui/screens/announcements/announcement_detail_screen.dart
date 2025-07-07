import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/providers/announcement_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';
import 'create_announcement_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen>
    with SingleTickerProviderStateMixin {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementsProvider>().loadCommentsForAnnouncement(
        widget.announcement.id,
      );
    });

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationMedium,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
      if (_isFabMenuOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  Future<void> _handleAddComment() async {
    if (_commentController.text.trim().isEmpty) return;
    final announcementsProvider = context.read<AnnouncementsProvider>();
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final success = await announcementsProvider.addComment(
      announcementId: widget.announcement.id,
      text: _commentController.text.trim(),
      authorUid: user.uid,
      authorNickname: user.nickname ?? user.nome,
    );

    if (success) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AppConstants.animationMedium,
            curve: Curves.easeOut,
          );
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            announcementsProvider.errorMessage ?? 'Erro ao enviar comentário.',
          ),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _showDeleteCommentDialog(CommentModel comment) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Apagar Comentário'),
            content: const Text(
              'Tem a certeza de que deseja apagar este comentário?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text('Apagar'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _handleDeleteComment(comment.id);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _handleDeleteComment(String commentId) async {
    final provider = context.read<AnnouncementsProvider>();
    final success = await provider.deleteComment(
      announcementId: widget.announcement.id,
      commentId: commentId,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erro ao apagar comentário.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _showDeleteAnnouncementDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Apagar Anúncio'),
            content: const Text(
              'Tem a certeza de que deseja apagar este anúncio e todos os seus comentários? Esta ação é irreversível.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: const Text(
                  'Apagar',
                  style: TextStyle(color: AppConstants.errorColor),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final provider = context.read<AnnouncementsProvider>();
                  final success = await provider.deleteAnnouncement(
                    widget.announcement.id,
                  );
                  if (success && mounted) {
                    Navigator.of(context).pop();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.errorMessage ?? 'Erro ao apagar anúncio.',
                        ),
                        backgroundColor: AppConstants.errorColor,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcementsProvider = context.watch<AnnouncementsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final comments = announcementsProvider.getCommentsForAnnouncement(
      widget.announcement.id,
    );
    final currentUser = authProvider.user;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.announcement.titulo,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.paddingLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.announcement.titulo,
                              style: AppConstants.heading2,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              'Publicado em: ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(widget.announcement.dataCriacao.toDate())}',
                              style: AppConstants.caption,
                            ),
                            const Divider(height: AppConstants.paddingLarge),
                            Text(
                              widget.announcement.corpo,
                              style: AppConstants.bodyText.copyWith(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.paddingLarge,
                          0,
                          AppConstants.paddingLarge,
                          AppConstants.paddingSmall,
                        ),
                        child: Text(
                          'Comentários (${comments.length})',
                          style: AppConstants.heading3,
                        ),
                      ),
                    ),
                    comments.isEmpty
                        ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.paddingLarge),
                            child: Center(
                              child: Text('Seja o primeiro a comentar!'),
                            ),
                          ),
                        )
                        : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final comment = comments[index];
                            final canDelete =
                                currentUser != null &&
                                (currentUser.role ==
                                        AppConstants.roleProfessor ||
                                    comment.authorUid == currentUser.uid);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppConstants.primaryColor
                                    .withOpacity(0.2),
                                child: Text(
                                  comment.authorNickname
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                              title: Text(
                                comment.authorNickname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(comment.text),
                              trailing:
                                  canDelete
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppConstants.errorColor,
                                        ),
                                        tooltip: 'Apagar comentário',
                                        onPressed:
                                            () => _showDeleteCommentDialog(
                                              comment,
                                            ),
                                      )
                                      : null,
                            );
                          }, childCount: comments.length),
                        ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
              _buildCommentInputField(),
            ],
          ),

          if (currentUser?.role == AppConstants.roleProfessor)
            Positioned(bottom: 120, right: 16, child: _buildSpeedDialFab()),
        ],
      ),
    );
  }

  Widget _buildSpeedDialFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabMenuOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton.small(
              heroTag: 'delete_announcement',
              onPressed: () {
                _toggleFabMenu();
                _showDeleteAnnouncementDialog();
              },
              backgroundColor: AppConstants.errorColor,
              tooltip: 'Apagar Anúncio',
              child: const Icon(Icons.delete_forever),
            ),
          ),
        if (_isFabMenuOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton.small(
              heroTag: 'edit_announcement',
              onPressed: () {
                _toggleFabMenu();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => CreateAnnouncementScreen(
                          announcementToEdit: widget.announcement,
                        ),
                  ),
                );
              },
              backgroundColor: AppConstants.warningColor,
              tooltip: 'Editar Anúncio',
              child: const Icon(Icons.edit),
            ),
          ),

        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggleFabMenu,
          backgroundColor: AppConstants.primaryColor,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _fabAnimation,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInputField() {
    return Material(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        color: AppConstants.cardColor,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: AppConstants.getInputDecoration(
                    labelText: AppConstants.commentLabelText,
                    hintText: AppConstants.commentHintText,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onTap: () {
                    if (_isFabMenuOpen) {
                      _toggleFabMenu();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              IconButton(
                icon: const Icon(Icons.send),
                color: AppConstants.primaryColor,
                onPressed: _handleAddComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
