import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/local.dart';
import 'dados_exemplo.dart';

/// Única classe que conversa com a coleção `locais` do Firestore.
///
/// As telas nunca usam o Firestore diretamente: elas chamam estes métodos.
/// Assim, se a forma de gravar mudar, só este arquivo é alterado.
class LocalService {
  LocalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _locais =>
      _firestore.collection('locais');

  /// READ — lista em tempo real (RF03). Qualquer alteração no banco
  /// reconstrói as telas que estiverem ouvindo este Stream.
  Stream<List<Local>> listarLocais() {
    return _locais.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Local.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// READ — acompanha um único documento (usado na tela de detalhes para
  /// refletir favorito/edição na hora). Emite `null` se o local for excluído.
  Stream<Local?> observarLocal(String id) {
    return _locais.doc(id).snapshots().map((doc) {
      final dados = doc.data();
      if (!doc.exists || dados == null) return null;
      return Local.fromMap(doc.id, dados);
    });
  }

  /// CREATE — o Firestore gera o ID do documento automaticamente (RF05).
  Future<void> adicionar(Local local) async {
    await _locais.add(local.toMap());
  }

  /// UPDATE — substitui os campos do documento identificado pelo id (RF06).
  Future<void> atualizar(Local local) async {
    await _locais.doc(local.id).update(local.toMap());
  }

  /// DELETE — remove o documento (RF07). A confirmação fica na interface.
  Future<void> excluir(String id) async {
    await _locais.doc(id).delete();
  }

  /// UPDATE parcial — altera somente o campo `favorito` (RF09).
  Future<void> alterarFavorito(String id, bool favorito) async {
    await _locais.doc(id).update({'favorito': favorito});
  }

  /// Grava os locais de exemplo de uma vez só (um único batch). Usado apenas
  /// quando a coleção está vazia, para não precisar digitar tudo no console.
  Future<void> popularDadosExemplo() async {
    final lote = _firestore.batch();
    for (final local in dadosExemplo) {
      lote.set(_locais.doc(), local.toMap());
    }
    await lote.commit();
  }
}
