import 'package:flutter/material.dart';

import '../utils/constantes.dart';

/// Espaço reservado para a foto do local.
///
/// O modelo da atividade não tem campo de imagem (fotos reais ficam para o
/// desafio extra com Firebase Storage), então mostramos o ícone da categoria
/// sobre uma cor própria de cada categoria.
class ImagemLocal extends StatelessWidget {
  const ImagemLocal({
    super.key,
    required this.categoria,
    this.largura,
    this.altura,
    this.tamanhoIcone = 32,
    this.raio = 12,
  });

  final String categoria;
  final double? largura;
  final double? altura;
  final double tamanhoIcone;
  final double raio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: corDaCategoria(categoria),
        borderRadius: BorderRadius.circular(raio),
      ),
      child: Icon(
        iconeDaCategoria(categoria),
        size: tamanhoIcone,
        color: const Color(0x8C1F2328),
      ),
    );
  }
}
