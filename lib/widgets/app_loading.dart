import 'package:flutter/material.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

Widget appLoadingCovertix() {
  return Center(child: _loadingIndicator());
}

Widget _loadingIndicator() {
  return const CircularProgressIndicator(
    color: ConvertixColors.primary,
    strokeWidth: 2.5,
  );
}
