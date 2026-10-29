import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/features/invoice/models/invoice_document.dart';
import 'package:invoice_studio_pro/features/invoice/models/invoice_item.dart';
import 'package:invoice_studio_pro/features/invoice/repositories/invoice_repository.dart';
import 'package:invoice_studio_pro/features/invoice/services/pdf_invoice_service.dart';

@immutable
class InvoiceState {
  final InvoiceDocument document;
  final bool isGeneratingPdf;
  final String? errorMessage;

  const InvoiceState({
    required this.document,
    this.isGeneratingPdf = false,
    this.errorMessage,
  });

  InvoiceState copyWith({
    InvoiceDocument? document,
    bool? isGeneratingPdf,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InvoiceState(
      document: document ?? this.document,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class InvoiceViewModel extends Notifier<InvoiceState> {
  @override
  InvoiceState build() {
    final repository = ref.watch(invoiceRepositoryProvider);
    return InvoiceState(document: repository.loadInitialDemoInvoice());
  }

  void updateMetadata({
    String? invoiceNumber,
    String? companyName,
    String? companyEmail,
    String? clientName,
    String? clientEmail,
    DateTime? issueDate,
    DateTime? dueDate,
    double? taxRatePercent,
    String? notes,
  }) {
    state = state.copyWith(
      clearError: true,
      document: state.document.copyWith(
        invoiceNumber: invoiceNumber,
        companyName: companyName,
        companyEmail: companyEmail,
        clientName: clientName,
        clientEmail: clientEmail,
        issueDate: issueDate,
        dueDate: dueDate,
        taxRatePercent: taxRatePercent,
        notes: notes,
      ),
    );
  }

  void addItem({
    required String name,
    String description = '',
    required int quantity,
    required double unitPrice,
  }) {
    final newItem = InvoiceItem(
      id: 'item-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
    );

    state = state.copyWith(
      clearError: true,
      document: state.document.copyWith(
        items: [...state.document.items, newItem],
      ),
    );
  }

  void removeItemById(String id) {
    state = state.copyWith(
      clearError: true,
      document: state.document.copyWith(
        items: state.document.items.where((item) => item.id != id).toList(),
      ),
    );
  }

  void updateItemQuantity(String id, int newQuantity) {
    if (newQuantity <= 0) {
      removeItemById(id);
      return;
    }
    final updatedItems = state.document.items.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = state.copyWith(
      clearError: true,
      document: state.document.copyWith(items: updatedItems),
    );
  }

  void loadDemoSeedData() {
    final repository = ref.read(invoiceRepositoryProvider);
    state = InvoiceState(document: repository.loadInitialDemoInvoice());
  }

  void resetToBlankInvoice() {
    final repository = ref.read(invoiceRepositoryProvider);
    state = InvoiceState(document: repository.createBlankInvoice());
  }

  Future<bool> previewPdf() async {
    if (state.document.items.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Please add at least one line item before generating a PDF.',
      );
      return false;
    }

    state = state.copyWith(isGeneratingPdf: true, clearError: true);
    try {
      final pdfService = ref.read(pdfInvoiceServiceProvider);
      await pdfService.previewAndPrintPdf(state.document);
      state = state.copyWith(isGeneratingPdf: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isGeneratingPdf: false,
        errorMessage: 'Failed to generate PDF preview: $e',
      );
      return false;
    }
  }

  Future<bool> shareOrDownloadPdf() async {
    if (state.document.items.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please add at least one line item before exporting.',
      );
      return false;
    }

    state = state.copyWith(isGeneratingPdf: true, clearError: true);
    try {
      final pdfService = ref.read(pdfInvoiceServiceProvider);
      await pdfService.shareOrDownloadPdf(state.document);
      state = state.copyWith(isGeneratingPdf: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isGeneratingPdf: false,
        errorMessage: 'Failed to export PDF: $e',
      );
      return false;
    }
  }
}

final invoiceViewModelProvider =
    NotifierProvider<InvoiceViewModel, InvoiceState>(InvoiceViewModel.new);
