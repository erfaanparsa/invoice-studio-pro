abstract final class NumberToWordsConverter {
  static const List<String> _units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  static const List<String> _tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  static const List<String> _scales = ['', 'Thousand', 'Million', 'Billion'];

  /// Converts a double USD amount into standard English accounting words.
  /// Example: 1250.50 -> "One Thousand Two Hundred Fifty Dollars and Fifty Cents"
  static String convertUsdToWords(double amount) {
    if (amount < 0) {
      return 'Negative ${convertUsdToWords(amount.abs())}';
    }

    final int wholeDollars = amount.floor();
    final int cents = ((amount - wholeDollars) * 100).round();

    final String dollarWords = wholeDollars == 0
        ? 'Zero Dollars'
        : '${_convertInteger(wholeDollars)} ${wholeDollars == 1 ? 'Dollar' : 'Dollars'}';

    final String centWords = cents == 0
        ? 'Zero Cents'
        : '${_convertInteger(cents)} ${cents == 1 ? 'Cent' : 'Cents'}';

    return '$dollarWords and $centWords';
  }

  static String _convertInteger(int number) {
    if (number == 0) return 'Zero';

    final List<String> parts = [];
    int scaleIndex = 0;
    int remaining = number;

    while (remaining > 0) {
      final int chunk = remaining % 1000;
      if (chunk > 0) {
        final String chunkWords = _convertLessThanOneThousand(chunk);
        final String scale = _scales[scaleIndex];
        parts.insert(0, scale.isEmpty ? chunkWords : '$chunkWords $scale');
      }
      remaining ~/= 1000;
      scaleIndex++;
    }

    return parts.join(' ');
  }

  static String _convertLessThanOneThousand(int number) {
    final List<String> parts = [];
    int remaining = number;

    if (remaining >= 100) {
      parts.add('${_units[remaining ~/ 100]} Hundred');
      remaining %= 100;
    }

    if (remaining >= 20) {
      final int tenDigit = remaining ~/ 10;
      final int unitDigit = remaining % 10;
      if (unitDigit > 0) {
        parts.add('${_tens[tenDigit]}-${_units[unitDigit]}');
      } else {
        parts.add(_tens[tenDigit]);
      }
    } else if (remaining > 0) {
      parts.add(_units[remaining]);
    }

    return parts.join(' ');
  }
}
