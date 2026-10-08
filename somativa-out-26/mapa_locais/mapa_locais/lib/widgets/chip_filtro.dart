import 'package:flutter/material.dart';

import '../utils/constantes.dart';

/// Chip de seleção no estilo do wireframe: escuro quando selecionado.
class ChipFiltro extends StatelessWidget {
  const ChipFiltro({
    super.key,
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
    this.icone,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final corTexto = selecionado ? Colors.white : Cores.texto;
    return ChoiceChip(
      label: Text(rotulo),
      avatar: icone == null ? null : Icon(icone, size: 18, color: corTexto),
      selected: selecionado,
      showCheckmark: false,
      onSelected: (_) => aoTocar(),
      selectedColor: Cores.escuro,
      backgroundColor: Cores.fundoCampo,
      side: BorderSide(color: selecionado ? Cores.escuro : Cores.borda),
      labelStyle: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
      shape: const StadiumBorder(),
    );
  }
}
