import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/core/theme/theme_provider.dart';
import 'package:invoice_studio_pro/features/invoice/view_models/invoice_view_model.dart';
import 'package:invoice_studio_pro/features/invoice/views/widgets/add_item_form_card.dart';
import 'package:invoice_studio_pro/features/invoice/views/widgets/invoice_header_card.dart';
import 'package:invoice_studio_pro/features/invoice/views/widgets/invoice_items_list.dart';
import 'package:invoice_studio_pro/features/invoice/views/widgets/invoice_summary_card.dart';

class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(
      invoiceViewModelProvider.select((state) => state.errorMessage),
      (previous, next) {
        if (next != null && next.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );

    ref.watch(themeModeProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompactScreen = MediaQuery.sizeOf(context).width < 600;
    final invoiceNotifier = ref.read(invoiceViewModelProvider.notifier);

    void handleLoadDemo() {
      invoiceNotifier.loadDemoSeedData();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo invoice data restored.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    void handleClearInvoice() {
      invoiceNotifier.resetToBlankInvoice();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice cleared.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description_outlined,
                color: theme.colorScheme.onPrimaryContainer,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Invoice Studio Pro', maxLines: 1),
              ),
            ),
          ],
        ),
        actions: [
          if (isCompactScreen) ...[
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: handleLoadDemo,
              tooltip: 'Load Demo Data',
              icon: const Icon(Icons.auto_awesome_outlined, size: 20),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: handleClearInvoice,
              tooltip: 'Clear Invoice',
              icon: const Icon(Icons.restart_alt_outlined, size: 20),
            ),
          ] else ...[
            TextButton.icon(
              onPressed: handleLoadDemo,
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: const Text('Demo Data'),
            ),
            TextButton.icon(
              onPressed: handleClearInvoice,
              icon: const Icon(Icons.restart_alt_outlined, size: 18),
              label: const Text('Clear'),
            ),
          ],
          IconButton(
            visualDensity: isCompactScreen
                ? VisualDensity.compact
                : VisualDensity.standard,
            onPressed: () => ref
                .read(themeModeProvider.notifier)
                .toggleTheme(currentBrightness: theme.brightness),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktopOrTablet = constraints.maxWidth >= 900;

                if (isDesktopOrTablet) {
                  return const SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              InvoiceHeaderCard(),
                              SizedBox(height: 20),
                              AddItemFormCard(),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              InvoiceSummaryCard(),
                              SizedBox(height: 20),
                              InvoiceItemsList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      InvoiceHeaderCard(),
                      SizedBox(height: 16),
                      AddItemFormCard(),
                      SizedBox(height: 16),
                      InvoiceItemsList(),
                      SizedBox(height: 16),
                      InvoiceSummaryCard(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
