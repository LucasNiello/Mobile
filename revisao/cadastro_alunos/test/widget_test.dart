import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cadastro_alunos/main.dart';

void main() {
  testWidgets('Cadastra aluno e exibe na lista', (WidgetTester tester) async {
    await tester.pumpWidget(const CadastroAlunosApp());

    expect(find.text('Nenhum aluno cadastrado ainda.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Maria');
    await tester.enterText(find.widgetWithText(TextFormField, 'Idade'), '20');
    await tester.enterText(find.widgetWithText(TextFormField, 'Curso'), 'ADS');

    await tester.tap(find.widgetWithText(FilledButton, 'Cadastrar'));
    await tester.pump();

    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('20 anos • ADS'), findsOneWidget);
    expect(find.text('Nenhum aluno cadastrado ainda.'), findsNothing);
  });
}
