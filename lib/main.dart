import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/core/theme/app_theme.dart';
import 'package:invoice_studio_pro/core/theme/theme_provider.dart';
import 'package:invoice_studio_pro/features/invoice/views/screens/invoice_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: InvoiceStudioApp()));
}

class InvoiceStudioApp extends ConsumerWidget {
  const InvoiceStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Invoice Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const InvoiceScreen(),
    );
  }
}
