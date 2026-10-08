import 'package:flutter/material.dart';

import '../utils/constantes.dart';

/// Abre a lista de cidades em um Bottom Sheet e devolve a escolhida
/// (ou `null` se o usuário fechar sem escolher).
Future<String?> selecionarCidade(
  BuildContext context, {
  required String atual,
  bool incluirTodas = false,
}) {
  final opcoes = [if (incluirTodas) todasCidades, ...cidades];

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Selecione a cidade',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            for (final cidade in opcoes)
              ListTile(
                leading: Icon(
                  cidade == todasCidades ? Icons.public : Icons.location_city,
                ),
                title: Text(
                  cidade == todasCidades ? 'Todas as cidades' : cidade,
                ),
                trailing: cidade == atual
                    ? const Icon(Icons.check, color: Cores.escuro)
                    : null,
                onTap: () => Navigator.pop(context, cidade),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
