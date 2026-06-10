String decimalABinario(String decimal) {
  return int.parse(decimal).toRadixString(2);
}

String binarioADecimal(String binario) {
  return int.parse(binario, radix: 2).toString();
}

String decimalAHexadecimal(String decimal) {
  return int.parse(decimal).toRadixString(16).toUpperCase();
}

String hexadecimalADecimal(String hexadecimal) {
  return int.parse(hexadecimal, radix: 16).toString();
}

String decimalAOctal(String decimal) {
  return int.parse(decimal).toRadixString(8);
}

String octalADecimal(String octal) {
  return int.parse(octal, radix: 8).toString();
}