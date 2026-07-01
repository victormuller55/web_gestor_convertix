# API Gestor — Documentação para Frontend Flutter

Documentação das APIs REST do backend **Gestor** (Convertix) para implementação no app Flutter.

---

## Índice

1. [Configuração geral](#1-configuração-geral)
2. [Autenticação e autorização](#2-autenticação-e-autorização)
3. [Tratamento de erros](#3-tratamento-de-erros)
4. [Enums](#4-enums)
5. [Endpoints](#5-endpoints)
   - [Auth](#51-auth)
   - [Usuários](#52-usuários-admin)
   - [Clientes](#53-clientes-admin)
   - [Sites](#54-sites)
   - [BioLinks](#55-biolinks)
   - [Itens de BioLink](#56-itens-de-biolink)
6. [Modelos Dart sugeridos](#6-modelos-dart-sugeridos)
7. [Implementação Flutter](#7-implementação-flutter)
8. [Fluxos de tela sugeridos](#8-fluxos-de-tela-sugeridos)

---

## 1. Configuração geral

| Item | Valor |
|------|-------|
| **Base URL (dev)** | `http://localhost:8080` |
| **Prefixo da API** | `/api/v1` |
| **Content-Type** | `application/json` |
| **Convenção JSON** | `snake_case` em todos os campos |
| **Swagger UI** | `http://localhost:8080/swagger-ui.html` |
| **OpenAPI JSON** | `http://localhost:8080/v3/api-docs` |

> **Importante:** O backend serializa/deserializa JSON em **snake_case** (`cliente_id`, `nome_empresa`, `created_at`, etc.). Configure o `json_serializable` ou equivalente com `@JsonKey(name: 'cliente_id')` ou use `fieldRename: FieldRename.snake`.

### Formato de datas

Campos `created_at` e `updated_at` são `LocalDateTime` no formato ISO-8601:

```
2026-06-27T14:30:00
```

No Flutter, use `DateTime.parse()` ou configure `@JsonKey` com conversor customizado.

---

## 2. Autenticação e autorização

### Login

O endpoint `POST /api/v1/auth/login` é **público** (não exige token).

Após o login bem-sucedido, armazene o campo `token` retornado e envie em todas as demais requisições:

```
Authorization: Bearer <token>
```

### Expiração do token

O JWT expira à **meia-noite do dia seguinte** (timezone `America/Sao_Paulo`). Ao receber `401 Unauthorized`, redirecione o usuário para a tela de login.

### Tipos de usuário

| Tipo | Descrição |
|------|-----------|
| `ADMIN` | Acesso total. Gerencia usuários admin e clientes. Vê todos os sites e biolinks. |
| `CLIENTE` | Acesso autenticado apenas aos recursos da própria empresa (`cliente_id`). |

### Matriz de permissões por endpoint

| Recurso | Público | ADMIN | CLIENTE |
|---------|---------|-------|---------|
| `/api/v1/auth/**` | ✅ | ✅ | ✅ |
| `/api/v1/usuarios/**` | ❌ | ✅ | ❌ |
| `/api/v1/clientes/**` | ❌ | ✅ | ❌ |
| `/api/v1/sites/**` | ❌ | ✅ | ✅ (somente seus sites) |
| `/api/v1/biolinks/**` | ❌ | ✅ | ✅ (somente seus biolinks) |
| `/api/v1/biolinks/itens/**` | ❌ | ✅ | ✅ (somente seus itens) |

### Regras para usuário CLIENTE

- Ao listar sites/biolinks, o backend filtra automaticamente pelo `cliente_id` do token.
- Ao criar ou alterar um site, o `cliente_id` informado no body é **ignorado** e substituído pelo `cliente_id` do usuário logado.
- Tentativa de acessar recurso de outro cliente retorna `403 Forbidden`.

---

## 3. Tratamento de erros

Todas as respostas de erro seguem o mesmo formato:

```json
{
  "timestamp": "2026-06-27T14:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "CNPJ inválido",
  "errors": null
}
```

Em erros de validação (`400`), o campo `errors` contém um mapa campo → mensagem:

```json
{
  "timestamp": "2026-06-27T14:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Erro de validação",
  "errors": {
    "email": "Email inválido",
    "senha": "A senha é obrigatória"
  }
}
```

> **Nota:** As chaves em `errors` usam o nome do campo Java (camelCase), ex.: `nomeEmpresa`, não `nome_empresa`.

### Códigos HTTP

| Status | Situação |
|--------|----------|
| `200` | Sucesso (GET, PUT) |
| `201` | Criado (POST) |
| `204` | Excluído com sucesso (DELETE, sem body) |
| `400` | Regra de negócio ou validação |
| `401` | Token inválido/ausente ou credenciais incorretas |
| `403` | Sem permissão para o recurso |
| `404` | Recurso não encontrado |

---

## 4. Enums

### TipoUsuario

```
ADMIN
CLIENTE
```

### TipoSite

```
BIOLINK
LANDING_PAGE
SITE_COMERCIAL
```

### StatusSite

```
ATIVO
INATIVO
EM_DESENVOLVIMENTO
```

---

## 5. Endpoints

---

### 5.1 Auth

#### POST `/api/v1/auth/login`

Autentica o usuário e retorna o JWT.

**Autenticação:** não requerida

**Request body:**

```json
{
  "email": "admin@convertix.net",
  "senha": "senha123"
}
```

| Campo | Tipo | Obrigatório | Validação |
|-------|------|-------------|-----------|
| `email` | string | sim | email válido |
| `senha` | string | sim | não vazio |

**Response `200`:**

```json
{
  "id": 1,
  "nome": "Administrador",
  "email": "admin@convertix.net",
  "tipo": "ADMIN",
  "ativo": true,
  "cliente_id": null,
  "nome_empresa": null,
  "cnpj": null,
  "telefone": null,
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "created_at": "2026-01-01T10:00:00",
  "updated_at": "2026-01-01T10:00:00"
}
```

Para usuário `CLIENTE`, os campos `cliente_id`, `nome_empresa`, `cnpj` e `telefone` são preenchidos.

**Erros comuns:**

| Status | message |
|--------|---------|
| `401` | Email ou senha inválidos |
| `401` | Usuário inativo |
| `400` | Usuário cliente sem empresa vinculada |

---

### 5.2 Usuários (ADMIN)

> Requer role `ADMIN`.

#### GET `/api/v1/usuarios`

Lista usuários admin com filtros opcionais.

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | long | não | Filtrar por ID |
| `query` | string | não | Busca parcial por nome ou email |
| `ativo` | boolean | não | Filtrar por status ativo |

**Response `200`:** array de `UsuarioResponse`

```json
[
  {
    "id": 1,
    "nome": "Administrador",
    "email": "admin@convertix.net",
    "ativo": true,
    "tipo": "ADMIN",
    "created_at": "2026-01-01T10:00:00",
    "updated_at": "2026-01-01T10:00:00"
  }
]
```

---

#### POST `/api/v1/usuarios/novo`

Cadastra um novo usuário **admin**.

**Request body:**

```json
{
  "nome": "Novo Admin",
  "email": "novo@convertix.net",
  "senha": "senha123",
  "ativo": true
}
```

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| `nome` | string | sim |
| `email` | string | sim |
| `senha` | string | sim |
| `ativo` | boolean | sim |

**Response `201`:** `UsuarioResponse`

---

#### PUT `/api/v1/usuarios/alterar-dados?id={id}`

Altera dados de um usuário admin.

**Query params:** `id` (obrigatório)

**Request body:** mesmo formato do POST

> A senha é sempre atualizada quando informada no body.

**Response `200`:** `UsuarioResponse`

**Erros:**

| Status | message |
|--------|---------|
| `400` | Usuários cliente devem ser alterados pelo cadastro de cliente |

---

#### DELETE `/api/v1/usuarios/apagar?id={id}`

**Query params:** `id` (obrigatório)

**Response `204`:** sem body

**Erros:**

| Status | message |
|--------|---------|
| `400` | Usuários cliente devem ser excluídos pelo cadastro de cliente |
| `400` | Não é possível excluir um usuário vinculado a um cliente |

---

### 5.3 Clientes (ADMIN)

> Requer role `ADMIN`.

#### GET `/api/v1/clientes`

Lista clientes com filtros opcionais.

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | long | não | Filtrar por ID |
| `query` | string | não | Busca parcial por nome da empresa, CNPJ, email ou telefone |

**Response `200`:** array de `ClienteResponse`

```json
[
  {
    "id": 1,
    "nome_empresa": "Empresa Exemplo LTDA",
    "cnpj": "12345678000199",
    "email": "contato@empresa.com",
    "telefone": "11999999999",
    "created_at": "2026-01-01T10:00:00",
    "updated_at": "2026-01-01T10:00:00"
  }
]
```

---

#### POST `/api/v1/clientes/novo`

Cadastra cliente e cria automaticamente um usuário do tipo `CLIENTE` vinculado.

**Request body:**

```json
{
  "nome_empresa": "Empresa Exemplo LTDA",
  "cnpj": "12.345.678/0001-99",
  "email": "contato@empresa.com",
  "senha": "senha123",
  "telefone": "11999999999"
}
```

| Campo | Tipo | Obrigatório | Observação |
|-------|------|-------------|------------|
| `nome_empresa` | string | sim | |
| `cnpj` | string | sim | Validado e normalizado (apenas dígitos) |
| `email` | string | sim | Único no sistema |
| `senha` | string | sim | |
| `telefone` | string | não | |

**Response `201`:** `ClienteResponse`

**Erros:**

| Status | message |
|--------|---------|
| `400` | CNPJ inválido |
| `400` | Já existe um usuário com o email: ... |
| `400` | Já existe um cliente com o CNPJ: ... |

---

#### PUT `/api/v1/clientes/alterar-dados?id={id}`

**Query params:** `id` (obrigatório)

**Request body:** mesmo formato do POST

> Se `senha` for enviada em branco ou omitida, a senha atual é mantida.

**Response `200`:** `ClienteResponse`

---

#### DELETE `/api/v1/clientes/apagar?id={id}`

Exclui o cliente e o usuário vinculado.

**Query params:** `id` (obrigatório)

**Response `204`:** sem body

---

### 5.4 Sites

> Requer autenticação. ADMIN vê todos; CLIENTE vê apenas os seus.

#### GET `/api/v1/sites`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | long | não | Filtrar por ID |
| `query` | string | não | Busca parcial por nome, domínio ou subdomínio |

**Response `200`:** array de `SiteResponse`

```json
[
  {
    "id": 1,
    "cliente_id": 1,
    "cliente_nome_empresa": "Empresa Exemplo LTDA",
    "nome": "Meu BioLink",
    "tipo": "BIOLINK",
    "dominio": null,
    "subdominio": "minhaempresa",
    "status": "ATIVO",
    "created_at": "2026-01-01T10:00:00",
    "updated_at": "2026-01-01T10:00:00"
  }
]
```

---

#### POST `/api/v1/sites/novo`

**Request body:**

```json
{
  "cliente_id": 1,
  "nome": "Meu BioLink",
  "tipo": "BIOLINK",
  "dominio": null,
  "subdominio": "minhaempresa",
  "status": "ATIVO"
}
```

| Campo | Tipo | Obrigatório | Observação |
|-------|------|-------------|------------|
| `cliente_id` | long | sim | Ignorado para CLIENTE (usa o do token) |
| `nome` | string | sim | |
| `tipo` | TipoSite | sim | |
| `dominio` | string | não | |
| `subdominio` | string | não | Deve ser único se informado |
| `status` | StatusSite | sim | |

**Response `201`:** `SiteResponse`

**Erros:**

| Status | message |
|--------|---------|
| `400` | Já existe um site com o subdomínio: ... |
| `404` | Cliente não encontrado com id: ... |

---

#### PUT `/api/v1/sites/alterar-dados?id={id}`

**Query params:** `id` (obrigatório)

**Request body:** mesmo formato do POST

**Response `200`:** `SiteResponse`

---

#### DELETE `/api/v1/sites/apagar?id={id}`

**Query params:** `id` (obrigatório)

**Response `204`:** sem body

---

### 5.5 BioLinks

> Requer autenticação. Um site do tipo `BIOLINK` pode ter **apenas um** BioLink vinculado.

#### GET `/api/v1/biolinks`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `id` | long | não | Filtrar por ID |

**Response `200`:** array de `BioLinkResponse`

```json
[
  {
    "id": 1,
    "site_id": 1,
    "site_nome": "Meu BioLink",
    "nome_usuario": "minhaempresa",
    "descricao": "Links oficiais",
    "foto_perfil": "https://exemplo.com/foto.jpg",
    "created_at": "2026-01-01T10:00:00",
    "updated_at": "2026-01-01T10:00:00"
  }
]
```

---

#### POST `/api/v1/biolinks/novo`

**Request body:**

```json
{
  "site_id": 1,
  "nome_usuario": "minhaempresa",
  "descricao": "Links oficiais",
  "foto_perfil": "https://exemplo.com/foto.jpg"
}
```

| Campo | Tipo | Obrigatório | Observação |
|-------|------|-------------|------------|
| `site_id` | long | sim | Site deve ser do tipo `BIOLINK` |
| `nome_usuario` | string | sim | |
| `descricao` | string | não | |
| `foto_perfil` | string | não | URL da imagem |

**Response `201`:** `BioLinkResponse`

**Erros:**

| Status | message |
|--------|---------|
| `400` | O site informado não é do tipo BIOLINK |
| `400` | Já existe um BioLink vinculado ao site: ... |

---

#### PUT `/api/v1/biolinks/alterar-dados?id={id}`

**Query params:** `id` (obrigatório)

**Request body:** mesmo formato do POST

**Response `200`:** `BioLinkResponse`

---

#### DELETE `/api/v1/biolinks/apagar?id={id}`

**Query params:** `id` (obrigatório)

**Response `204`:** sem body

---

### 5.6 Itens de BioLink

> Requer autenticação. Itens pertencem a um BioLink específico.

#### GET `/api/v1/biolinks/itens`

**Query params:**

| Param | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `biolink_id` | long | **sim** | ID do BioLink pai |
| `id` | long | não | Se informado, retorna um único item; senão, lista todos |

**Response `200`:**

- Com `id`: objeto `BioLinkItemResponse`
- Sem `id`: array de `BioLinkItemResponse` (ordenados por `ordem`)

```json
[
  {
    "id": 1,
    "biolink_id": 1,
    "titulo": "Instagram",
    "url": "https://instagram.com/minhaempresa",
    "icone": "instagram",
    "ordem": 1,
    "ativo": true,
    "created_at": "2026-01-01T10:00:00",
    "updated_at": "2026-01-01T10:00:00"
  }
]
```

---

#### POST `/api/v1/biolinks/itens/novo`

**Request body:**

```json
{
  "biolink_id": 1,
  "titulo": "Instagram",
  "url": "https://instagram.com/minhaempresa",
  "icone": "instagram",
  "ordem": 1,
  "ativo": true
}
```

| Campo | Tipo | Obrigatório |
|-------|------|-------------|
| `biolink_id` | long | sim |
| `titulo` | string | sim |
| `url` | string | sim |
| `icone` | string | não |
| `ordem` | int | sim |
| `ativo` | boolean | sim |

**Response `201`:** `BioLinkItemResponse`

---

#### PUT `/api/v1/biolinks/itens/alterar-dados?biolink_id={biolinkId}&id={id}`

**Query params:** `biolink_id` e `id` (obrigatórios)

**Request body:** mesmo formato do POST (`biolink_id` no body é opcional na atualização)

**Response `200`:** `BioLinkItemResponse`

---

#### DELETE `/api/v1/biolinks/itens/apagar?biolink_id={biolinkId}&id={id}`

**Query params:** `biolink_id` e `id` (obrigatórios)

**Response `204`:** sem body

---

## 6. Modelos Dart sugeridos

Exemplo de modelos com `json_serializable`:

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class LoginRequest {
  final String email;
  final String senha;

  LoginRequest({required this.email, required this.senha});

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponse {
  final int id;
  final String nome;
  final String email;
  final String tipo; // ADMIN | CLIENTE
  final bool ativo;
  final int? clienteId;
  final String? nomeEmpresa;
  final String? cnpj;
  final String? telefone;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoginResponse({/* ... */});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ErrorResponse {
  final DateTime timestamp;
  final int status;
  final String error;
  final String message;
  final Map<String, String>? errors;

  ErrorResponse({/* ... */});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
}
```

Replique o mesmo padrão para: `ClienteRequest/Response`, `SiteRequest/Response`, `BioLinkRequest/Response`, `BioLinkItemRequest/Response`, `UsuarioRequest/Response`.

---

## 7. Implementação Flutter

### Dependências recomendadas

```yaml
dependencies:
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  json_annotation: ^4.9.0

dev_dependencies:
  json_serializable: ^6.8.0
  build_runner: ^2.4.0
```

### Cliente HTTP com interceptor JWT

```dart
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _storage = const FlutterSecureStorage() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
          // Navegar para login via AuthNotifier / GoRouter redirect
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
```

### Serviços por recurso

Organize em camadas:

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   └── api_exception.dart
│   └── auth/
│       └── auth_storage.dart
├── models/
│   ├── login_request.dart
│   ├── login_response.dart
│   └── ...
└── services/
    ├── auth_service.dart
    ├── cliente_service.dart
    ├── site_service.dart
    ├── biolink_service.dart
    └── biolink_item_service.dart
```

### Exemplo: AuthService

```dart
class AuthService {
  final ApiClient _client;
  final AuthStorage _storage;

  AuthService(this._client, this._storage);

  Future<LoginResponse> login(String email, String senha) async {
    final response = await _client.dio.post(
      '/api/v1/auth/login',
      data: LoginRequest(email: email, senha: senha).toJson(),
    );
    final loginResponse = LoginResponse.fromJson(response.data);
    await _storage.saveToken(loginResponse.token);
    await _storage.saveUser(loginResponse);
    return loginResponse;
  }

  Future<void> logout() => _storage.clear();
}
```

### Exemplo: SiteService

```dart
class SiteService {
  final ApiClient _client;

  SiteService(this._client);

  Future<List<SiteResponse>> listar({int? id, String? query}) async {
    final response = await _client.dio.get(
      '/api/v1/sites',
      queryParameters: {
        if (id != null) 'id': id,
        if (query != null && query.isNotEmpty) 'query': query,
      },
    );
    return (response.data as List)
        .map((e) => SiteResponse.fromJson(e))
        .toList();
  }

  Future<SiteResponse> criar(SiteRequest request) async {
    final response = await _client.dio.post(
      '/api/v1/sites/novo',
      data: request.toJson(),
    );
    return SiteResponse.fromJson(response.data);
  }

  Future<SiteResponse> atualizar(int id, SiteRequest request) async {
    final response = await _client.dio.put(
      '/api/v1/sites/alterar-dados',
      queryParameters: {'id': id},
      data: request.toJson(),
    );
    return SiteResponse.fromJson(response.data);
  }

  Future<void> excluir(int id) async {
    await _client.dio.delete(
      '/api/v1/sites/apagar',
      queryParameters: {'id': id},
    );
  }
}
```

### Tratamento de erros no Flutter

```dart
class ApiException implements Exception {
  final int status;
  final String message;
  final Map<String, String>? fieldErrors;

  ApiException({
    required this.status,
    required this.message,
    this.fieldErrors,
  });

  factory ApiException.fromDio(DioException e) {
    if (e.response?.data != null) {
      final error = ErrorResponse.fromJson(e.response!.data);
      return ApiException(
        status: error.status,
        message: error.message,
        fieldErrors: error.errors,
      );
    }
    return ApiException(status: 0, message: 'Erro de conexão');
  }
}
```

---

## 8. Fluxos de tela sugeridos

### ADMIN

```
Login
 ├── Usuários (CRUD)
 ├── Clientes (CRUD)
 ├── Sites (CRUD — seleciona cliente)
 │    └── BioLinks (CRUD — site tipo BIOLINK)
 │         └── Itens (CRUD — links do biolink)
 └── Logout
```

### CLIENTE

```
Login
 ├── Meus Sites (listar/criar/editar/excluir)
 │    └── BioLink (criar/editar se site for BIOLINK)
 │         └── Itens (CRUD — gerenciar links)
 └── Logout
```

### Ordem de criação recomendada

1. **Cliente** (ADMIN) — cria empresa + usuário de acesso
2. **Site** — vinculado ao cliente, tipo `BIOLINK`
3. **BioLink** — vinculado ao site
4. **Itens** — links exibidos na página do biolink

---

## Referência rápida de endpoints

| Método | Endpoint | Auth | Role |
|--------|----------|------|------|
| POST | `/api/v1/auth/login` | — | — |
| GET | `/api/v1/usuarios` | Bearer | ADMIN |
| POST | `/api/v1/usuarios/novo` | Bearer | ADMIN |
| PUT | `/api/v1/usuarios/alterar-dados?id=` | Bearer | ADMIN |
| DELETE | `/api/v1/usuarios/apagar?id=` | Bearer | ADMIN |
| GET | `/api/v1/clientes` | Bearer | ADMIN |
| POST | `/api/v1/clientes/novo` | Bearer | ADMIN |
| PUT | `/api/v1/clientes/alterar-dados?id=` | Bearer | ADMIN |
| DELETE | `/api/v1/clientes/apagar?id=` | Bearer | ADMIN |
| GET | `/api/v1/sites` | Bearer | ADMIN, CLIENTE |
| POST | `/api/v1/sites/novo` | Bearer | ADMIN, CLIENTE |
| PUT | `/api/v1/sites/alterar-dados?id=` | Bearer | ADMIN, CLIENTE |
| DELETE | `/api/v1/sites/apagar?id=` | Bearer | ADMIN, CLIENTE |
| GET | `/api/v1/biolinks` | Bearer | ADMIN, CLIENTE |
| POST | `/api/v1/biolinks/novo` | Bearer | ADMIN, CLIENTE |
| PUT | `/api/v1/biolinks/alterar-dados?id=` | Bearer | ADMIN, CLIENTE |
| DELETE | `/api/v1/biolinks/apagar?id=` | Bearer | ADMIN, CLIENTE |
| GET | `/api/v1/biolinks/itens?biolink_id=` | Bearer | ADMIN, CLIENTE |
| POST | `/api/v1/biolinks/itens/novo` | Bearer | ADMIN, CLIENTE |
| PUT | `/api/v1/biolinks/itens/alterar-dados?biolink_id=&id=` | Bearer | ADMIN, CLIENTE |
| DELETE | `/api/v1/biolinks/itens/apagar?biolink_id=&id=` | Bearer | ADMIN, CLIENTE |

---

*Documento gerado com base no backend Gestor v0.0.1-SNAPSHOT (Spring Boot 3.4.5).*
