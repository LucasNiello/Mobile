import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/filtros.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_inferior.dart';
import '../widgets/mapa_representacao.dart';
import '../widgets/seletor_cidade.dart';
import 'detalhes_screen.dart';
import 'resultados_screen.dart';

/// Tela 1 — Mapa principal: cidade, pesquisa, mapa e marcadores.
class MapaScreen extends StatefulWidget {
  const MapaScreen({
    super.key,
    this.cidadeInicial = 'São Paulo',
    this.localDestacadoId,
  });

  final String cidadeInicial;

  /// Usado pelo botão "Ver no mapa" da tela de detalhes.
  final String? localDestacadoId;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _service = LocalService();
  final _pesquisa = TextEditingController();

  // O Stream é criado uma vez só; recriá-lo a cada build reabriria a escuta.
  late final Stream<List<Local>> _locais = _service.listarLocais();
  late String _cidade = widget.cidadeInicial;
  late String? _destaque = widget.localDestacadoId;

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  Future<void> _trocarCidade() async {
    final escolhida = await selecionarCidade(context, atual: _cidade);
    if (escolhida != null && escolhida != _cidade) {
      setState(() {
        _cidade = escolhida;
        _destaque = null;
      });
    }
  }

  void _abrirResultados() {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          cidade: _cidade,
          pesquisa: _pesquisa.text.trim(),
        ),
      ),
    );
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CabecalhoCidade(cidade: _cidade, aoTocar: _trocarCidade),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _pesquisa,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _abrirResultados(),
                decoration: InputDecoration(
                  hintText: 'Buscar locais ou categorias...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Pesquisar',
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _abrirResultados,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Local>>(
                stream: _locais,
                builder: (context, snapshot) {
                  final locaisDaCidade = filtrarLocais(
                    snapshot.data ?? const [],
                    cidade: _cidade,
                  );

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: MapaRepresentacao(
                          cidade: _cidade,
                          locais: locaisDaCidade,
                          localDestacadoId: _destaque,
                          aoAbrirLocal: _abrirDetalhes,
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (snapshot.hasError)
                        _Aviso(
                          icone: Icons.cloud_off,
                          texto: mensagemDeErro(snapshot.error!),
                        )
                      else if (locaisDaCidade.isEmpty)
                        _Aviso(
                          icone: Icons.info_outline,
                          texto: 'Nenhum local cadastrado em $_cidade. '
                              'Abra os resultados para cadastrar.',
                        ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: FilledButton.icon(
                          onPressed: _abrirResultados,
                          icon: const Icon(Icons.list_alt),
                          label: Text(
                            'Ver ${locaisDaCidade.length} '
                            '${locaisDaCidade.length == 1 ? 'resultado' : 'resultados'} '
                            'em $_cidade',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BarraInferior(abaAtual: Aba.mapa),
    );
  }
}

class _CabecalhoCidade extends StatelessWidget {
  const _CabecalhoCidade({required this.cidade, required this.aoTocar});

  final String cidade;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, size: 30, color: Cores.texto),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cidade selecionada',
                    style: TextStyle(fontSize: 12, color: Cores.textoSecundario),
                  ),
                  Row(
                    children: [
                      Text(
                        cidade,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Cores.texto,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
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

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icone, color: Cores.textoSecundario),
              const SizedBox(width: 10),
              Expanded(child: Text(texto)),
            ],
          ),
        ),
      ),
    );
  }
}
