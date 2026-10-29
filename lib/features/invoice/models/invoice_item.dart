import 'package:flutter/foundation.dart';

@immutable
class InvoiceItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.id,
    required this.name,
    this.description = '',
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  InvoiceItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvoiceItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.quantity == quantity &&
        other.unitPrice == unitPrice;
  }

  @override
  int get hashCode => Object.hash(id, name, description, quantity, unitPrice);
}
