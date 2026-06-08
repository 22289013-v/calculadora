import 'dart:math';

double suma(double num1, double num2) {
  return num1 + num2;
}

double resta(double num1, double num2) {
  return num1 - num2;
}

double multiplicacion(double num1, double num2) {
  return num1 * num2;
}

double division(double num1, double num2) {
  if (num2 == 0) {
    throw Exception('No se puede dividir entre cero');
  }
  return num1 / num2;
}

double raiz(double num) {
  if (num < 0) {
    throw Exception(
      'No se puede calcular la raíz cuadrada de un número negativo',
    );
  }
  return sqrt(num);
}

double potencia(double base, double exponente) {
  return pow(base, exponente).toDouble();
}