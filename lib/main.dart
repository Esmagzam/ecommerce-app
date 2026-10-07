import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/app_config.dart';
import 'core/constants/app_theme.dart';
import 'core/storage/cart_storage_service.dart';
import 'presentation/providers/core_providers.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage for offline cart
  await Hive.initFlutter();
  final cartStorage = CartStorageService();
  await cartStorage.init();

  runApp(
    ProviderScope(
      overrides: [
        cartStorageServiceProvider.overrideWithValue(cartStorage),
      ],
      child: const EcommerceApp(),
    ),
  );
}

class EcommerceApp extends ConsumerWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
