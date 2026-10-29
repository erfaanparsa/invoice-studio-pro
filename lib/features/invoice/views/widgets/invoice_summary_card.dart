import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_studio_pro/core/utils/formatters.dart';
import 'package:invoice_studio_pro/core/utils/number_to_words.dart';
import 'package:invoice_studio_pro/features/invoice/view_models/invoice_view_model.dart';

class InvoiceSummaryCard extends ConsumerWidget {
  const InvoiceSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.subtotal),
    );
    final taxRate = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.taxRatePercent),
    );
    final taxAmount = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.taxAmount),
    );
    final grandTotal = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.grandTotal),
    );
    final totalQty = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.totalQuantity),
    );
    final isGenerating = ref.watch(
      invoiceViewModelProvider.select((s) => s.isGeneratingPdf),
    );
    final hasItems = ref.watch(
      invoiceViewModelProvider.select((s) => s.document.items.isNotEmpty),
    );

    final notifier = ref.read(invoiceViewModelProvider.notifier);
    final theme = Theme.of(context);
    final amountInWords = NumberToWordsConverter.convertUsdToWords(grandTotal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Financial Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryMetricRow(label: 'Total Units / Hours', value: '$totalQty'),
            const SizedBox(height: 8),
            _SummaryMetricRow(
              label: 'Subtotal',
              value: AppFormatters.formatCurrency(subtotal),
            ),
            const SizedBox(height: 8),
            _SummaryMetricRow(
              label: 'Estimated Tax (${taxRate.toStringAsFixed(1)}%)',
              value: AppFormatters.formatCurrency(taxAmount),
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Due (USD)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(grandTotal),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AMOUNT IN WORDS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amountInWords,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (!hasItems || isGenerating)
                        ? null
                        : () => notifier.previewPdf(),
                    icon: isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      isGenerating ? 'Building PDF...' : 'Preview & Print PDF',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: (!hasItems || isGenerating)
                      ? null
                      : () => notifier.shareOrDownloadPdf(),
                  icon: const Icon(Icons.ios_share_outlined),
                  tooltip: 'Share or Download PDF',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryMetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
