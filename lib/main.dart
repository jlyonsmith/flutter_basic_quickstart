import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import './constants/constants.dart';
import './routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const FlutterBasicQuickstartApp());
}

class FlutterBasicQuickstartApp extends StatelessWidget {
  const FlutterBasicQuickstartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Quickstart App',
      theme: _buildTheme(Brightness.dark),
      routerConfig: GoRouter(
          routes: $appRoutes,
          initialLocation: AppConfig.initialLocation,
          debugLogDiagnostics: false),
    );
  }

  _buildTheme(Brightness brightness) {
    final baseTheme =
        ThemeData(brightness: brightness, primarySwatch: Colors.blue);

    return baseTheme.copyWith(
        textTheme: GoogleFonts.muktaTextTheme(baseTheme.textTheme));
  }
}
