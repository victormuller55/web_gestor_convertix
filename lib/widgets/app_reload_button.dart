import 'package:flutter/material.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

class AppReloadButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AppReloadButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Atualizar dados',
      onPressed: isLoading ? null : onPressed,
      icon: _reloadButtonIcon(isLoading),
    );
  }
}

Widget appReloadButton({
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return AppReloadButton(onPressed: onPressed, isLoading: isLoading);
}

Widget _reloadButtonIcon(bool isLoading) {
  if (isLoading) return _reloadButtonSpinner();

  return Icon(
    Icons.refresh_rounded,
    color: ConvertixColors.textPrimary,
  );
}

Widget _reloadButtonSpinner() {
  return const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: ConvertixColors.primary,
    ),
  );
}
