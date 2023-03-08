import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './screens/screens.dart';

part 'routes.g.dart';

@TypedGoRoute<MainScreenRoute>(
    path: '/wsf-routes', routes: <TypedGoRoute<GoRouteData>>[])
class MainScreenRoute extends GoRouteData {
  const MainScreenRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MainScreen();
}
