/// Representa um estabelecimento salvo na coleção `locais` do Firestore.
///
/// O campo [id] não é gravado dentro do documento: ele é o próprio ID do
/// documento no Firestore e serve para editar, excluir e favoritar o registro.
class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;

  const Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
  });

  /// Converte um documento do Firestore em [Local].
  ///
  /// É tolerante a campos ausentes ou com tipo inesperado (por exemplo, um
  /// número digitado como texto no console), para que um documento mal
  /// preenchido não derrube a lista inteira.
  factory Local.fromMap(String id, Map<String, dynamic> data) {
    return Local(
      id: id,
      nome: _paraTexto(data['nome']),
      categoria: _paraTexto(data['categoria']),
      cidade: _paraTexto(data['cidade']),
      avaliacao: _paraDouble(data['avaliacao']),
      distancia: _paraDouble(data['distancia']),
      horario: _paraTexto(data['horario']),
      descricao: _paraTexto(data['descricao']),
      favorito: data['favorito'] == true,
    );
  }

  /// Converte o [Local] no mapa gravado no Firestore (sem o id).
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
    };
  }

  Local copyWith({
    String? id,
    String? nome,
    String? categoria,
    String? cidade,
    double? avaliacao,
    double? distancia,
    String? horario,
    String? descricao,
    bool? favorito,
  }) {
    return Local(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      cidade: cidade ?? this.cidade,
      avaliacao: avaliacao ?? this.avaliacao,
      distancia: distancia ?? this.distancia,
      horario: horario ?? this.horario,
      descricao: descricao ?? this.descricao,
      favorito: favorito ?? this.favorito,
    );
  }

  static String _paraTexto(dynamic valor) => valor?.toString() ?? '';

  static double _paraDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    if (valor is String) {
      return double.tryParse(valor.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }
}
