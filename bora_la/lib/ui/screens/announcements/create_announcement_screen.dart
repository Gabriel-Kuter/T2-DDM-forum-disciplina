import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/announcement_model.dart';
import '../../../core/providers/announcement_provider.dart';
import '../../../core/utils/constants.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel? announcementToEdit;

  const CreateAnnouncementScreen({super.key, this.announcementToEdit});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.announcementToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.announcementToEdit!.titulo;
      _bodyController.text = widget.announcementToEdit!.corpo;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<AnnouncementsProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateAnnouncement(
        id: widget.announcementToEdit!.id,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
    } else {
      success = await provider.createAnnouncement(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Ocorreu um erro inesperado.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Anúncio' : 'Novo Anúncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: AppConstants.getInputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título do anúncio',
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'O título é obrigatório.'
                            : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextFormField(
                controller: _bodyController,
                decoration: AppConstants.getInputDecoration(
                  labelText: 'Corpo do Anúncio',
                  hintText: 'Digite o conteúdo completo do anúncio',
                ),
                maxLines: 10,
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'O corpo do anúncio é obrigatório.'
                            : null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )
                        : Text(
                          _isEditing ? 'Salvar Alterações' : 'Publicar Anúncio',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
