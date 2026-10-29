import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_studio_pro/core/theme/theme_provider.dart';
import 'package:invoice_studio_pro/core/utils/number_to_words.dart';
import 'package:invoice_studio_pro/features/invoice/view_models/invoice_view_model.dart';

void main() {
  group('InvoiceViewModel Business Logic Tests', () {
    test('Initial state loads pre-populated Recruiter Demo invoice items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(invoiceViewModelProvider);

      expect(state.document.items, isNotEmpty);
      expect(state.document.companyName, 'Apex Digital Studio LLC');
      expect(state.document.subtotal, 4900.00);
      expect(state.document.taxRatePercent, 8.5);
      expect(state.document.taxAmount, closeTo(416.50, 0.001));
      expect(state.document.grandTotal, closeTo(5316.50, 0.001));
    });

    test(
      'Adding, updating quantity, and removing items recalculates totals',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(invoiceViewModelProvider.notifier);
        notifier.resetToBlankInvoice();

        expect(
          container.read(invoiceViewModelProvider).document.items,
          isEmpty,
        );

        notifier.addItem(
          name: 'Mobile App Security Audit',
          description: 'OWASP MASVS compliance verification',
          quantity: 2,
          unitPrice: 750.0,
        );

        var doc = container.read(invoiceViewModelProvider).document;
        expect(doc.items.length, 1);
        expect(doc.subtotal, 1500.0);

        final itemId = doc.items.first.id;
        notifier.updateItemQuantity(itemId, 3);

        doc = container.read(invoiceViewModelProvider).document;
        expect(doc.subtotal, 2250.0);

        notifier.removeItemById(itemId);
        doc = container.read(invoiceViewModelProvider).document;
        expect(doc.items, isEmpty);
        expect(doc.grandTotal, 0.0);
      },
    );
  });

  group('ThemeModeNotifier Tests', () {
    test(
      'Toggles immediately to Light mode on first tap when system is Dark',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(themeModeProvider), ThemeMode.system);

        container
            .read(themeModeProvider.notifier)
            .toggleTheme(currentBrightness: Brightness.dark);

        expect(container.read(themeModeProvider), ThemeMode.light);

        container
            .read(themeModeProvider.notifier)
            .toggleTheme(currentBrightness: Brightness.light);

        expect(container.read(themeModeProvider), ThemeMode.dark);
      },
    );
  });

  group('NumberToWordsConverter Tests', () {
    test('Accurately converts USD amounts with cents to English words', () {
      expect(
        NumberToWordsConverter.convertUsdToWords(1250.50),
        'One Thousand Two Hundred Fifty Dollars and Fifty Cents',
      );
      expect(
        NumberToWordsConverter.convertUsdToWords(0.0),
        'Zero Dollars and Zero Cents',
      );
    });
  });
}
