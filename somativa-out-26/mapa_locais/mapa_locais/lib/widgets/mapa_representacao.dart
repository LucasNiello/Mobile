import 'dart:math';

import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';

/// Representação visual de um mapa (exigida na Tela 1).
///
/// Não é um mapa real (isso é o desafio extra "Mapa real"): as ruas são
/// desenhadas com [CustomPainter] e cada cidade gera um traçado diferente.
/// Como o modelo `Local` não tem latitude/longitude, a posição de cada
/// marcador é calculada a partir do ID do documento — sempre a mesma para o
/// mesmo local, o que permite o botão "Ver no mapa" destacar o marcador certo.
class MapaRepresentacao extends StatefulWidget {
  const MapaRepresentacao({
    super.key,
    required this.cidade,
    required this.locais,
    required this.aoAbrirLocal,
    this.localDestacadoId,
  });

  final String cidade;
  final List<Local> locais;
  final ValueChanged<Local> aoAbrirLocal;
  final String? localDestacadoId;

  @override
  State<MapaRepresentacao> createState() => _MapaRepresentacaoState();
}

class _MapaRepresentacaoState extends State<MapaRepresentacao> {
  final _transformacao = TransformationController();
  String? _selecionadoId;
  bool _mostrarNomes = false;

  @override
  void initState() {
    super.initState();
    _selecionadoId = widget.localDestacadoId;
  }

  @override
  void didUpdateWidget(covariant MapaRepresentacao antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.cidade != widget.cidade) {
      _selecionadoId = null;
      _transformacao.value = Matrix4.identity();
    }
    if (antigo.localDestacadoId != widget.localDestacadoId) {
      _selecionadoId = widget.localDestacadoId;
    }
  }

  @override
  void dispose() {
    _transformacao.dispose();
    super.dispose();
  }

  void _centralizar() {
    setState(() {
      _transformacao.value = Matrix4.identity();
      _selecionadoId = null;
    });
  }

  void _tocarMarcador(Local local) {
    if (_selecionadoId == local.id) {
      widget.aoAbrirLocal(local);
    } else {
      setState(() => _selecionadoId = local.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posicoes = calcularPosicoes(widget.locais.map((l) => l.id).toList());

    // O marcador selecionado é desenhado por último para ficar por cima.
    final ordenados = [...widget.locais]
      ..sort((a, b) {
        if (a.id == _selecionadoId) return 1;
        if (b.id == _selecionadoId) return -1;
        return posicoes[a.id]!.dy.compareTo(posicoes[b.id]!.dy);
      });

    return LayoutBuilder(
      builder: (context, restricoes) {
        final largura = restricoes.maxWidth;
        final altura = restricoes.maxHeight;

        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transformacao,
              minScale: 1,
              maxScale: 3.5,
              child: SizedBox(
                width: largura,
                height: altura,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => setState(() => _selecionadoId = null),
                        child: CustomPaint(
                          painter: _PintorMapa(semente: _hash(widget.cidade)),
                        ),
                      ),
                    ),
                    Positioned(
                      left: largura / 2,
                      top: altura / 2,
                      child: const FractionalTranslation(
                        translation: Offset(-0.5, -0.5),
                        child: _PontoUsuario(),
                      ),
                    ),
                    for (final local in ordenados)
                      Positioned(
                        left: posicoes[local.id]!.dx * largura,
                        top: posicoes[local.id]!.dy * altura,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -1),
                          child: _Marcador(
                            local: local,
                            selecionado: local.id == _selecionadoId,
                            mostrarNome: _mostrarNomes,
                            aoTocar: () => _tocarMarcador(local),
                            aoAbrir: () => widget.aoAbrirLocal(local),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 92,
              child: Column(
                children: [
                  _BotaoRedondo(
                    icone: Icons.my_location,
                    dica: 'Centralizar na minha posição',
                    aoTocar: _centralizar,
                  ),
                  const SizedBox(height: 12),
                  _BotaoRedondo(
                    icone: _mostrarNomes ? Icons.layers : Icons.layers_outlined,
                    dica: _mostrarNomes ? 'Ocultar nomes' : 'Mostrar nomes',
                    ativo: _mostrarNomes,
                    aoTocar: () => setState(() => _mostrarNomes = !_mostrarNomes),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Calcula a posição relativa (0 a 1) de cada marcador a partir do ID.
///
/// É determinística: o mesmo ID sempre cai no mesmo ponto. Afasta marcadores
/// do centro (onde fica o usuário) e evita que dois fiquem sobrepostos.
Map<String, Offset> calcularPosicoes(List<String> ids) {
  const minX = 0.14, maxX = 0.86, minY = 0.22, maxY = 0.76;
  const distanciaMinima = 0.1;
  const centro = Offset(0.5, 0.5);
  final resultado = <String, Offset>{};

  // Ordena para que o resultado não dependa da ordem em que os dados chegam.
  for (final id in [...ids]..sort()) {
    final aleatorio = Random(_hash(id));
    Offset? melhor;
    var maiorFolga = -1.0;

    // Sorteia candidatos (sempre os mesmos para o mesmo id) e fica com o
    // primeiro que não colide; se nenhum servir, usa o mais afastado.
    for (var tentativa = 0; tentativa < 60; tentativa++) {
      final candidato = Offset(
        minX + aleatorio.nextDouble() * (maxX - minX),
        minY + aleatorio.nextDouble() * (maxY - minY),
      );
      final folga = [
        (candidato - centro).distance,
        for (final outro in resultado.values) (candidato - outro).distance,
      ].reduce(min);

      if (folga > maiorFolga) {
        maiorFolga = folga;
        melhor = candidato;
      }
      if (folga >= distanciaMinima) break;
    }
    resultado[id] = melhor!;
  }
  return resultado;
}

/// Hash FNV-1a de 32 bits: estável entre execuções (ao contrário de
/// `String.hashCode`, que não tem essa garantia).
int _hash(String texto) {
  var h = 0x811c9dc5;
  for (final codigo in texto.codeUnits) {
    h ^= codigo;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

class _Marcador extends StatelessWidget {
  const _Marcador({
    required this.local,
    required this.selecionado,
    required this.mostrarNome,
    required this.aoTocar,
    required this.aoAbrir,
  });

  final Local local;
  final bool selecionado;
  final bool mostrarNome;
  final VoidCallback aoTocar;
  final VoidCallback aoAbrir;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selecionado)
          _BalaoDetalhado(local: local, aoTocar: aoAbrir)
        else if (mostrarNome)
          _BalaoSimples(nome: local.nome, aoTocar: aoTocar),
        GestureDetector(
          onTap: aoTocar,
          child: Semantics(
            button: true,
            label: local.nome,
            child: Icon(
              Icons.location_on,
              size: selecionado ? 48 : 38,
              color: selecionado ? Cores.favorito : Cores.escuro,
              shadows: const [
                Shadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BalaoSimples extends StatelessWidget {
  const _BalaoSimples({required this.nome, required this.aoTocar});

  final String nome;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 130),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 6)],
        ),
        child: Text(
          nome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _BalaoDetalhado extends StatelessWidget {
  const _BalaoDetalhado({required this.local, required this.aoTocar});

  final Local local;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: aoTocar,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Cores.estrela),
                      const SizedBox(width: 2),
                      Text(
                        '${formatarNota(local.avaliacao)} · ${local.categoria}',
                        style: const TextStyle(
                            fontSize: 11, color: Cores.textoSecundario),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PontoUsuario extends StatelessWidget {
  const _PontoUsuario();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x332F80ED),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2F80ED),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 4)],
        ),
      ),
    );
  }
}

class _BotaoRedondo extends StatelessWidget {
  const _BotaoRedondo({
    required this.icone,
    required this.dica,
    required this.aoTocar,
    this.ativo = false,
  });

  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dica,
      child: Material(
        color: ativo ? Cores.escuro : Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: aoTocar,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icone, color: ativo ? Colors.white : Cores.escuro),
          ),
        ),
      ),
    );
  }
}

