import '../models/local.dart';
import 'constantes.dart';

/// Filtra a lista vinda do Firestore em memória (RF02 e RF04).
///
/// Optamos por filtrar no Flutter, como sugere o tutorial, porque a coleção é
/// pequena e isso permite combinar texto + cidade + categoria + favoritos sem
/// criar índices compostos no Firestore. O resultado volta ordenado pela
/// distância, do mais perto para o mais longe, como no wireframe.
List<Local> filtrarLocais(
  List<Local> locais, {
  String texto = '',
  String cidade = todasCidades,
  String categoria = todasCategorias,
  bool somenteFavoritos = false,
}) {
  final termo = normalizar(texto.trim());

  final filtrados = locais.where((local) {
    final correspondeCidade = cidade == todasCidades || local.cidade == cidade;

    final correspondeCategoria =
        categoria == todasCategorias || local.categoria == categoria;

    final correspondeTexto = termo.isEmpty ||
        normalizar(local.nome).contains(termo) ||
        normalizar(local.categoria).contains(termo);

    final correspondeFavorito = !somenteFavoritos || local.favorito;

    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto &&
        correspondeFavorito;
  }).toList();

  filtrados.sort((a, b) => a.distancia.compareTo(b.distancia));
  return filtrados;
}

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

/// Deixa o texto em minúsculas e sem acentos, para que "farmacia" encontre
/// "Farmácia" e "JUNDIAI" encontre "Jundiaí".
String normalizar(String texto) {
  final minusculo = texto.toLowerCase();
  final buffer = StringBuffer();
  for (final caractere in minusculo.split('')) {
    final posicao = _comAcento.indexOf(caractere);
    buffer.write(posicao >= 0 ? _semAcento[posicao] : caractere);
  }
  return buffer.toString();
}
