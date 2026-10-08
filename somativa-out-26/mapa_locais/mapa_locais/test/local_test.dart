import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/models/local.dart';

void main() {
  group('Local.fromMap', () {
    test('converte um documento completo', () {
      final local = Local.fromMap('abc123', {
        'nome': 'Academia Fitness',
        'categoria': 'Academia',
        'cidade': 'São Paulo',
        'avaliacao': 4.8,
        'distancia': 1.2,
        'horario': '06:00 - 22:00',
        'descricao': 'Completa',
        'favorito': true,
      });

      expect(local.id, 'abc123');
      expect(local.nome, 'Academia Fitness');
      expect(local.avaliacao, 4.8);
      expect(local.distancia, 1.2);
      expect(local.favorito, isTrue);
    });

    test('usa valores padrão quando faltam campos', () {
      final local = Local.fromMap('x', {});

      expect(local.nome, '');
      expect(local.avaliacao, 0);
      expect(local.distancia, 0);
      expect(local.favorito, isFalse);
    });

    test('aceita números inteiros e texto numérico vindos do console', () {
      final local = Local.fromMap('x', {
        'avaliacao': 5,
        'distancia': '2,5',
        'favorito': 'true',
      });

      expect(local.avaliacao, 5.0);
      expect(local.distancia, 2.5);
      // Só o booleano true conta como favorito.
      expect(local.favorito, isFalse);
    });
  });

  test('toMap não grava o id e mantém os 8 campos do modelo', () {
    const local = Local(
      id: 'nao-deve-ir',
      nome: 'Iron Gym',
      categoria: 'Academia',
      cidade: 'Campinas',
      avaliacao: 4.2,
      distancia: 5.2,
      horario: '06:00 - 23:00',
      descricao: '',
      favorito: false,
    );

    final mapa = local.toMap();

    expect(mapa.containsKey('id'), isFalse);
    expect(mapa.keys, hasLength(8));
    expect(Local.fromMap('novo', mapa).nome, 'Iron Gym');
  });

  test('copyWith altera só o campo informado', () {
    const original = Local(
      id: '1',
      nome: 'A',
      categoria: 'Academia',
      cidade: 'Jundiaí',
      avaliacao: 4,
      distancia: 1,
      horario: '24 horas',
      descricao: '',
      favorito: false,
    );

    final alterado = original.copyWith(favorito: true);

    expect(alterado.favorito, isTrue);
    expect(alterado.nome, 'A');
    expect(alterado.id, '1');
  });
}
