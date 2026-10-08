import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';
import 'imagem_local.dart';

/// Item da lista de resultados: nome, categoria, distância e avaliação,
/// com menu para editar ou excluir.
class LocalCard extends StatelessWidget {
  const LocalCard({
    super.key,
    required this.local,
    required this.aoTocar,
    required this.aoEditar,
    required this.aoExcluir,
  });

  final Local local;
  final VoidCallback aoTocar;
  final VoidCallback aoEditar;
  final VoidCallback aoExcluir;

  @override
  Widget build(BuildContext context) {
    const estiloSecundario =
        TextStyle(color: Cores.textoSecundario, fontSize: 13);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Cores.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ImagemLocal(
                categoria: local.categoria,
                largura: 76,
                altura: 76,
                tamanhoIcone: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            local.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Cores.texto,
                            ),
                          ),
                        ),
                        if (local.favorito) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite,
                              size: 16, color: Cores.favorito),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${local.categoria} · ${local.cidade}',
                      style: estiloSecundario,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 15, color: Cores.textoSecundario),
                        const SizedBox(width: 3),
                        Text(formatarDistancia(local.distancia),
                            style: estiloSecundario),
                        const SizedBox(width: 14),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Cores.estrela),
                        const SizedBox(width: 3),
                        Text(
                          formatarNota(local.avaliacao),
                          style: estiloSecundario.copyWith(
                            color: Cores.texto,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                icon: const Icon(Icons.more_vert, color: Cores.textoSecundario),
                onSelected: (opcao) {
                  if (opcao == 'editar') aoEditar();
                  if (opcao == 'excluir') aoExcluir();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Cores.erro),
                      title: Text('Excluir',
                          style: TextStyle(color: Cores.erro)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
