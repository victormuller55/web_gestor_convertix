import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

enum WebToastType { success, error, warning }

class WebToastPopup extends StatelessWidget {
  final String message;
  final WebToastType type;
  final VoidCallback onClose;

  const WebToastPopup({
    super.key,
    required this.message,
    required this.type,
    required this.onClose,
  });

  static const double width = 380;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _webToastContainer(
        type: type,
        message: message,
        onClose: onClose,
      ),
    );
  }
}

Widget _webToastContainer({
  required WebToastType type,
  required String message,
  required VoidCallback onClose,
}) {
  return Container(
    width: WebToastPopup.width,
    decoration: _webToastDecoration(),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _webToastAccentBar(type),
            Expanded(child: _webToastBody(type: type, message: message, onClose: onClose)),
          ],
        ),
      ),
    ),
  );
}

BoxDecoration _webToastDecoration() {
  return BoxDecoration(
    color: ConvertixColors.surface,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: ConvertixColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

Widget _webToastAccentBar(WebToastType type) {
  return Container(width: 4, color: _webToastAccentColor(type));
}

Widget _webToastBody({
  required WebToastType type,
  required String message,
  required VoidCallback onClose,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _webToastIconBadge(type),
        appSizedBox(width: AppSpacing.normal),
        Expanded(child: _webToastMessage(message)),
        _webToastCloseButton(onClose),
      ],
    ),
  );
}

Widget _webToastIconBadge(WebToastType type) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: _webToastIconBackground(type),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Icon(_webToastIcon(type), color: _webToastAccentColor(type), size: 20),
  );
}

Widget _webToastMessage(String message) {
  return Padding(
    padding: const EdgeInsets.only(top: 2),
    child: appText(
      message,
      color: ConvertixColors.textPrimary,
      fontSize: AppFontSizes.verySmall,
    ),
  );
}

Widget _webToastCloseButton(VoidCallback onClose) {
  return IconButton(
    onPressed: onClose,
    icon: const Icon(Icons.close, size: 18),
    color: ConvertixColors.textMuted,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    tooltip: 'Fechar',
  );
}

Color _webToastAccentColor(WebToastType type) {
  switch (type) {
    case WebToastType.success:
      return ConvertixColors.primary;
    case WebToastType.error:
      return ConvertixColors.error;
    case WebToastType.warning:
      return AppColors.orange;
  }
}

Color _webToastIconBackground(WebToastType type) {
  switch (type) {
    case WebToastType.success:
      return ConvertixColors.primaryLight;
    case WebToastType.error:
      return ConvertixColors.errorBackground;
    case WebToastType.warning:
      return AppColors.orange.withValues(alpha: 0.15);
  }
}

IconData _webToastIcon(WebToastType type) {
  switch (type) {
    case WebToastType.success:
      return Icons.check_rounded;
    case WebToastType.error:
      return Icons.error_outline_rounded;
    case WebToastType.warning:
      return Icons.warning_amber_rounded;
  }
}
