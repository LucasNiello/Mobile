import 'package:flutter/material.dart';

/// Cidades disponíveis no seletor (RF01 exige ao menos três).
const List<String> cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

/// Valor usado no filtro para "não filtrar por cidade".
const String todasCidades = 'Todas';

/// Categorias aceitas no cadastro e nos filtros.
const List<String> categorias = ['Academia', 'Restaurante', 'Hospital', 'Farmácia'];

/// Valor usado no filtro para "não filtrar por categoria".
const String todasCategorias = 'Todos';

/// Rótulo no plural usado nos chips de filtro, como no wireframe.
String rotuloCategoria(String categoria) {
  const plurais = {
    todasCategorias: 'Todos',
    'Academia': 'Academias',
    'Restaurante': 'Restaurantes',
    'Hospital': 'Hospitais',
    'Farmácia': 'Farmácias',
  };
  return plurais[categoria] ?? categoria;
}

/// Ícone que representa cada categoria (usado no lugar de fotos).
IconData iconeDaCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return Icons.fitness_center;
    case 'Restaurante':
      return Icons.restaurant;
    case 'Hospital':
      return Icons.local_hospital;
    case 'Farmácia':
      return Icons.local_pharmacy;
    default:
      return Icons.storefront;
  }
}

/// Cor de fundo suave de cada categoria (placeholder de imagem).
Color corDaCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return const Color(0xFFE3ECFB);
    case 'Restaurante':
      return const Color(0xFFFCEBDD);
    case 'Hospital':
      return const Color(0xFFFBE2E2);
    case 'Farmácia':
      return const Color(0xFFE0F2E7);
    default:
      return const Color(0xFFECEDEF);
  }
}

/// Paleta neutra próxima ao wireframe.
class Cores {
  static const Color texto = Color(0xFF1F2328);
  static const Color textoSecundario = Color(0xFF6B7078);
  static const Color borda = Color(0xFFE2E4E8);
  static const Color fundoCampo = Color(0xFFF6F7F9);
  static const Color escuro = Color(0xFF2B2F36);
  static const Color estrela = Color(0xFF2B2F36);
  static const Color sucesso = Color(0xFF1E7B45);
  static const Color erro = Color(0xFFB3261E);
  static const Color favorito = Color(0xFFD93B3B);
}
