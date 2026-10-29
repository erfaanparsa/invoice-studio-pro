import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/features/invoice/models/invoice_document.dart';
import 'package:invoice_studio_pro/features/invoice/models/invoice_item.dart';

abstract interface class InvoiceRepository {
  InvoiceDocument loadInitialDemoInvoice();
  InvoiceDocument createBlankInvoice();
}

class MockInvoiceRepository implements InvoiceRepository {
  const MockInvoiceRepository();

  @override
  InvoiceDocument loadInitialDemoInvoice() {
    final now = DateTime.now();
    return InvoiceDocument(
      invoiceNumber: 'INV-2026-0842',
      companyName: 'Apex Digital Studio LLC',
      companyEmail: 'billing@apexstudio.io',
      clientName: 'Linear Global Technologies Inc.',
      clientEmail: 'accounts-payable@linear-tech.com',
      issueDate: now,
      dueDate: now.add(const Duration(days: 14)),
      taxRatePercent: 8.5,
      notes: 'Thank you for your business. Please remit payment via ACH or wire transfer within 14 days of invoice date.',
      items: const [
        InvoiceItem(
          id: 'seed-1',
          name: 'Flutter Enterprise Architecture Audit',
          description: 'Comprehensive codebase review, Riverpod 3 migration roadmap, and performance profiling.',
          quantity: 1,
          unitPrice: 1850.00,
        ),
        InvoiceItem(
          id: 'seed-2',
          name: 'Material 3 Design System & UI Kit',
          description: 'Custom responsive component library with Light/Dark theme tokens and interactive states.',
          quantity: 2,
          unitPrice: 1200.00,
        ),
        InvoiceItem(
          id: 'seed-3',
          name: 'Automated CI/CD & Web Deployment Setup',
          description: 'GitHub Actions pipeline for automated unit testing and multi-platform web builds.',
          quantity: 1,
          unitPrice: 650.00,
        ),
      ],
    );
  }

  @override
  InvoiceDocument createBlankInvoice() {
    final now = DateTime.now();
    return InvoiceDocument(
      invoiceNumber:
          'INV-${now.year}-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      companyName: 'Apex Digital Studio LLC',
      companyEmail: 'billing@apexstudio.io',
      clientName: '',
      clientEmail: '',
      issueDate: now,
      dueDate: now.add(const Duration(days: 14)),
      taxRatePercent: 0.0,
      notes: 'Thank you for your business. Payment is due within 14 days.',
      items: const [],
    );
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return const MockInvoiceRepository();
});
