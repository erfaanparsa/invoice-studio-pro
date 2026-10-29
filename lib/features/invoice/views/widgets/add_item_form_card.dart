import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/features/invoice/view_models/invoice_view_model.dart';

class AddItemFormCard extends ConsumerStatefulWidget {
  const AddItemFormCard({super.key});

  @override
  ConsumerState<AddItemFormCard> createState() => _AddItemFormCardState();
}

class _AddItemFormCardState extends ConsumerState<AddItemFormCard> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _unitPriceController = TextEditingController();
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _submitItem() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text.trim());
    final unitPrice = double.parse(
      _unitPriceController.text.trim().replaceAll(',', ''),
    );

    ref
        .read(invoiceViewModelProvider.notifier)
        .addItem(
          name: _nameController.text,
          description: _descriptionController.text,
          quantity: quantity,
          unitPrice: unitPrice,
        );

    _nameController.clear();
    _descriptionController.clear();
    _quantityController.text = '1';
    _unitPriceController.clear();
    _nameFocusNode.requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Line item added to invoice.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_box_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Line Item',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Service or Product Title *',
                  hintText: 'e.g., Cloud Infrastructure Setup',
                  prefixIcon: Icon(Icons.work_outline, size: 18),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Deliverables, sprint scope, or hourly breakdown',
                  prefixIcon: Icon(Icons.notes_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price (USD) *',
                        hintText: '1250.00',
                        prefixIcon: Icon(Icons.attach_money, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final parsed = double.tryParse(
                          value.trim().replaceAll(',', ''),
                        );
                        if (parsed == null || parsed < 0) {
                          return 'Enter valid USD';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitItem(),
                      decoration: const InputDecoration(
                        labelText: 'Qty *',
                        hintText: '1',
                        prefixIcon: Icon(Icons.numbers, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Min 1';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitItem,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Item to Invoice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
