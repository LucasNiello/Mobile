import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Login anônimo: o usuário não digita nada, mas cada aparelho recebe uma
/// identidade do Firebase. Isso permite que as regras do Firestore exijam
/// `request.auth != null` em vez de deixar o banco aberto para qualquer um.
class AuthService {
  AuthService._();

  static Future<void> entrarAnonimamente() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
    } on FirebaseAuthException catch (erro) {
      // Se o provedor anônimo não estiver ativado no console (ou não houver
      // internet), o app abre mesmo assim e as telas mostram a mensagem de erro.
      debugPrint('Falha no login anônimo: ${erro.code}');
    } catch (erro) {
      debugPrint('Falha inesperada no login anônimo: $erro');
    }
  }

  /// ID da sessão anônima atual (exibido em "Perfil").
  static String? get idUsuario => FirebaseAuth.instance.currentUser?.uid;
}
