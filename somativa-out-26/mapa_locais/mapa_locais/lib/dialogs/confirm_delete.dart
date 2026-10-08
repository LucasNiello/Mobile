import 'package:flutter/material.dart';

import '../utils/constantes.dart';

/// Pergunta antes de excluir (requisito não funcional). Retorna `true` somente
/// se o usuário tocar em "Excluir"; fechar o diálogo conta como cancelar.
Future<bool> confirmarExclusao(BuildContext context, String nomeLocal) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(Icons.delete_outline, color: Cores.erro),
        title: const Text('Excluir local?'),
        content: Text(
          '"$nomeLocal" será removido do banco de dados. '
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Cores.erro),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return confirmou == true;
}
