import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'states/estados_preajustes.dart';
import 'screens/pantalla_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ChronoTimerApp());
}

class ChronoTimerApp extends StatelessWidget {
  const ChronoTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProveedorPreajustes(),
      child: MaterialApp(
        title: 'ChronoTimer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A2A80)),
          useMaterial3: true,
        ),
        home: const PantallaPrincipal(),
      ),
    );
  }
}