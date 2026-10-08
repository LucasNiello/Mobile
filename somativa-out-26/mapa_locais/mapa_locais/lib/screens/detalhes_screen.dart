import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';
import '../utils/horario.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_inferior.dart';
import '../widgets/imagem_local.dart';
import '../widgets/local_form.dart';
import 'mapa_screen.dart';

/// Tela 3 — Detalhes do local selecionado.
///
/// Recebe o [local] tocado na lista, mas também escuta o documento no
/// Firestore: assim, ao favoritar ou editar, a tela se atualiza sozinha.
class DetalhesScreen extends StatefulWidget {
  const DetalhesScreen({super.key, required this.local});

  final Local local;

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final _service = LocalService();
  late final Stream<Local?> _local = _service.observarLocal(widget.local.id);
  bool _alterandoFavorito = false;

  Future<void> _alternarFavorito(Local local) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final novoValor = !local.favorito;
    setState(() => _alterandoFavorito = true);
    try {
      await _service.alterarFavorito(local.id, novoValor);
      mostrarSucesso(
        mensageiro,
        novoValor ? 'Adicionado aos favoritos' : 'Removido dos favoritos',
      );
    } catch (erro) {
      mostrarErro(mensageiro, mensagemDeErro(erro));
    } finally {
      if (mounted) setState(() => _alterandoFavorito = false);
    }
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
    final navegador = Navigator.of(context);
    final confirmou = await confirmarExclusao(context, local.nome);
    if (!confirmou) return;

    // Volta para a lista antes de excluir: a tela de detalhes não teria mais
    // o que mostrar depois que o documento sumir.
    navegador.pop();
    try {
      await _service.excluir(local.id);
      mostrarSucesso(mensageiro, '"${local.nome}" foi excluído.');
    } catch (erro) {
      mostrarErro(mensageiro, mensagemDeErro(erro));
    }
  }

  void _verNoMapa(Local local) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MapaScreen(
          cidadeInicial: local.cidade,
          localDestacadoId: local.id,
        ),
      ),
      (rota) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Local?>(
      stream: _local,
      initialData: widget.local,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _TelaMensagem(
            icone: Icons.cloud_off,
            texto: mensagemDeErro(snapshot.error!),
          );
        }

        final local = snapshot.data;
        if (local == null) {
          return const _TelaMensagem(
            icone: Icons.delete_outline,
            texto: 'Este local foi excluído.',
          );
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: local.favorito
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                onPressed:
                    _alterandoFavorito ? null : () => _alternarFavorito(local),
                icon: Icon(
                  local.favorito ? Icons.favorite : Icons.favorite_border,
                  color: local.favorito ? Cores.favorito : Cores.texto,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              ImagemLocal(
                categoria: local.categoria,
                altura: 200,
                tamanhoIcone: 80,
                raio: 16,
              ),
              const SizedBox(height: 16),
              Text(
                local.nome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Cores.texto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                local.categoria,
                style: const TextStyle(
                    fontSize: 15, color: Cores.textoSecundario),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Cores.estrela),
                  const SizedBox(width: 4),
                  Text(
                    formatarNota(local.avaliacao),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Text(' de 5',
                      style: TextStyle(color: Cores.textoSecundario)),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  _InfoIcone(
                    icone: Icons.location_on_outlined,
                    texto: formatarDistancia(local.distancia),
                  ),
                  _InfoHorario(horario: local.horario),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AcaoCircular(
                    icone: Icons.edit_outlined,
                    rotulo: 'Editar',
                    aoTocar: () => _editar(local),
                  ),
                  _AcaoCircular(
                    icone: Icons.delete_outline,
                    rotulo: 'Excluir',
                    cor: Cores.erro,
                    aoTocar: () => _excluir(local),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Sobre',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                local.descricao.isEmpty
                    ? 'Sem descrição cadastrada.'
                    : local.descricao,
                style: const TextStyle(height: 1.4, color: Cores.texto),
              ),
              const Divider(height: 32),
              const Text(
                'Informações',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              _LinhaInfo(rotulo: 'Cidade', valor: local.cidade),
              _LinhaInfo(rotulo: 'Categoria', valor: local.categoria),
              _LinhaInfo(
                  rotulo: 'Avaliação', valor: '${formatarNota(local.avaliacao)} de 5'),
              _LinhaInfo(
                  rotulo: 'Distância', valor: formatarDistancia(local.distancia)),
              _LinhaInfo(rotulo: 'Horário', valor: local.horario),
              _LinhaInfo(rotulo: 'Favorito', valor: local.favorito ? 'Sim' : 'Não'),
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: FilledButton.icon(
                  onPressed: () => _verNoMapa(local),
                  icon: const Icon(Icons.location_on),
                  label: const Text('Ver no mapa'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const BarraInferior(abaAtual: Aba.mapa),
            ],
          ),
        );
      },
    );
  }
}

class _InfoIcone extends StatelessWidget {
  const _InfoIcone({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 20, color: Cores.textoSecundario),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(color: Cores.texto)),
      ],
    );
  }
}

class _InfoHorario extends StatelessWidget {
  const _InfoHorario({required this.horario});

  final String horario;

  @override
  Widget build(BuildContext context) {
    final status = statusDoHorario(horario, DateTime.now());
    if (status == null) {
      return _InfoIcone(icone: Icons.schedule, texto: horario);
    }
    final aberto = status == StatusHorario.aberto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 20, color: Cores.textoSecundario),
        const SizedBox(width: 6),
        Text(
          aberto ? 'Aberto' : 'Fechado',
          style: TextStyle(
            color: aberto ? Cores.sucesso : Cores.erro,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(' · $horario'),
      ],
    );
  }
}

class _AcaoCircular extends StatelessWidget {
  const _AcaoCircular({
    required this.icone,
    required this.rotulo,
    required this.aoTocar,
    this.cor = Cores.texto,
  });

  final IconData icone;
  final String rotulo;
  final VoidCallback aoTocar;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Cores.borda),
              ),
              child: Icon(icone, color: cor),
            ),
            const SizedBox(height: 6),
            Text(rotulo, style: TextStyle(color: cor, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(rotulo,
                style: const TextStyle(color: Cores.textoSecundario)),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(color: Cores.texto)),
          ),
        ],
      ),
    );
  }
}

class _TelaMensagem extends StatelessWidget {
  const _TelaMensagem({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 56, color: Cores.textoSecundario),
              const SizedBox(height: 12),
              Text(texto, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
