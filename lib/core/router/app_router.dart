import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/deliveries/screens/delivery_detail_screen.dart';
import '../../features/deliveries/screens/deliveries_list_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/history/screens/history_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final isGoingToAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/splash';

        if (!isLoggedIn && !isGoingToAuth) {
          return '/login';
        }
        if (isLoggedIn && state.matchedLocation == '/login') {
          return '/dashboard';
        }
        return null;
      },
      refreshListenable: auth,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/deliveries',
          builder: (context, state) => const DeliveriesListScreen(),
        ),
        GoRoute(
          path: '/delivery/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return DeliveryDetailScreen(deliveryId: id);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
      ],
    );
  }
}
