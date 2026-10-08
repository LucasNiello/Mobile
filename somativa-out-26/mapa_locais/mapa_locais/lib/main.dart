import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/mapa_screen.dart';
import 'services/auth_service.dart';
import 'utils/constantes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Garante um usuário autenticado (anônimo) antes de acessar o Firestore,
  // pois as regras de segurança negam acesso a quem não está autenticado.
  await AuthService.entrarAnonimamente();

  runApp(const MinhaAplicacao());
}

class MinhaAplicacao extends StatelessWidget {
  const MinhaAplicacao({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = ColorScheme.fromSeed(
      seedColor: Cores.escuro,
      primary: Cores.escuro,
      onPrimary: Colors.white,
      surface: Colors.white,
    );

    final bordaCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Cores.borda),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa de Locais',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: esquema,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Cores.texto,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: bordaCampo,
          enabledBorder: bordaCampo,
          focusedBorder: bordaCampo.copyWith(
            borderSide: const BorderSide(color: Cores.escuro, width: 1.4),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Color(0xFFE9EBEE),
          height: 66,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Cores.escuro,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MapaScreen(),
    );
  }
}
