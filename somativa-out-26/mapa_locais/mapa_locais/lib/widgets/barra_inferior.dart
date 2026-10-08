import 'package:flutter/material.dart';

import '../screens/resultados_screen.dart';
import '../services/auth_service.dart';
import '../utils/constantes.dart';

enum Aba { mapa, favoritos, perfil }

/// Barra inferior do wireframe (Mapa, Favoritos, Perfil).
///
/// O app continua com três telas principais: "Favoritos" abre a tela de
/// Resultados já filtrada por favoritos (como sugere o tutorial) e "Perfil"
/// abre apenas um Bottom Sheet informativo.
class BarraInferior extends StatelessWidget {
  const BarraInferior({super.key, required this.abaAtual});

  final Aba abaAtual;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: abaAtual.index,
      onDestinationSelected: (indice) => _navegar(context, Aba.values[indice]),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _navegar(BuildContext context, Aba destino) {
    if (destino == abaAtual) return;
    final navegador = Navigator.of(context);

    switch (destino) {
      case Aba.mapa:
        navegador.popUntil((rota) => rota.isFirst);
      case Aba.favoritos:
        navegador.popUntil((rota) => rota.isFirst);
        navegador.push(
          MaterialPageRoute(
            builder: (_) => const ResultadosScreen(somenteFavoritos: true),
          ),
        );
      case Aba.perfil:
        _mostrarPerfil(context);
    }
  }

  void _mostrarPerfil(BuildContext context) {
    final id = AuthService.idUsuario;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Cores.fundoCampo,
                      child: Icon(Icons.person, color: Cores.escuro, size: 28),
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visitante',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Sessão anônima do Firebase',
                          style: TextStyle(color: Cores.textoSecundario),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  id == null
                      ? 'Não autenticado: ative o login anônimo no Firebase.'
                      : 'ID da sessão: ${id.length > 10 ? '${id.substring(0, 10)}…' : id}',
                  style: const TextStyle(color: Cores.textoSecundario),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O login anônimo permite que as regras do Firestore aceitem '
                  'somente usuários autenticados, sem pedir cadastro.',
                  style: TextStyle(color: Cores.textoSecundario),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
