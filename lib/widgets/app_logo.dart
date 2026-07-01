import 'package:flutter/material.dart';

const String logoAsset = 'assets/images/logo_texto_fundo_transparente.png';

Widget appLogoConvertix({
  double height = 48,
  Alignment alignment = Alignment.center,
}) {
  return Align(
    alignment: alignment,
    child: _logoImage(height),
  );
}

Widget _logoImage(double height) {
  return Image.asset(
    logoAsset,
    height: height,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );
}
