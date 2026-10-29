import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/core/utils/formatters.dart';
import 'package:invoice_studio_pro/features/invoice/view_models/invoice_view_model.dart';

class InvoiceHeaderCard extends ConsumerStatefulWidget {
  const InvoiceHeaderCard({super.key});

  @override
  ConsumerState<InvoiceHeaderCard> createState() => _InvoiceHeaderCardState();
}

class _InvoiceHeaderCardState extends ConsumerState<InvoiceHeaderCard> {
  late final TextEditingController _invoiceNumberController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _companyEmailController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientEmailController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final doc = ref.read(invoiceViewModelProvider).document;
    _invoiceNumberController = TextEditingController(text: doc.invoiceNumber);
    _companyNameController = TextEditingController(text: doc.companyName);
    _companyEmailController = TextEditingController(text: doc.companyEmail);
    _clientNameController = TextEditingController(text: doc.clientName);
    _clientEmailController = TextEditingController(text: doc.clientEmail);
    _taxRateController = TextEditingController(
      text: doc.taxRatePercent.toStringAsFixed(1),
    );
    _notesController = TextEditingController(text: doc.notes);
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _companyNameController.dispose();
    _companyEmailController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _taxRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncControllersWithDocument() {
    final doc = ref.read(invoiceViewModelProvider).document;
    if (_invoiceNumberController.text != doc.invoiceNumber) {
      _invoiceNumberController.text = doc.invoiceNumber;
    }
    if (_companyNameController.text != doc.companyName) {
      _companyNameController.text = doc.companyName;
    }
    if (_companyEmailController.text != doc.companyEmail) {
      _companyEmailController.text = doc.companyEmail;
    }
    if (_clientNameController.text != doc.clientName) {
      _clientNameController.text = doc.clientName;
    }
    if (_clientEmailController.text != doc.clientEmail) {
      _clientEmailController.text = doc.clientEmail;
    }
    final formattedTax = doc.taxRatePercent.toStringAsFixed(1);
    if (double.tryParse(_taxRateController.text) != doc.taxRatePercent) {
      _taxRateController.text = formattedTax;
    }
    if (_notesController.text != doc.notes) {
      _notesController.text = doc.notes;
    }
  }

  Future<void> _selectDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      invoiceViewModelProvider.select((s) => s.document.invoiceNumber),
      (_, __) => _syncControllersWithDocument(),
    );

    final issueDate = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.issueDate),
    );
    final dueDate = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.dueDate),
    );
    final notifier = ref.read(invoiceViewModelProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Invoice & Billing Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _invoiceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      hintText: 'INV-2026-0001',
                      prefixIcon: Icon(Icons.tag, size: 17),
                    ),
                    onChanged: (value) =>
                        notifier.updateMetadata(invoiceNumber: value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _taxRateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tax Rate',
                      hintText: '8.5',
                      suffixText: '%',
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value) ?? 0.0;
                      notifier.updateMetadata(
                        taxRatePercent: parsed.clamp(0.0, 100.0),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DatePickerTile(
                    label: 'Issue Date',
                    dateText: AppFormatters.formatDate(issueDate),
                    onTap: () => _selectDate(
                      context: context,
                      initialDate: issueDate,
                      onSelected: (date) =>
                          notifier.updateMetadata(issueDate: date),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DatePickerTile(
                    label: 'Due Date',
                    dateText: AppFormatters.formatDate(dueDate),
                    onTap: () => _selectDate(
                      context: context,
                      initialDate: dueDate,
                      onSelected: (date) =>
                          notifier.updateMetadata(dueDate: date),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'From (Your Organization)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 460;
                final children = [
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company / Sender Name',
                      hintText: 'Apex Digital Studio LLC',
                      prefixIcon: Icon(Icons.business_outlined, size: 18),
                    ),
                    onChanged: (value) =>
                        notifier.updateMetadata(companyName: value),
                  ),
                  const SizedBox(height: 12, width: 12),
                  TextFormField(
                    controller: _companyEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Sender Email',
                      hintText: 'billing@apexstudio.io',
                      prefixIcon: Icon(Icons.alternate_email, size: 18),
                    ),
                    onChanged: (value) =>
                        notifier.updateMetadata(companyEmail: value),
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: children[0]),
                      children[1],
                      Expanded(child: children[2]),
                    ],
                  );
                }
                return Column(children: children);
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Bill To (Client)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 460;
                final children = [
                  TextFormField(
                    controller: _clientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Client / Recipient Name',
                      hintText: 'Linear Global Technologies Inc.',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    onChanged: (value) =>
                        notifier.updateMetadata(clientName: value),
                  ),
                  const SizedBox(height: 12, width: 12),
                  TextFormField(
                    controller: _clientEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Client Email',
                      hintText: 'accounts@client.com',
                      prefixIcon: Icon(Icons.mail_outline, size: 18),
                    ),
                    onChanged: (value) =>
                        notifier.updateMetadata(clientEmail: value),
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: children[0]),
                      children[1],
                      Expanded(child: children[2]),
                    ],
                  );
                }
                return Column(children: children);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Payment Terms & Notes',
                hintText: 'Enter wire transfer instructions or terms...',
              ),
              onChanged: (value) => notifier.updateMetadata(notes: value),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String dateText;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 17),
        ),
        child: Text(
          dateText,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