/// Desenha quarteirões, avenidas, um parque e um rio. A [semente] (derivada do
/// nome da cidade) muda o traçado para cada cidade parecer diferente.
class _PintorMapa extends CustomPainter {
  _PintorMapa({required this.semente});

  final int semente;

  @override
  void paint(Canvas canvas, Size tamanho) {
    final aleatorio = Random(semente);
    final w = tamanho.width;
    final h = tamanho.height;

    canvas.drawRect(Offset.zero & tamanho, Paint()..color = const Color(0xFFECEEF1));

    // Ruas menores em uma grade levemente girada.
    final angulo = (aleatorio.nextDouble() - 0.5) * 0.7;
    final diagonal = tamanho.longestSide * 1.6;
    final espacoX = 44.0 + aleatorio.nextInt(16);
    final espacoY = 52.0 + aleatorio.nextInt(16);
    final ruaMenor = Paint()
      ..color = Colors.white
      ..strokeWidth = 5;

    canvas.save();
    canvas.translate(w / 2, h / 2);
    canvas.rotate(angulo);
    for (var x = -diagonal; x <= diagonal; x += espacoX) {
      canvas.drawLine(Offset(x, -diagonal), Offset(x, diagonal), ruaMenor);
    }
    for (var y = -diagonal; y <= diagonal; y += espacoY) {
      canvas.drawLine(Offset(-diagonal, y), Offset(diagonal, y), ruaMenor);
    }
    canvas.restore();

    // Parque.
    final parque = Rect.fromLTWH(
      w * (0.05 + aleatorio.nextDouble() * 0.45),
      h * (0.55 + aleatorio.nextDouble() * 0.2),
      w * 0.32,
      h * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(parque, const Radius.circular(22)),
      Paint()..color = const Color(0xFFD6E7CF),
    );

    // Rio cruzando o mapa.
    final inicioRio = h * (0.2 + aleatorio.nextDouble() * 0.5);
    final rio = Path()
      ..moveTo(-20, inicioRio)
      ..cubicTo(
        w * 0.3, inicioRio + h * (aleatorio.nextDouble() * 0.4 - 0.2),
        w * 0.6, inicioRio + h * (aleatorio.nextDouble() * 0.5 - 0.1),
        w + 20, inicioRio + h * (aleatorio.nextDouble() * 0.5 - 0.15),
      );
    canvas.drawPath(
      rio,
      Paint()
        ..color = const Color(0xFFC4D3E2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.round,
    );

    // Avenidas (com borda) por cima do rio, como pontes.
    final bordaAvenida = Paint()
      ..color = const Color(0xFFD5D9DF)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    final avenida = Paint()
      ..color = Colors.white
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    final avenidas = <(Offset, Offset)>[
      (Offset(0, h * aleatorio.nextDouble()), Offset(w, h * aleatorio.nextDouble())),
      (Offset(w * aleatorio.nextDouble(), 0), Offset(w * aleatorio.nextDouble(), h)),
      (Offset(w * (0.6 + aleatorio.nextDouble() * 0.4), 0), Offset(0, h * (0.6 + aleatorio.nextDouble() * 0.4))),
    ];
    for (final (inicio, fim) in avenidas) {
      canvas.drawLine(inicio, fim, bordaAvenida);
    }
    for (final (inicio, fim) in avenidas) {
      canvas.drawLine(inicio, fim, avenida);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorMapa antigo) => antigo.semente != semente;
}
