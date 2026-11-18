import 'package:go_router/go_router.dart';

import '../../features/welcome/welcome_screen.dart';
import '../../features/module_selection/module_selection_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/admin_login_screen.dart';
import '../../features/admin/admin_home_screen.dart';
import '../../core/constants/app_constants.dart';
import '../services/supabase_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),

    GoRoute(
      path: '/module-selection',
      builder: (context, state) => const ModuleSelectionScreen(),
    ),

    GoRoute(
      path: '/login/:role',
      redirect: (context, state) {
        if (state.pathParameters['role'] == AppConstants.admin) {
          return AppConstants.adminLoginRoute;
        }
        return null;
      },
      builder: (context, state) {
        final role = state.pathParameters['role']!;

        return LoginScreen(role: role);
      },
    ),

    GoRoute(
      path: AppConstants.adminLoginRoute,
      builder: (context, state) => const AdminLoginScreen(),
    ),

    GoRoute(
      path: AppConstants.adminHomeRoute,
      redirect: (context, state) {
        if (SupabaseService.client?.auth.currentUser == null) {
          return AppConstants.adminLoginRoute;
        }
        return null;
      },
      builder: (context, state) => const AdminHomeScreen(),
    ),
  ],
);
