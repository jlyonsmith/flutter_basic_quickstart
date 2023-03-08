// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<GoRoute> get $appRoutes => [
      $mainScreenRoute,
    ];

GoRoute get $mainScreenRoute => GoRouteData.$route(
      path: '/wsf-routes',
      factory: $MainScreenRouteExtension._fromState,
    );

extension $MainScreenRouteExtension on MainScreenRoute {
  static MainScreenRoute _fromState(GoRouterState state) =>
      const MainScreenRoute();

  String get location => GoRouteData.$location(
        '/wsf-routes',
      );

  void go(BuildContext context) => context.go(location);

  void push(BuildContext context) => context.push(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);
}
