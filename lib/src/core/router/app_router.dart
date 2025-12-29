import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/app_check_debug/presentation/app_check_debug_page.dart';
import '../../features/admin_web/presentation/pages/admin_web_page.dart';
import '../../features/spa_browse/presentation/pages/category_spa_list_page.dart';
import '../../features/spa_browse/presentation/pages/category_subcategories_page.dart';
import '../../features/spa_browse/presentation/pages/subcategory_spa_list_page.dart';
import '../../features/spa_browse/presentation/pages/spa_services_page.dart';
import '../../features/spa_browse/presentation/pages/spa_detail_page.dart';
import '../../features/cart/presentation/pages/order_summary_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        final initialIndex = (settings.arguments as int?) ?? 0;
        return MaterialPageRoute(builder: (_) => HomePage(initialIndex: initialIndex));
      case '/debug-app-check':
        return MaterialPageRoute(builder: (_) => const AppCheckDebugPage());
      case '/admin-web':
        return MaterialPageRoute(builder: (_) => const AdminWebPage());
      case '/category-subcategories':
        final args = settings.arguments as CategorySubcategoriesArgs?;
        final category = args?.category ?? '';
        return MaterialPageRoute(
          builder: (_) => CategorySubcategoriesPage(category: category),
        );
      case '/category-spas':
        final args = settings.arguments as CategorySpasArgs?;
        final category = args?.category ?? '';
        return MaterialPageRoute(
          builder: (_) => CategorySpaListPage(category: category),
        );
      case '/subcategory-spas':
        if (settings.arguments is Map) {
          final map = settings.arguments as Map;
          final category = (map['category'] as String?) ?? '';
          final subcategory = (map['subcategory'] as String?) ?? '';
          return MaterialPageRoute(
            builder: (_) => SubcategorySpaListPage(
              category: category,
              subcategory: subcategory,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const Scaffold());
      case '/spa-services':
        final args = settings.arguments as SpaServicesArgs?;
        final spaId = args?.spaId ?? '';
        return MaterialPageRoute(builder: (_) => SpaServicesPage(spaId: spaId));
      case '/spa-detail':
        final args = settings.arguments as SpaDetailArgs?;
        final spaId = args?.spaId ?? '';
        return MaterialPageRoute(builder: (_) => SpaDetailPage(spaId: spaId));
      case '/order-summary':
        return MaterialPageRoute(builder: (_) => const OrderSummaryPage());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
