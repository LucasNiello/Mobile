import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapa_locais/dialogs/confirm_delete.dart';
import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/widgets/local_card.dart';
import 'package:mapa_locais/widgets/local_form.dart';
import 'package:mapa_locais/widgets/mapa_representacao.dart';

/// Testes de interface que não precisam do Firebase: o formulário recebe a
/// função de salvar por parâmetro, então aqui ela só captura o resultado.
void main() {
  const exemplo = Local(
    id: 'doc1',
    nome: 'Academia Fitness',
    categoria: 'Academia',
    cidade: 'São Paulo',
    avaliacao: 4.8,
    distancia: 1.2,
    horario: '06:00 - 22:00',
    descricao: 'Completa',
    favorito: true,
  );

  Widget emTela(Widget filho) => MaterialApp(home: Scaffold(body: filho));

  testWidgets('card mostra nome, categoria, distância e avaliação',
      (tester) async {
    await tester.pumpWidget(emTela(LocalCard(
      local: exemplo,
      aoTocar: () {},
      aoEditar: () {},
      aoExcluir: () {},
    )));

    expect(find.text('Academia Fitness'), findsOneWidget);
    expect(find.text('Academia · São Paulo'), findsOneWidget);
    expect(find.text('1,2 km'), findsOneWidget);
    expect(find.text('4,8'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('menu do card chama editar e excluir', (tester) async {
    var editou = false;
    var excluiu = false;
    await tester.pumpWidget(emTela(LocalCard(
      local: exemplo,
      aoTocar: () {},
      aoEditar: () => editou = true,
      aoExcluir: () => excluiu = true,
    )));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(editou, isTrue);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(excluiu, isTrue);
  });

  group('formulário', () {
    testWidgets('cadastro vazio mostra os erros de validação', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      addTearDown(tester.view.reset);

      Local? salvo;
      await tester.pumpWidget(emTela(SingleChildScrollView(
        child: FormularioLocal(aoSalvar: (l) async => salvo = l),
      )));

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe o nome do local'), findsOneWidget);
      expect(find.text('Escolha uma categoria'), findsOneWidget);
      expect(find.text('Escolha uma cidade'), findsOneWidget);
      expect(salvo, isNull);
    });

    testWidgets('cadastro válido monta o Local com vírgula decimal',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      addTearDown(tester.view.reset);

      Local? salvo;
      await tester.pumpWidget(emTela(SingleChildScrollView(
        child: FormularioLocal(
          cidadeInicial: 'Campinas',
          aoSalvar: (l) async => salvo = l,
        ),
      )));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'), 'Novo Lugar');
      await tester.tap(find.text('Restaurante'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Avaliação'), '4,5');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Distância'), '2,3');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Horário de funcionamento'),
          '11:00 - 23:00');
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(salvo, isNotNull);
      expect(salvo!.id, '');
      expect(salvo!.nome, 'Novo Lugar');
      expect(salvo!.categoria, 'Restaurante');
      expect(salvo!.cidade, 'Campinas');
      expect(salvo!.avaliacao, 4.5);
      expect(salvo!.distancia, 2.3);
      expect(salvo!.favorito, isFalse);
    });

    testWidgets('avaliação fora de 0 a 5 é recusada', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(emTela(SingleChildScrollView(
        child: FormularioLocal(aoSalvar: (l) async {}),
      )));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Avaliação'), '7');
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Entre 0 e 5'), findsOneWidget);
    });

    testWidgets('edição vem preenchida e preserva id e favorito',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      addTearDown(tester.view.reset);

      Local? salvo;
      await tester.pumpWidget(emTela(SingleChildScrollView(
        child: FormularioLocal(
          local: exemplo,
          aoSalvar: (l) async => salvo = l,
        ),
      )));

      expect(find.text('Editar local'), findsOneWidget);
      expect(find.text('Academia Fitness'), findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Horário de funcionamento'),
          '07:00 - 21:00');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();

      expect(salvo!.id, 'doc1');
      expect(salvo!.favorito, isTrue);
      expect(salvo!.horario, '07:00 - 21:00');
    });
  });

  group('confirmação de exclusão', () {
    Future<bool?> abrirDialogo(WidgetTester tester, String botao) async {
      bool? resposta;
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                resposta = await confirmarExclusao(context, 'Iron Gym'),
            child: const Text('abrir'),
          ),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir local?'), findsOneWidget);
      await tester.tap(find.text(botao));
      await tester.pumpAndSettle();
      return resposta;
    }

    testWidgets('Cancelar não exclui', (tester) async {
      expect(await abrirDialogo(tester, 'Cancelar'), isFalse);
    });

    testWidgets('Excluir confirma', (tester) async {
      expect(await abrirDialogo(tester, 'Excluir'), isTrue);
    });
  });

  test('posições do mapa são estáveis e não se sobrepõem', () {
    // IDs no formato gerado pelo Firestore (20 caracteres aleatórios).
    final ids = [
      'Zx81kPq2mN0vB7cD4eFg', 'a1B2c3D4e5F6g7H8i9J0', 'QwErTyUiOpAsDfGhJkLz',
      'mNbVcXzLkJhGfDsApOiU', '9f8e7d6c5b4a3Z2Y1X0w', 'TtRrEeWwQqYyUuIiOoPp',
      'documento_1', 'documento_2', 'documento_3', 'documento_4',
    ];
    final primeira = calcularPosicoes(ids);
    final segunda = calcularPosicoes(ids.reversed.toList());

    // Mesma entrada (em qualquer ordem) gera as mesmas posições.
    expect(primeira, equals(segunda));
    final pontos = primeira.values.toList();
    for (var i = 0; i < pontos.length; i++) {
      expect(pontos[i].dx, inInclusiveRange(0, 1));
      expect(pontos[i].dy, inInclusiveRange(0, 1));
      for (var j = i + 1; j < pontos.length; j++) {
        expect((pontos[i] - pontos[j]).distance, greaterThanOrEqualTo(0.1));
      }
    }
  });
}
