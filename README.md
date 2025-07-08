# Fórum 65DDM (bora_la)

Um aplicativo Flutter para gerenciamento de workshops da disciplina de Desenvolvimento para Dispositivos Móveis (65DDM).

## Sobre o Projeto

O Fórum 65DDM é uma plataforma mobile desenvolvida em Flutter que permite aos alunos escolher temas para seus projetos finais e acompanhar avisos importantes da disciplina. O aplicativo oferece funcionalidades específicas para alunos e professores, com autenticação segura e dados em tempo real através do Firebase.

## Equipe

### Desenvolvedores
- **André Ludwig**
- **Gabriel Küter**
- **Vitor Gehrke**

### Professor Orientador
- **Prof. Mattheus da Hora França**

## Funcionalidades

### Para Alunos
- Cadastro e login com email institucional
- Visualização de avisos e comunicados
- Escolha de temas para projetos finais
- Sistema de comentários em avisos
- Edição de perfil (nickname e avatar)
- Visualização de temas disponíveis e escolhidos

### Para Professores
- Todas as funcionalidades de aluno
- Criação e edição de avisos
- Exclusão de avisos e comentários

### Recursos Técnicos
- Firebase Authentication
- Cloud Firestore para dados em tempo real
- Interface responsiva e Material Design 3
- Tema consistente com cores e tipografia personalizadas
- Gerenciamento de estado com Provider
- Atualizações em tempo real
- Validação de matrícula integrada

## Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento mobile
- **Firebase** - Backend como serviço
    - Authentication (autenticação por email)
    - Cloud Firestore (banco de dados NoSQL)
- **Provider** - Gerenciamento de estado

## Estrutura do Projeto

```
lib/
├── core/                          # Lógica central da aplicação
│   ├── models/                    # Modelos de dados
│   │   ├── announcement_model.dart
│   │   ├── comment_model.dart
│   │   ├── topic_model.dart
│   │   └── user_model.dart
│   ├── providers/                 # Gerenciamento de estado (ViewModels)
│   │   ├── announcement_provider.dart
│   │   ├── auth_provider.dart
│   │   └── topics_provider.dart
│   ├── services/                  # Serviços e APIs
│   │   ├── auth_service.dart
│   │   ├── auto_seed_service.dart
│   │   └── firestore_service.dart
│   └── utils/                     # Utilitários e constantes
│       └── constants.dart
├── ui/                           # Interface do usuário
│   ├── screens/                  # Telas da aplicação
│   │   ├── announcements/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── profile/
│   │   └── topics/
│   └── widgets/                  # Componentes reutilizáveis
└── main.dart                     # Ponto de entrada da aplicação
```

## Como Executar o Projeto

### Pré-requisitos

- Flutter SDK (versão 3.32.3 ou superior)
- Dart SDK
- Android Studio / VS Code
- Firebase CLI
- Flutterfire
- Git

### 1. Clone o Repositório

```bash
git clone https://github.com/Gabriel-Kuter/T2-DDM-forum-disciplina.git
cd T2-DDM-forum-disciplina/bora_la
```

### 2. Instale as Dependências

```bash
flutter pub get
```

### 3. Configuração do Firebase

#### 3.1. Crie um Projeto no Firebase

