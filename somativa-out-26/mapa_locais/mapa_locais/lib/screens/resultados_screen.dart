import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/filtros.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_inferior.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import '../widgets/seletor_cidade.dart';
import 'detalhes_screen.dart';

/// Tela 2 — Resultados: lista do Firestore com pesquisa, filtros e CRUD.
class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({
    super.key,
    this.cidade = todasCidades,
    this.pesquisa = '',
    this.somenteFavoritos = false,
  });

  final String cidade;
  final String pesquisa;
  final bool somenteFavoritos;

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final _service = LocalService();

  late final Stream<List<Local>> _locais = _service.listarLocais();
  late final TextEditingController _pesquisa =
      TextEditingController(text: widget.pesquisa);
  late String _cidade = widget.cidade;
  late bool _somenteFavoritos = widget.somenteFavoritos;
  String _categoria = todasCategorias;
  bool _populando = false;

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  // ----- Ações -----

  Future<void> _trocarCidade() async {
    final escolhida =
        await selecionarCidade(context, atual: _cidade, incluirTodas: true);
    if (escolhida != null) setState(() => _cidade = escolhida);
  }

  void _limparFiltros() {
    _pesquisa.clear();
    setState(() {
      _cidade = todasCidades;
      _categoria = todasCategorias;
      _somenteFavoritos = false;
    });
  }

  void _abrirDetalhes(Local local) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
    );
  }

  Future<void> _cadastrar() async {
    final mensageiro = ScaffoldMessenger.of(context);
    final salvou = await abrirFormularioLocal(
      context,
      cidadeInicial: _cidade == todasCidades ? null : _cidade,
      aoSalvar: _service.adicionar,
    );
    if (salvou) mostrarSucesso(mensageiro, 'Local cadastrado com sucesso!');
  }

  Future<void> _editar(Local local) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final salvou = await abrirFormularioLocal(
      context,
      local: local,
      aoSalvar: _service.atualizar,
    );
    if (salvou) mostrarSucesso(mensageiro, 'Local atualizado com sucesso!');
  }

  Future<void> _excluir(Local local) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final confirmou = await confirmarExclusao(context, local.nome);
    if (!confirmou) return;

    try {
      await _service.excluir(local.id);
      mostrarSucesso(mensageiro, '"${local.nome}" foi excluído.');
    } catch (erro) {
      mostrarErro(mensageiro, mensagemDeErro(erro));
    }
  }

  Future<void> _popularExemplos() async {
    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _populando = true);
    try {
      await _service.popularDadosExemplo();
      mostrarSucesso(mensageiro, 'Locais de exemplo cadastrados!');
    } catch (erro) {
      mostrarErro(mensageiro, mensagemDeErro(erro));
    } finally {
      if (mounted) setState(() => _populando = false);
    }
  }

  // ----- Interface -----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_somenteFavoritos ? 'Favoritos' : 'Resultados'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _pesquisa,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou categoria',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _pesquisa.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar pesquisa',
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(_pesquisa.clear),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Cores.borda),
              ),
              child: ListTile(
                onTap: _trocarCidade,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                dense: true,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(
                  _cidade == todasCidades ? 'Todas as cidades' : _cidade,
                  style: const TextStyle(fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                ChipFiltro(
                  rotulo: 'Favoritos',
                  icone: _somenteFavoritos ? Icons.favorite : Icons.favorite_border,
                  selecionado: _somenteFavoritos,
                  aoTocar: () =>
                      setState(() => _somenteFavoritos = !_somenteFavoritos),
                ),
                for (final categoria in [todasCategorias, ...categorias])
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChipFiltro(
                      rotulo: rotuloCategoria(categoria),
                      selecionado: _categoria == categoria,
                      aoTocar: () => setState(() => _categoria = categoria),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Local>>(
              stream: _locais,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return EstadoVazio(
                    icone: Icons.cloud_off,
                    titulo: 'Erro ao carregar os locais',
                    texto: mensagemDeErro(snapshot.error!),
                  );
                }

                final todos = snapshot.data ?? const <Local>[];

                if (todos.isEmpty) {
                  return EstadoVazio(
                    icone: Icons.inbox_outlined,
                    titulo: 'Nenhum local cadastrado',
                    texto: 'A coleção "locais" está vazia. Cadastre um local '
                        'pelo botão "Novo local" ou carregue os exemplos.',
                    acao: FilledButton.icon(
                      onPressed: _populando ? null : _popularExemplos,
                      icon: _populando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download),
                      label: const Text('Carregar locais de exemplo'),
                    ),
                  );
                }

                final filtrados = filtrarLocais(
                  todos,
                  texto: _pesquisa.text,
                  cidade: _cidade,
                  categoria: _categoria,
                  somenteFavoritos: _somenteFavoritos,
                );

                if (filtrados.isEmpty) {
                  return EstadoVazio(
                    icone: Icons.search_off,
                    titulo: 'Nenhum local encontrado',
                    texto: _somenteFavoritos
                        ? 'Nenhum favorito com esses filtros. Toque no '
                            'coração na tela de detalhes para favoritar.'
                        : 'Tente outro termo de pesquisa, cidade ou categoria.',
                    acao: OutlinedButton(
                      onPressed: _limparFiltros,
                      child: const Text('Limpar filtros'),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Text(
                        '${filtrados.length} '
                        '${filtrados.length == 1 ? 'local encontrado' : 'locais encontrados'}',
                        style: const TextStyle(color: Cores.textoSecundario),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                        itemCount: filtrados.length,
                        separatorBuilder: (context, indice) => const SizedBox(height: 10),
                        itemBuilder: (context, indice) {
                          final local = filtrados[indice];
                          return LocalCard(
                            local: local,
                            aoTocar: () => _abrirDetalhes(local),
                            aoEditar: () => _editar(local),
                            aoExcluir: () => _excluir(local),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cadastrar,
        icon: const Icon(Icons.add),
        label: const Text('Novo local'),
      ),
      bottomNavigationBar: BarraInferior(
        abaAtual: _somenteFavoritos ? Aba.favoritos : Aba.mapa,
      ),
    );
  }
}

/// Mensagem centralizada para lista vazia, filtro sem resultado ou erro.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Cores.textoSecundario),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Cores.textoSecundario),
            ),
            if (acao != null) ...[const SizedBox(height: 16), acao!],
          ],
        ),
      ),
    );
  }
}
