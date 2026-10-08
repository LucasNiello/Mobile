import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/services/dados_exemplo.dart';
import 'package:mapa_locais/utils/horario.dart';

DateTime as(int hora, int minuto) => DateTime(2026, 10, 8, hora, minuto);

void main() {
  group('horarioValido', () {
    test('aceita os formatos esperados', () {
      expect(horarioValido('06:00 - 22:00'), isTrue);
      expect(horarioValido('06:00-22:00'), isTrue);
      expect(horarioValido('24 horas'), isTrue);
      expect(horarioValido('24h'), isTrue);
    });

    test('recusa formatos inválidos', () {
      expect(horarioValido('6h às 22h'), isFalse);
      expect(horarioValido('25:00 - 22:00'), isFalse);
      expect(horarioValido(''), isFalse);
    });

    test('todos os dados de exemplo usam formato válido', () {
      for (final local in dadosExemplo) {
        expect(horarioValido(local.horario), isTrue, reason: local.nome);
      }
    });
  });

  group('statusDoHorario', () {
    test('expediente comum', () {
      expect(statusDoHorario('06:00 - 22:00', as(5, 59)), StatusHorario.fechado);
      expect(statusDoHorario('06:00 - 22:00', as(6, 0)), StatusHorario.aberto);
      expect(statusDoHorario('06:00 - 22:00', as(21, 59)), StatusHorario.aberto);
      expect(statusDoHorario('06:00 - 22:00', as(22, 0)), StatusHorario.fechado);
    });

    test('expediente que passa da meia-noite', () {
      expect(statusDoHorario('18:00 - 00:00', as(23, 30)), StatusHorario.aberto);
      expect(statusDoHorario('18:00 - 02:00', as(1, 0)), StatusHorario.aberto);
      expect(statusDoHorario('18:00 - 02:00', as(3, 0)), StatusHorario.fechado);
      expect(statusDoHorario('18:00 - 02:00', as(12, 0)), StatusHorario.fechado);
    });

    test('24 horas está sempre aberto', () {
      expect(statusDoHorario('24 horas', as(3, 0)), StatusHorario.aberto);
    });

    test('formato desconhecido não gera status', () {
      expect(statusDoHorario('horário comercial', as(10, 0)), isNull);
    });
  });
}
