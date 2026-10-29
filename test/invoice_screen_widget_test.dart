import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_studio_pro/main.dart';

void main() {
  testWidgets(
    'InvoiceStudioApp renders initial demo items and supports clearing invoice',
    (WidgetTester tester) async {
      // Set a standard desktop viewport for comprehensive widget tree rendering
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: InvoiceStudioApp()));
      await tester.pumpAndSettle();

      // Verify AppBar title and section headers are rendered
      expect(find.text('Invoice Studio Pro'), findsOneWidget);
      expect(find.text('Invoice & Billing Details'), findsOneWidget);
      expect(find.text('Financial Summary'), findsOneWidget);

      // Verify pre-populated Recruiter Demo Mode items exist
      expect(
        find.text('Flutter Enterprise Architecture Audit'),
        findsOneWidget,
      );
      expect(find.text('\$5,316.50'), findsOneWidget);

      // Trigger 'Clear' action and verify empty state appears
      final clearButton = find.text('Clear');
      expect(clearButton, findsOneWidget);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      expect(find.text('No billable items added yet'), findsOneWidget);
      expect(find.text('Restore Demo Seed Data'), findsOneWidget);
    },
  );
}
