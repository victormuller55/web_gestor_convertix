import 'package:flutter/material.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_icone.dart';

class BiolinkItemIconeWidget extends StatelessWidget {
  final String? icone;
  final double size;

  const BiolinkItemIconeWidget({
    super.key,
    required this.icone,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final valor = icone?.trim();
    if (valor == null || valor.isEmpty) return const SizedBox.shrink();

    if (valor == BioLinkItemIcone.outros) {
      return SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.link, size: size * 0.72, color: BioLinkItemIcone.cor(valor)),
      );
    }

    final fontSize = valor.length == 1 ? size * 0.48 : size * 0.34;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BioLinkItemIcone.cor(valor),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Text(
        BioLinkItemIcone.abreviacao(valor),
        style: TextStyle(
          color: BioLinkItemIcone.corTexto(valor),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