1. Acesse o [Console do Firebase](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Siga as instruções para criar seu projeto

#### 3.2. Ative os Serviços Necessários

**Authentication:**
1. No console, vá para "Authentication" → "Sign-in method"
2. Ative o provedor "Email/senha"

**Cloud Firestore:**
1. Vá para "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha "Iniciar no modo de teste" para desenvolvimento
4. Selecione uma localização próxima

#### 3.3. Configure o FlutterFire CLI

```bash
# Instale o FlutterFire CLI
dart pub global activate flutterfire_cli

# Execute a configuração automática
flutterfire configure
```

Selecione:
- Seu projeto Firebase
- Plataformas: Android e/ou iOS
- Confirme a configuração

Isso criará automaticamente o arquivo `firebase_options.dart` com as configurações do seu projeto.

#### 3.4. Regras do Firestore (Desenvolvimento)

No Console do Firebase, vá para "Firestore Database" → "Regras" e use:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================================================================
    // 🚨 REGRAS DE DESENVOLVIMENTO
    // ========================================================================
    // ATENÇÃO: Essas regras são PERMISSIVAS para permitir AutoSeedService
    // EM DESENVOLVIMENTO (SEM INTEGRAÇÃO REAL COM MATRÍCULAS):
    // 1. Comente as regras abaixo
    // 2. Descomente as regras de produção no final do arquivo
    // ========================================================================
    
    match /{document=**} {
      allow read, write: if true; // ⚠️ PERMISSIVO - APENAS PARA DEV!
    }
    
    // ========================================================================
    // 🛡️ REGRAS DE PRODUÇÃO
    // ========================================================================
    // Descomente essas regras quando for fazer deploy em produção
    // e comente a regra permissiva acima
    // ========================================================================
    
    // --- DADOS PÚBLICOS (SEED DATA) ---
    // match /enrollments/{doc} {
    //   allow read: if true;
    //   allow write: if false; // Só admin/seed pode criar
    // }
    
    // match /topics/{doc} {
    //   allow read: if true;
    //   allow write: if request.auth != null; // Só users logados podem escolher/desmarcar
    // }
    
    // match /announcements/{announcementId} {
    //   allow read: if true;
      
      // Permite a um professor criar ou atualizar um anúncio
      // allow write: if request.auth != null && 
                     // get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'professor';
      
      // Permite a um professor apagar um anúncio
      // allow delete: if request.auth != null && 
                      // get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'professor';

      // Subcoleção de comentários
      // match /comments/{commentId} {
        // allow read: if true; // Comentários podem ser lidos publicamente
        // allow create: if request.auth != null && 
                        // request.auth.uid == request.resource.data.authorUid;
        // allow update: if request.auth != null && 
                        // request.auth.uid == resource.data.authorUid;
        
        // Permite apagar se for o autor OU se for um professor
        // allow delete: if request.auth != null &&
                      // (request.auth.uid == resource.data.authorUid ||
                       // get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'professor');
      // }
    // }

    // --- DADOS PRIVADOS ---
    // match /users/{userId} {
    //   allow read, write: if request.auth != null && request.auth.uid == userId;
    // }

  }
}
```

> ⚠️ **Atenção:** Estas regras são para desenvolvimento. Para produção, implemente regras mais restritivas.

### 4. Execute o Aplicativo

```bash
# Para Android
flutter run

# Para iOS (apenas no macOS)
flutter run -d ios

# Para escolher o dispositivo
flutter devices
flutter run -d <device-id>
```

## Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.15.1
  cloud_firestore: ^5.6.11
  firebase_auth: ^5.6.2
  provider: ^6.1.5
  intl: ^0.20.2
```

## Arquitetura

O projeto segue uma arquitetura baseada no padrão **MVVM** adaptado para Flutter:

- **Model**: Classes de dados (`core/models/`)
- **View**: Widgets e telas (`ui/`)
- **ViewModel**: Providers com ChangeNotifier (`core/providers/`)

### Fluxo de Dados

1. **View** escuta mudanças nos **Providers**
2. **Provider** contém lógica de negócio e estado
3. **Services** fazem comunicação com Firebase
4. **Models** definem estrutura dos dados

## Usuários de Teste

O aplicativo possui um sistema de seed automático que cria usuários de teste:

### Alunos
| Nome | CPF | Senha |
|------|-----|--------|
| André Ludwig | 12345678901 | Definida no cadastro |
| Gabriel Küter | 98765432101 | Definida no cadastro |
| Vitor Gehrke | 12312312301 | Definida no cadastro |
| João Vitor | 05612345699 | Definida no cadastro |

### Professor
| Nome | CPF | Senha |
|------|-----|--------|
| Prof. Mattheus da Hora França | 12312312399 | Definida no cadastro |

> **Nota:** Para fazer login, primeiro faça o cadastro usando o CPF e email correspondentes.