import 'package:go_router/go_router.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/accidentes/views/estadisticas_screen.dart';
import '../../features/establecimientos/views/establecimientos_list_screen.dart';
import '../../features/establecimientos/views/establecimiento_detail_screen.dart';
import '../../features/establecimientos/views/establecimiento_form_screen.dart';
import '../../features/establecimientos/models/establecimiento.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/accidentes',
      name: 'accidentes',
      builder: (context, state) => const EstadisticasScreen(),
    ),
    GoRoute(
      path: '/establecimientos',
      name: 'establecimientos',
      builder: (context, state) => const EstablecimientosListScreen(),
      routes: [
        GoRoute(
          path: 'nuevo',
          name: 'establecimiento_nuevo',
          builder: (context, state) => const EstablecimientoFormScreen(),
        ),
        GoRoute(
          path: ':id',
          name: 'establecimiento_detalle',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return EstablecimientoDetailScreen(id: id);
          },
          routes: [
            GoRoute(
              path: 'editar',
              name: 'establecimiento_editar',
              builder: (context, state) {
                final establecimiento = state.extra as Establecimiento?;
                return EstablecimientoFormScreen(
                    establecimiento: establecimiento);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
