import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import './providers/providers.dart';
import './routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final appPathService = await AppPathService.create();

  runApp(ProviderScope(overrides: [
    appPathProvider.overrideWithValue(appPathService),
  ], child: const FlutterBasicQuickstartApp()));
}

class FlutterBasicQuickstartApp extends ConsumerWidget {
  const FlutterBasicQuickstartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'Flutter Basic Quickstart',
      theme: _buildTheme(Brightness.dark),
      routerConfig: GoRouter(
          routes: $appRoutes,
          initialLocation: appConfig.initialLocation,
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
