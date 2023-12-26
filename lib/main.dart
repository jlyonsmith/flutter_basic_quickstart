import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import './providers/providers.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final appPathService = await AppPathService.create();

  runApp(ProviderScope(overrides: [
    appPathProvider.overrideWithValue(appPathService),
  ], child: FlutterBasicQuickstartApp()));
}

class FlutterBasicQuickstartApp extends ConsumerWidget {
  final appRouter = AppRouter();

  FlutterBasicQuickstartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: 'Flutter Basic Quickstart',
      theme: _buildTheme(Brightness.dark),
      routerConfig: appRouter.config(
        deepLinkBuilder: (deepLink) async {
          return DeepLink.path(appConfig.initialLocation);
        },
      ),
    );
  }

  _buildTheme(Brightness brightness) {
    final baseTheme =
        ThemeData(brightness: brightness, primarySwatch: Colors.blue);

    return baseTheme.copyWith(
        textTheme: GoogleFonts.muktaTextTheme(baseTheme.textTheme));
  }
}
