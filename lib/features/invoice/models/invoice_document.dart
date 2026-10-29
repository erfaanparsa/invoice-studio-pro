import 'package:flutter/foundation.dart';
import 'package:invoice_studio_pro/features/invoice/models/invoice_item.dart';

@immutable
class InvoiceDocument {
  final String invoiceNumber;
  final String companyName;
  final String companyEmail;
  final String clientName;
  final String clientEmail;
  final DateTime issueDate;
  final DateTime dueDate;
  final double taxRatePercent;
  final String notes;
  final List<InvoiceItem> items;

  const InvoiceDocument({
    required this.invoiceNumber,
    required this.companyName,
    required this.companyEmail,
    required this.clientName,
    required this.clientEmail,
    required this.issueDate,
    required this.dueDate,
    this.taxRatePercent = 0.0,
    this.notes = '',
    this.items = const [],
  });

  int get totalQuantity =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold<double>(0.0, (sum, item) => sum + item.total);

  double get taxAmount => subtotal * (taxRatePercent / 100.0);

  double get grandTotal => subtotal + taxAmount;

  InvoiceDocument copyWith({
    String? invoiceNumber,
    String? companyName,
    String? companyEmail,
    String? clientName,
    String? clientEmail,
    DateTime? issueDate,
    DateTime? dueDate,
    double? taxRatePercent,
    String? notes,
    List<InvoiceItem>? items,
  }) {
    return InvoiceDocument(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      companyName: companyName ?? this.companyName,
      companyEmail: companyEmail ?? this.companyEmail,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      taxRatePercent: taxRatePercent ?? this.taxRatePercent,
      notes: notes ?? this.notes,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceDocument &&
        other.invoiceNumber == invoiceNumber &&
        other.companyName == companyName &&
        other.companyEmail == companyEmail &&
        other.clientName == clientName &&
        other.clientEmail == clientEmail &&
        other.issueDate == issueDate &&
        other.dueDate == dueDate &&
        other.taxRatePercent == taxRatePercent &&
        other.notes == notes &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode => Object.hash(
    invoiceNumber,
    companyName,
    companyEmail,
    clientName,
    clientEmail,
    issueDate,
    dueDate,
    taxRatePercent,
    notes,
    Object.hashAll(items),
  );
}
