# Convertix - Gestor Web

Painel administrativo web da plataforma **Convertix**, desenvolvido em Flutter. Permite gerenciar usuários, clientes, sites e BioLinks por meio da API oficial da Convertix.

## Funcionalidades

- **Autenticação** — login com token JWT persistido localmente
- **Início** — dashboard de boas-vindas com dados do usuário logado
- **Usuários** *(admin)* — cadastro, edição e exclusão de usuários administradores
- **Clientes** *(admin)* — gestão de clientes da plataforma
- **Sites** *(admin)* — cadastro e manutenção de sites (BioLink, landing page, site comercial)
- **BioLinks** *(admin)* — gestão de BioLinks e seus itens (links, ícones, ordenação)
- **BioLink** *(cliente)* — acesso restrito para clientes com sites do tipo BioLink
- **Perfil** — alteração dos dados do usuário logado

O menu lateral exibe apenas as seções permitidas para o perfil autenticado (`ADMIN` ou `CLIENTE`).

## Stack

| Tecnologia | Uso |
|------------|-----|
| [Flutter](https://flutter.dev) | UI multiplataforma (foco em web) |
| [flutter_bloc](https://bloclibrary.dev) | Gerenciamento de estado (padrão BLoC) |
| [muller_package](../muller_package) | Pacote compartilhado (HTTP, componentes base, navegação) |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Persistência de token e sessão |
| [http](https://pub.dev/packages/http) | Requisições à API REST |

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatível com Dart `^3.11.5`
- Repositório [`muller_package`](../muller_package) clonado no mesmo diretório pai deste projeto:

```
projects/flutter/
├── muller_package/
└── web_gestor_site_covertix/
```

## Instalação

```bash
git clone <url-do-repositorio>
cd web_gestor_site_covertix
flutter pub get
```

Certifique-se de que o `muller_package` está acessível no caminho relativo configurado em `pubspec.yaml`:

```yaml
muller_package:
  path: ../muller_package
```

## Executando

### Web (desenvolvimento)

A API libera CORS apenas para as portas **3000**, **5173** e **8080**. Use uma delas:

```bash
flutter run -d chrome --web-port 3000
```

### Web (build de produção)

O front de produção deve ser servido em `https://gestor.convertix.net.br`.

```bash
flutter build web
```

Os arquivos gerados ficam em `build/web/`. Sirva essa pasta com qualquer servidor estático (Nginx, Apache, Firebase Hosting, etc.).

> Swagger da API não está disponível em produção. Use o ambiente local ou a documentação do repositório da API.

## API

A aplicação consome a API em produção:

- **Base:** `https://api.convertix.net.br`
- **Prefixo:** `/api/v1`

Os endpoints estão centralizados em `lib/app_config/const/app_endpoints.dart`.

## Perfis de acesso

| Perfil | Descrição |
|--------|-----------|
| `ADMIN` | Acesso completo: usuários, clientes, sites e BioLinks |
| `CLIENTE` | Acesso ao BioLink vinculado ao seu cadastro, quando possui site do tipo `BIOLINK` |

## Estrutura do projeto

```
lib/
├── main.dart                 # Entrada da aplicação
├── app_config/               # MaterialApp, auth, menu, endpoints, tema
├── models/                   # Modelos e enums (DTOs da API)
├── function/                 # Helpers e validadores
├── services/                 # Serviços HTTP compartilhados
├── pages/
│   ├── login_page/           # Tela de login
│   ├── menu.dart             # Shell pós-login (menu lateral)
│   ├── menu_admin/           # Features administrativas (BLoC por pasta)
│   └── perfil/               # Perfil do usuário
└── widgets/                  # Componentes visuais do app

assets/
├── images/                   # Logos e imagens da marca
└── json/                     # Assets estáticos

web/                          # index.html, favicon, manifest (PWA)
docs/                         # Documentação interna de arquitetura
```

Cada feature segue o padrão:

```
<feature>_page.dart      → UI e formulários
<feature>_bloc.dart      → Orquestração de estado
<feature>_event.dart     → Eventos do BLoC
<feature>_state.dart     → Estados do BLoC
<feature>_service.dart   → Chamadas HTTP
```

## Documentação interna

- [`docs/padronizacao-e-estrutura.md`](docs/padronizacao-e-estrutura.md) — convenções de código, pastas e uso do `muller_package`
- [`docs/estrutura-de-tela.md`](docs/estrutura-de-tela.md) — arquitetura de uma tela (camadas e responsabilidades)

## Testes

```bash
flutter test
```

## Licença

Projeto privado — uso interno Convertix.
