import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';
import '../utils/horario.dart';
import '../utils/mensagens.dart';
import 'chip_filtro.dart';

/// Abre o formulário de cadastro/edição em um Bottom Sheet.
///
/// - Sem [local]: cadastro (RF05).
/// - Com [local]: edição, com os campos já preenchidos (RF06).
///
/// [aoSalvar] é quem grava no Firestore. Se der erro, o formulário continua
/// aberto mostrando a mensagem, para o usuário não perder o que digitou.
/// Retorna `true` quando salvou com sucesso.
Future<bool> abrirFormularioLocal(
  BuildContext context, {
  Local? local,
  String? cidadeInicial,
  required Future<void> Function(Local local) aoSalvar,
}) async {
  final salvou = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) => FormularioLocal(
      local: local,
      cidadeInicial: cidadeInicial,
      aoSalvar: aoSalvar,
    ),
  );
  return salvou == true;
}

class FormularioLocal extends StatefulWidget {
  const FormularioLocal({
    super.key,
    this.local,
    this.cidadeInicial,
    required this.aoSalvar,
  });

  final Local? local;
  final String? cidadeInicial;
  final Future<void> Function(Local local) aoSalvar;

  @override
  State<FormularioLocal> createState() => _FormularioLocalState();
}

class _FormularioLocalState extends State<FormularioLocal> {
  final _chaveFormulario = GlobalKey<FormState>();

  late final TextEditingController _nome;
  late final TextEditingController _avaliacao;
  late final TextEditingController _distancia;
  late final TextEditingController _horario;
  late final TextEditingController _descricao;

  String? _categoria;
  String? _cidade;
  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.local != null;

  @override
  void initState() {
    super.initState();
    final local = widget.local;
    _nome = TextEditingController(text: local?.nome ?? '');
    _avaliacao = TextEditingController(
      text: local == null ? '' : formatarNota(local.avaliacao),
    );
    _distancia = TextEditingController(
      text: local == null
          ? ''
          : local.distancia.toString().replaceAll('.', ','),
    );
    _horario = TextEditingController(text: local?.horario ?? '');
    _descricao = TextEditingController(text: local?.descricao ?? '');
    _categoria = _valorOuNulo(local?.categoria);
    _cidade = _valorOuNulo(local?.cidade) ?? widget.cidadeInicial;
  }

  @override
  void dispose() {
    _nome.dispose();
    _avaliacao.dispose();
    _distancia.dispose();
    _horario.dispose();
    _descricao.dispose();
    super.dispose();
  }

  static String? _valorOuNulo(String? texto) =>
      (texto == null || texto.isEmpty) ? null : texto;

  /// Inclui o valor atual nas opções caso o documento tenha sido criado no
  /// console com uma categoria/cidade fora da lista padrão.
  List<String> _opcoes(List<String> padrao, String? atual) =>
      [...padrao, if (atual != null && !padrao.contains(atual)) atual];

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_chaveFormulario.currentState!.validate()) return;

    final local = Local(
      id: widget.local?.id ?? '',
      nome: _nome.text.trim(),
      categoria: _categoria!,
      cidade: _cidade!,
      avaliacao: lerDecimal(_avaliacao.text)!,
      distancia: lerDecimal(_distancia.text)!,
      horario: _horario.text.trim(),
      descricao: _descricao.text.trim(),
      favorito: widget.local?.favorito ?? false,
    );

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      await widget.aoSalvar(local);
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = mensagemDeErro(erro);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tecladoAberto = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: tecladoAberto),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _chaveFormulario,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editando ? 'Editar local' : 'Novo local',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Academia Fitness',
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Informe o nome do local'
                    : null,
              ),
              const SizedBox(height: 4),
              _CampoOpcoes(
                rotulo: 'Categoria',
                opcoes: _opcoes(categorias, _categoria),
                valorInicial: _categoria,
                comIcones: true,
                mensagemErro: 'Escolha uma categoria',
                aoMudar: (valor) => _categoria = valor,
              ),
              const SizedBox(height: 16),
              _CampoOpcoes(
                rotulo: 'Cidade',
                opcoes: _opcoes(cidades, _cidade),
                valorInicial: _cidade,
                mensagemErro: 'Escolha uma cidade',
                aoMudar: (valor) => _cidade = valor,
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _avaliacao,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Avaliação',
                        hintText: '0 a 5',
                        prefixIcon: Icon(Icons.star_outline),
                      ),
                      validator: (valor) {
                        final nota = lerDecimal(valor ?? '');
                        if (nota == null) return 'Informe um número';
                        if (nota < 0 || nota > 5) return 'Entre 0 e 5';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _distancia,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Distância',
                        hintText: 'Ex.: 1,2',
                        suffixText: 'km',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (valor) {
                        final km = lerDecimal(valor ?? '');
                        if (km == null) return 'Informe um número';
                        if (km < 0) return 'Não pode ser negativa';
                        if (km > 1000) return 'Máximo 1000 km';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horario,
                decoration: const InputDecoration(
                  labelText: 'Horário de funcionamento',
                  hintText: '06:00 - 22:00',
                  helperText: 'Formato HH:MM - HH:MM ou "24 horas"',
                  prefixIcon: Icon(Icons.schedule),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Informe o horário';
                  }
                  return horarioValido(valor)
                      ? null
                      : 'Use o formato 06:00 - 22:00 ou "24 horas"';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricao,
                maxLines: 4,
                minLines: 2,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Conte o que o local oferece',
                  alignLabelWithHint: true,
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE9E7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Cores.erro),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_erro!,
                            style: const TextStyle(color: Cores.erro)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _salvando ? null : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _salvando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
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

/// Grupo de chips de escolha única integrado à validação do Form.
class _CampoOpcoes extends StatelessWidget {
  const _CampoOpcoes({
    required this.rotulo,
    required this.opcoes,
    required this.valorInicial,
    required this.mensagemErro,
    required this.aoMudar,
    this.comIcones = false,
  });

  final String rotulo;
  final List<String> opcoes;
  final String? valorInicial;
  final String mensagemErro;
  final ValueChanged<String> aoMudar;
  final bool comIcones;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: valorInicial,
      validator: (valor) => valor == null ? mensagemErro : null,
      builder: (campo) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Cores.texto,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opcao in opcoes)
                  ChipFiltro(
                    rotulo: opcao,
                    icone: comIcones ? iconeDaCategoria(opcao) : null,
                    selecionado: campo.value == opcao,
                    aoTocar: () {
                      campo.didChange(opcao);
                      aoMudar(opcao);
                    },
                  ),
              ],
            ),
            if (campo.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  campo.errorText!,
                  style: const TextStyle(color: Cores.erro, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
