import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'constantes.dart';

/// Traduz erros do Firebase para mensagens que o usuário entende.
String mensagemDeErro(Object erro) {
  if (erro is FirebaseException) {
    switch (erro.code) {
      case 'permission-denied':
        return 'Sem permissão no banco de dados. Verifique as regras do '
            'Firestore e se o login anônimo está ativado.';
      case 'unavailable':
        return 'Banco de dados indisponível. Verifique sua conexão com a internet.';
      case 'not-found':
        return 'Este local não existe mais no banco de dados.';
      case 'deadline-exceeded':
        return 'O servidor demorou para responder. Tente novamente.';
      default:
        return 'Erro do Firebase (${erro.code}). Tente novamente.';
    }
  }
  return 'Erro inesperado. Tente novamente.';
}

void mostrarSucesso(ScaffoldMessengerState mensageiro, String mensagem) {
  _mostrar(mensageiro, mensagem, Cores.sucesso, Icons.check_circle_outline);
}

void mostrarErro(ScaffoldMessengerState mensageiro, String mensagem) {
  _mostrar(mensageiro, mensagem, Cores.erro, Icons.error_outline);
}

void _mostrar(
  ScaffoldMessengerState mensageiro,
  String mensagem,
  Color cor,
  IconData icone,
) {
  mensageiro
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icone, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(mensagem)),
          ],
        ),
      ),
    );
}
