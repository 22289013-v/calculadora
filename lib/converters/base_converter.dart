class BaseConverter {
  static const String _digits = '0123456789ABCDEF';

  static String fromDecimal(int decimal, int targetBase) {
    if (targetBase < 2 || targetBase > 16) {
      throw FormatException('Base no soportada: $targetBase');
    }

    if (decimal == 0) {
      return '0';
    }

    final isNegative = decimal < 0;
    int value = decimal.abs();
    final buffer = StringBuffer();

    while (value > 0) {
      buffer.write(_digits[value % targetBase]);
      value ~/= targetBase;
    }

    if (isNegative) {
      buffer.write('-');
    }

    return buffer.toString().split('').reversed.join();
  }

  static int toDecimal(String number, int base) {
    if (base < 2 || base > 16) {
      throw FormatException('Base no soportada: $base');
    }

    final normalized = number.trim();
    if (normalized.isEmpty) {
      throw FormatException('Número vacío');
    }

    final isNegative = normalized.startsWith('-');
    final value = isNegative ? normalized.substring(1) : normalized;
    int result = 0;

    for (final char in value.toUpperCase().split('')) {
      final digitValue = _digits.indexOf(char);
      if (digitValue == -1 || digitValue >= base) {
        throw FormatException('Número inválido para la base $base: $number');
      }
      result = result * base + digitValue;
    }

    return isNegative ? -result : result;
  }

  static String convertBase(String input, int fromBase, int toBase) {
    try {
      if (input.trim().isEmpty) {
        return 'Error';
      }

      if (fromBase == toBase) {
        return input.trim().toUpperCase();
      }

      final decimal = toDecimal(input, fromBase);
      return fromDecimal(decimal, toBase);
    } catch (_) {
      return 'Error';
    }
  }
}
