import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_service.dart';

Future<UsuarioModel> salvarPerfil({
  required UsuarioModel usuarioAtual,
  required UsuarioModel dados,
  XFile? foto,
}) async {
  if (usuarioAtual.isAdmin) {
    final atualizado = await alterarUsuarioAdmin(
      usuarioAtual.id!,
      UsuarioModel(
        id: usuarioAtual.id,
        nome: dados.nome,
        email: dados.email,
        senha: dados.senha,
        ativo: usuarioAtual.ativo ?? true,
        tipo: usuarioAtual.tipo,
      ),
      foto: foto,
    );
    return _persistirSessao(usuarioAtual, atualizado);
  }
  if (usuarioAtual.isCliente && usuarioAtual.clienteId != null) {
    final clienteAtualizado = await alterarCliente(
      usuarioAtual.clienteId!,
      ClienteModel(
        id: usuarioAtual.clienteId,
        nomeEmpresa: dados.nomeEmpresa,
        documento: dados.documento,
        email: dados.email,
        telefone: dados.telefone,
        senha: dados.senha,
      ),
      foto: foto,
    );
    return _persistirSessao(
      usuarioAtual,
      UsuarioModel(
        id: usuarioAtual.id,
        nome: usuarioAtual.nome,
        email: dados.email,
        tipo: usuarioAtual.tipo,
        ativo: usuarioAtual.ativo,
        clienteId: usuarioAtual.clienteId,
        nomeEmpresa: dados.nomeEmpresa,
        documento: dados.documento,
        telefone: dados.telefone,
        token: usuarioAtual.token,
        foto: clienteAtualizado.foto,
      ),
    );
  }
  throw StateError('Perfil não suportado para este usuário.');
}

Future<UsuarioModel> _persistirSessao(
  UsuarioModel anterior,
  UsuarioModel atualizado,
) async {
  final merged = UsuarioModel(
    id: anterior.id,
    nome: atualizado.nome ?? anterior.nome,
    email: atualizado.email ?? anterior.email,
    tipo: anterior.tipo,
    ativo: atualizado.ativo ?? anterior.ativo,
    clienteId: anterior.clienteId,
    nomeEmpresa: atualizado.nomeEmpresa ?? anterior.nomeEmpresa,
    documento: atualizado.documento ?? anterior.documento,
    telefone: atualizado.telefone ?? anterior.telefone,
    token: anterior.token,
    foto: atualizado.foto ?? anterior.foto,
    createdAt: atualizado.createdAt ?? anterior.createdAt,
    updatedAt: atualizado.updatedAt ?? anterior.updatedAt,
  );
  await saveUsuarioLogado(merged);
  return merged;
}
