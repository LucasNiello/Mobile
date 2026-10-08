import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/services/dados_exemplo.dart';
import 'package:mapa_locais/utils/constantes.dart';
import 'package:mapa_locais/utils/filtros.dart';

void main() {
  // Os dados de exemplo ganham ids para simular documentos do Firestore.
  final locais = [
    for (var i = 0; i < dadosExemplo.length; i++)
      dadosExemplo[i].copyWith(id: 'doc$i', favorito: i == 0 || i == 7),
  ];

  test('sem filtros devolve tudo, ordenado pela distância', () {
    final resultado = filtrarLocais(locais);

    expect(resultado, hasLength(locais.length));
    for (var i = 1; i < resultado.length; i++) {
      expect(resultado[i - 1].distancia <= resultado[i].distancia, isTrue);
    }
  });

  test('T02 — pesquisa "Academia" encontra só academias', () {
    final resultado = filtrarLocais(locais, texto: 'Academia');

    expect(resultado, isNotEmpty);
    expect(resultado.every((l) => l.categoria == 'Academia'), isTrue);
  });

  test('pesquisa ignora maiúsculas e acentos', () {
    expect(filtrarLocais(locais, texto: 'FARMACIA'), hasLength(3));
    expect(filtrarLocais(locais, texto: 'bella nonna').single.nome,
        'Cantina Bella Nonna');
  });

  test('T03 — filtra pela cidade selecionada', () {
    final resultado = filtrarLocais(locais, cidade: 'Campinas');

    expect(resultado, hasLength(6));
    expect(resultado.every((l) => l.cidade == 'Campinas'), isTrue);
  });

  test('T04 — filtra por categoria', () {
    final resultado = filtrarLocais(locais, categoria: 'Hospital');

    expect(resultado, hasLength(3));
    expect(resultado.every((l) => l.categoria == 'Hospital'), isTrue);
  });

  test('combina cidade, categoria e texto', () {
    final resultado = filtrarLocais(
      locais,
      cidade: 'Jundiaí',
      categoria: 'Restaurante',
      texto: 'grill',
    );

    expect(resultado.single.nome, 'Grill Japi');
  });

  test('filtro de favoritos mostra só os marcados', () {
    final resultado = filtrarLocais(locais, somenteFavoritos: true);

    expect(resultado, hasLength(2));
    expect(resultado.every((l) => l.favorito), isTrue);
  });

  test('"Todas" e "Todos" desativam os filtros de cidade e categoria', () {
    final resultado = filtrarLocais(
      locais,
      cidade: todasCidades,
      categoria: todasCategorias,
    );

    expect(resultado, hasLength(locais.length));
  });

  test('busca sem correspondência devolve lista vazia', () {
    expect(filtrarLocais(locais, texto: 'xyz inexistente'), isEmpty);
  });

  test('os dados de exemplo cobrem os requisitos do checklist', () {
    expect(dadosExemplo.length, greaterThanOrEqualTo(10));
    for (final cidade in cidades) {
      // Pelo menos 5 marcadores no mapa de cada cidade.
      expect(dadosExemplo.where((l) => l.cidade == cidade).length,
          greaterThanOrEqualTo(5));
    }
    expect(dadosExemplo.every((Local l) => categorias.contains(l.categoria)),
        isTrue);
  });
}
