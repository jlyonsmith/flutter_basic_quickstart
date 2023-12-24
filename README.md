# Flutter Quick Start Template

This is a Flutter `quickstart` template for use with the [`git_extra`](https://github.com/jlyonsmith/git_extra_rs) tool.

- [x] Generated from `flutter create`
- [x] Generates a `next` flavor for iOS & Android with a beta icon and unique bundle ID/application ID
- [x] Tweak analysis to prefer relative imports, single quotes, Flutter style TODO's, and allow `print()`
- [x] Add commonly used directories under `lib`
- [x] Add `scratch` directory
- [x] Add `assets` and `raw_assets` directories
- [x] Add [`flutter_svg`](https://pub.dev/packages/flutter_svg) and related packages
- [x] [`justfile`](https://crates.io/crates/just) containing scripts to:
  - [x] Clean SVG using [svgcleaner](https://crates.io/crates/svgcleaner)
  - [x] Compile SVG's into `vector_graphics` binary format for smaller images
  - [x] Generate all `build_runner` files
  - [x] Apple and Android generation bundle generation
  - [x] CLI Publish to Apple App Store
  - [x] CLI Publish to Google Play Store
- [x] Use [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash)
- [x] Add [`google_fonts`](https://pub.dev/packages/google_fonts) with [Mukta](https://fonts.google.com/specimen/Mukta) font
- [x] Call `WidgetsFlutterBinding.ensureInitialized()` in `main()`
- [x] Add [`icons_launcher`](https://pub.dev/packages/icons_launcher) for consistent app icons
- [x] Add [`stampver`](https://crates.io/crates/stampver) versioning support
- [x] Adds a coverage file and badge
- [x] Add [`go_router`](https://pub.dev/packages/go_router) with default routes
