import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/foto_helper.dart';

class FotoPickerField extends StatefulWidget {
  final String? fotoAtual;
  final ValueChanged<XFile?> onFotoChanged;
  final double size;

  const FotoPickerField({super.key, this.fotoAtual, required this.onFotoChanged, this.size = 96});

  @override
  State<FotoPickerField> createState() => _FotoPickerFieldState();
}

class _FotoPickerPreviewState {
  final XFile? novaFoto;
  final Uint8List? previewBytes;
  final String? erro;

  const _FotoPickerPreviewState({
    this.novaFoto,
    this.previewBytes,
    this.erro,
  });
}

class _FotoPickerFieldState extends State<FotoPickerField> {
  final ValueNotifier<_FotoPickerPreviewState> _previewNotifier =
      ValueNotifier(const _FotoPickerPreviewState());

  @override
  void dispose() {
    _previewNotifier.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto() async {
    final file = await pickImageFromGalleryWeb();
    if (file == null) return;

    final erro = await validarFotoComTamanho(file);
    if (erro != null) {
      _previewNotifier.value = _FotoPickerPreviewState(erro: erro);
      return;
    }

    final bytes = await file.readAsBytes();
    _previewNotifier.value = _FotoPickerPreviewState(
      novaFoto: file,
      previewBytes: bytes,
    );
    widget.onFotoChanged(file);
  }

  void _descartarNovaFoto() {
    _previewNotifier.value = const _FotoPickerPreviewState();
    widget.onFotoChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return appContainer(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      radius: BorderRadius.circular(10),
      backgroundColor: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fotoPickerLabel(),
          appSizedBox(height: AppSpacing.normal),
          ValueListenableBuilder<_FotoPickerPreviewState>(
            valueListenable: _previewNotifier,
            builder: (_, preview, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fotoPickerRow(
                    size: widget.size,
                    fotoAtual: widget.fotoAtual,
                    previewBytes: preview.previewBytes,
                    temNovaFoto: preview.novaFoto != null,
                    onSelecionar: _selecionarFoto,
                    onDescartar: _descartarNovaFoto,
                  ),
                  if (preview.erro != null) ...[
                    appSizedBox(height: AppSpacing.small),
                    _fotoPickerErro(preview.erro!),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget fotoPickerField({
  String? fotoAtual,
  required ValueChanged<XFile?> onFotoChanged,
  double size = 96,
}) {
  return FotoPickerField(fotoAtual: fotoAtual, onFotoChanged: onFotoChanged, size: size);
}

Widget _fotoPickerLabel() {
  return appText(
    'Foto (opcional) - JPEG, PNG ou WebP — máx. 5 MB',
    color: ConvertixColors.textSecondary,
    fontSize: AppFontSizes.verySmall,
  );
}
Widget _fotoPickerErro(String mensagem) {
  return appText(mensagem, color: ConvertixColors.error, fontSize: AppFontSizes.verySmall);
}

Widget _fotoPickerRow({
  required double size,
  required String? fotoAtual,
  required Uint8List? previewBytes,
  required bool temNovaFoto,
  required VoidCallback onSelecionar,
  required VoidCallback onDescartar,
}) {
  return Row(
    children: [
      _fotoPickerAvatar(
        size: size,
        fotoAtual: fotoAtual,
        previewBytes: previewBytes,
        onTap: onSelecionar,
      ),
      appSizedBox(width: AppSpacing.normal),
      _fotoPickerAcoes(
        temNovaFoto: temNovaFoto,
        onSelecionar: onSelecionar,
        onDescartar: onDescartar,
      ),
    ],
  );
}

Widget _fotoPickerAvatar({
  required double size,
  required String? fotoAtual,
  required Uint8List? previewBytes,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(size),
    child: _fotoPickerAvatarConteudo(size: size, fotoAtual: fotoAtual, previewBytes: previewBytes),
  );
}

Widget _fotoPickerAvatarConteudo({
  required double size,
  required String? fotoAtual,
  required Uint8List? previewBytes,
}) {
  if (previewBytes != null) {
    return _fotoPickerAvatarMemoria(size: size, bytes: previewBytes);
  }

  if (_fotoPickerTemFotoAtual(fotoAtual)) {
    return _fotoPickerAvatarRede(size: size, path: fotoAtual!);
  }

  return _fotoPickerAvatarVazio(size: size);
}

bool _fotoPickerTemFotoAtual(String? path) {
  return path != null && path.trim().isNotEmpty;
}

Widget _fotoPickerAvatarVazio({required double size}) {
  return appContainer(
    height: 120,
    width: 120,
    radius: BorderRadius.circular(10),
    backgroundColor: Colors.white,
    child: Icon(Icons.image_not_supported_rounded, size: size * 0.35, color: ConvertixColors.textMuted),
  );
}

Widget _fotoPickerAvatarMemoria({required double size, required Uint8List bytes}) {
  return appContainer(
    height: 120,
    width: 120,
    radius: BorderRadius.circular(10),
    backgroundColor: Colors.white,
    image: MemoryImage(bytes),
  );
}

Widget _fotoPickerAvatarRede({required double size, required String path}) {
  return appContainer(
    height: 120,
    width: 120,
    radius: BorderRadius.circular(10),
    backgroundColor: Colors.white,
    image: NetworkImage(fotoUrl(path)),
  );
}

Widget _fotoPickerAcoes({
  required bool temNovaFoto,
  required VoidCallback onSelecionar,
  required VoidCallback onDescartar,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fotoPickerBotaoSelecionar(onSelecionar),
      if (temNovaFoto) _fotoPickerBotaoDescartar(onDescartar),
    ],
  );
}

Widget _fotoPickerBotaoSelecionar(VoidCallback onTap) {
  return _fotoPickerBotaoTexto(
    icon: Icons.upload_outlined,
    label: 'Selecionar imagem',
    onTap: onTap,
  );
}

Widget _fotoPickerBotaoDescartar(VoidCallback onTap) {
  return _fotoPickerBotaoTexto(
    icon: Icons.close,
    label: 'Descartar nova foto',
    onTap: onTap,
    textColor: ConvertixColors.error,
  );
}

Widget _fotoPickerBotaoTexto({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? textColor,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadius.small),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor ?? ConvertixColors.primary),
          appSizedBox(width: AppSpacing.small),
          appText(
            label,
            color: textColor ?? ConvertixColors.primary,
            fontSize: AppFontSizes.verySmall,
          ),
        ],
      ),
    ),
  );
}
