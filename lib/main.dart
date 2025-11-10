import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/app_provider.dart';

// GlobalKey para acessar o HomeScreen de qualquer lugar
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

void main() {
  // Inicializar SQLite para desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const BarbeariaApp());
}

class BarbeariaApp extends StatelessWidget {
  const BarbeariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: MaterialApp(
        title: 'Barbearia Premium',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          primaryColor: const Color(0xFF8D6E63),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF8D6E63),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => HomeScreen(key: homeScreenKey),
        },
      ),
    );
  }
}
