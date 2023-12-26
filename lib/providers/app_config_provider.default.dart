import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_config.dart';

// NOTE: This is the default app configuration for release builds!

// Global app configuration.
//
// You can change this as needed. The file should not be checked and will
// be overridden in a release build.
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig(
      // DEBUG: '/wsf-routes?from-terminal-id=3&to-terminal-id=7'
      initialLocation: '/',
    ));
