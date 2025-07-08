import 'package:cloud_firestore/cloud_firestore.dart';

class AutoSeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> ensureInitialData() async {
    try {
      await _ensureEnrollmentsExist();
      await _ensureTopicsExist();
      await _ensureAnnouncementsExist();
    } catch (e) {
      print('Aviso: Não foi possível verificar os dados iniciais: $e');
    }
  }

  Future<void> _ensureEnrollmentsExist() async {
    final enrollmentsSnapshot =
        await _db.collection('enrollments').limit(1).get();

    if (enrollmentsSnapshot.docs.isEmpty) {
      print('Sem matrículas encontradas, criando matrículas iniciais...');
      await _seedEnrollments();
    }
  }

  Future<void> _ensureTopicsExist() async {
    final topicsSnapshot = await _db.collection('topics').limit(1).get();

    if (topicsSnapshot.docs.isEmpty) {
      print('Sem temas encontrados, criando temas iniciais...');
      await _seedTopics();
    }
  }

  Future<void> _ensureAnnouncementsExist() async {
    final announcementsSnapshot =
        await _db.collection('announcements').limit(1).get();

    if (announcementsSnapshot.docs.isEmpty) {
      print('Sem anúncios encontrados, criando anúncios iniciais...');
      await _seedAnnouncements();
    }
  }

  Future<void> _seedEnrollments() async {
    final enrollments = [
      {
        'cpf': '12345678901',
        'nome': 'André Ludwig',
        'email': 'andre@edu.udesc.br',
        'role': 'aluno',
        'curso': 'Engenharia de Software',
        'ativo': true,
      },
      {
        'cpf': '98765432101',
        'nome': 'Gabriel Küter',
        'email': 'gabriel@edu.udesc.br',
        'role': 'aluno',
        'curso': 'Engenharia de Software',
        'ativo': true,
      },
      {
        'cpf': '12312312301',
        'nome': 'Vitor Gehrke',
        'email': 'vitor@edu.udesc.br',
        'role': 'aluno',
        'curso': 'Engenharia de Software',
        'ativo': true,
      },
      {
        'cpf': '12312312399',
        'nome': 'Prof. Mattheus da Hora França',
        'email': 'dahora@udesc.br',
        'role': 'professor',
        'departamento': 'Engenharia de Software',
        'ativo': true,
      },
      {
        'cpf': '05612345699',
        'nome': 'João Vitor',
        'email': 'joaojoao@edu.udesc.br',
        'role': 'aluno',
        'curso': 'Engenharia de Software',
        'ativo': true,
      },
    ];

    final batch = _db.batch();
    for (final enrollmentData in enrollments) {
      final docRef = _db
          .collection('enrollments')
          .doc(enrollmentData['cpf'] as String);
      batch.set(docRef, enrollmentData);
    }
    await batch.commit();
    print('Matrículas iniciais criadas com sucesso');
  }

  Future<void> _seedTopics() async {
    final topics = [
      {
        'titulo': 'Desenvolvimento de App Mobile',
        'descricao':
            'Criar um aplicativo mobile completo usando Flutter para gerenciamento de tarefas pessoais.',
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      },
      {
        'titulo': 'Sistema Mobile de E-commerce',
        'descricao':
            'Desenvolver uma plataforma mobile de vendas online com carrinho de compras e pagamento integrado.',
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      },
      {
        'titulo': 'API REST',
        'descricao':
            'Construir uma API REST completa para gerenciamento de usuários e autenticação.',
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      },
      {
        'titulo': 'Dashboard Analytics',
        'descricao':
            'Criar um dashboard interativo para visualização de dados e métricas em tempo real.',
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      },
      {
        'titulo': 'Chat em Tempo Real',
        'descricao':
            'Desenvolver um sistema de chat em tempo real usando WebSockets ou Firebase.',
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      },
      {
        'titulo': 'Sistema de Gestão Escolar',
        'descricao':
            'Plataforma para gerenciar alunos, professores, notas e frequência escolar.',
        'isChosen': false,
        'chosenByUid': null,
        'chosenByNickname': null,
      },
    ];

    final batch = _db.batch();
    for (final topicData in topics) {
      final docRef = _db.collection('topics').doc();
      batch.set(docRef, topicData);
    }
    await batch.commit();
    print('Temas iniciais criados com sucesso');
  }

  Future<void> _seedAnnouncements() async {
    final announcements = [
      {
        'titulo': 'Bem-vindos ao Fórum 65DDM!',
        'corpo': '''Olá pessoal!

Sejam bem-vindos ao nosso fórum da disciplina de Desenvolvimento para Dispositivos Móveis.

Este espaço foi criado para:
- Escolha de temas para projetos finais
- Avisos importantes da disciplina
- Discussões sobre os trabalhos

Lembrem-se de escolher seus temas com cuidado - cada tema só pode ser escolhido por um aluno!

Bons estudos!
Prof. Mattheus''',
        'dataCriacao': Timestamp.now(),
      },
      {
        'titulo': 'Prazo para Escolha de Temas',
        'corpo': '''ATENÇÃO - PRAZO IMPORTANTE

O prazo para escolha dos temas dos projetos finais é até o dia 15 de agosto.

Não deixem para a última hora!''',
        'dataCriacao': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 2)),
        ),
      },
      {
        'titulo': 'Critérios de Avaliação',
        'corpo': '''CRITÉRIOS DE AVALIAÇÃO

Os trabalhos finais serão avaliados com base em:

1. **Funcionalidade** (30%)
2. **Qualidade do Código** (25%)  
3. **Interface do Usuário** (25%)
4. **Apresentação** (20%)

Boa sorte a todos!''',
        'dataCriacao': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 5)),
        ),
      },
    ];

    final batch = _db.batch();
    for (final announcementData in announcements) {
      final docRef = _db.collection('announcements').doc();
      batch.set(docRef, announcementData);
    }
    await batch.commit();
    print('Anúncios iniciais criados com sucesso');
  }
}
