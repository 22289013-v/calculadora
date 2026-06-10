import 'package:flutter/material.dart';
import '../logica/operaciones.dart';
import 'pantalla_convertidor.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: const InterfazPrincipal(),
    );
  }
}

class InterfazPrincipal extends StatefulWidget {
  const InterfazPrincipal({super.key});

  @override
  State<InterfazPrincipal> createState() => _InterfazPrincipalState();
}

class _InterfazPrincipalState extends State<InterfazPrincipal> {
  String _display = '0';
  String _expresion = '';
  double? _primerOperando;
  String? _operacionActual;
  bool _esperandoSegundoOperando = false;
  bool _hayError = false;

  // ── Colores del tema ────────────────────────────────────────────
  static const Color _bgColor = Color(0xFF0D0D0D);
  static const Color _pantallaColor = Color(0xFF1A1A1A);
  static const Color _accentColor = Color(0xFFE8FF47); // amarillo-lima
  static const Color _btnOperacion = Color(0xFF2A2A2A);
  static const Color _btnNumero = Color(0xFF1E1E1E);
  static const Color _btnEspecial = Color(0xFF222222);
  static const Color _txtPrimario = Color(0xFFFFFFFF);
  static const Color _txtSecundario = Color(0xFF888888);

  // ── Lógica de entrada ───────────────────────────────────────────
  void _ingresarDigito(String digito) {
    setState(() {
      _hayError = false;
      if (_esperandoSegundoOperando) {
        _display = digito;
        _esperandoSegundoOperando = false;
      } else {
        if (digito == '.' && _display.contains('.')) return;
        _display = (_display == '0' && digito != '.')
            ? digito
            : _display + digito;
      }
    });
  }

  void _seleccionarOperacion(String operacion) {
    setState(() {
      _hayError = false;
      _primerOperando = double.tryParse(_display);
      _operacionActual = operacion;
      _esperandoSegundoOperando = true;

      final simbolos = {
        'suma': '+',
        'resta': '−',
        'multiplicacion': '×',
        'division': '÷',
        'potencia': '^',
      };
      _expresion =
          '${_formatearNumero(_primerOperando!)} ${simbolos[operacion] ?? operacion}';
    });
  }

  void _calcularRaiz() {
    setState(() {
      try {
        final num = double.tryParse(_display) ?? 0;
        final resultado = raiz(num);
        _expresion = '√${_formatearNumero(num)}';
        _display = _formatearNumero(resultado);
        _primerOperando = null;
        _operacionActual = null;
        _esperandoSegundoOperando = false;
        _hayError = false;
      } catch (e) {
        _display = 'Error';
        _expresion = '';
        _hayError = true;
      }
    });
  }

  void _calcularResultado() {
    if (_primerOperando == null || _operacionActual == null) return;
    setState(() {
      try {
        final segundoOperando = double.tryParse(_display) ?? 0;
        double resultado;

        switch (_operacionActual) {
          case 'suma':
            resultado = suma(_primerOperando!, segundoOperando);
            break;
          case 'resta':
            resultado = resta(_primerOperando!, segundoOperando);
            break;
          case 'multiplicacion':
            resultado = multiplicacion(_primerOperando!, segundoOperando);
            break;
          case 'division':
            resultado = division(_primerOperando!, segundoOperando);
            break;
          case 'potencia':
            resultado = potencia(_primerOperando!, segundoOperando);
            break;
          default:
            return;
        }

        final simbolos = {
          'suma': '+',
          'resta': '−',
          'multiplicacion': '×',
          'division': '÷',
          'potencia': '^',
        };
        _expresion =
            '${_formatearNumero(_primerOperando!)} ${simbolos[_operacionActual]!} ${_formatearNumero(segundoOperando)} =';
        _display = _formatearNumero(resultado);
        _primerOperando = null;
        _operacionActual = null;
        _esperandoSegundoOperando = false;
        _hayError = false;
      } catch (e) {
        _display = 'Error';
        _expresion = '';
        _hayError = true;
      }
    });
  }

  void _limpiar() {
    setState(() {
      _display = '0';
      _expresion = '';
      _primerOperando = null;
      _operacionActual = null;
      _esperandoSegundoOperando = false;
      _hayError = false;
    });
  }

  void _borrarUltimo() {
    setState(() {
      if (_hayError) {
        _limpiar();
        return;
      }
      if (_display.length <= 1 ||
          (_display.startsWith('-') && _display.length == 2)) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _cambiarSigno() {
    setState(() {
      final valor = double.tryParse(_display);
      if (valor != null && valor != 0) {
        _display = _formatearNumero(valor * -1);
      }
    });
  }

  String _formatearNumero(double num) {
    if (num == num.truncateToDouble() && !num.isInfinite) {
      final entero = num.toInt();
      return entero.toString();
    }
    // Limitar decimales a 10 dígitos
    String s = num.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // ── Widgets ─────────────────────────────────────────────────────

  Widget _buildPantalla() {
    final fontSize = _display.length > 12
        ? 28.0
        : (_display.length > 8 ? 36.0 : 52.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: _pantallaColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expresión secundaria
          SizedBox(
            height: 28,
            child: Text(
              _expresion,
              style: TextStyle(
                color: _txtSecundario,
                fontSize: 18,
                fontFamily: 'monospace',
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          // Resultado / número actual
          Text(
            _display,
            style: TextStyle(
              color: _hayError ? Colors.redAccent : _txtPrimario,
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildBoton({
    required String etiqueta,
    required VoidCallback alPresionar,
    Color? colorFondo,
    Color? colorTexto,
    bool esAccent = false,
    double? fontSize,
    bool ancho = false,
  }) {
    final bg = esAccent ? _accentColor : (colorFondo ?? _btnNumero);
    final fg = esAccent ? _bgColor : (colorTexto ?? _txtPrimario);

    return Expanded(
      flex: ancho ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: esAccent
                ? Colors.black12
                : _accentColor.withOpacity(0.12),
            onTap: alPresionar,
            child: Container(
              height: 72,
              alignment: Alignment.center,
              child: Text(
                etiqueta,
                style: TextStyle(
                  color: fg,
                  fontSize: fontSize ?? 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Título
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Calculadora',
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 14,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      //Boton
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PantallaCom()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _btnEspecial,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2E2E2E)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xFF888888),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Com',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Pantalla
              _buildPantalla(),

              const Spacer(),

              // ── Fila 1: funciones especiales ───────────────────
              Row(
                children: [
                  _buildBoton(
                    etiqueta: 'AC',
                    alPresionar: _limpiar,
                    colorFondo: _btnEspecial,
                    colorTexto: _accentColor,
                    fontSize: 20,
                  ),
                  _buildBoton(
                    etiqueta: '+/−',
                    alPresionar: _cambiarSigno,
                    colorFondo: _btnEspecial,
                  ),
                  _buildBoton(
                    etiqueta: '√',
                    alPresionar: _calcularRaiz,
                    colorFondo: _btnEspecial,
                    colorTexto: _accentColor,
                  ),
                  _buildBoton(
                    etiqueta: 'xⁿ',
                    alPresionar: () => _seleccionarOperacion('potencia'),
                    colorFondo: _operacionActual == 'potencia'
                        ? _accentColor
                        : _btnOperacion,
                    colorTexto: _operacionActual == 'potencia'
                        ? _bgColor
                        : _accentColor,
                  ),
                ],
              ),

              // ── Fila 2 ─────────────────────────────────────────
              Row(
                children: [
                  _buildBoton(
                    etiqueta: '7',
                    alPresionar: () => _ingresarDigito('7'),
                  ),
                  _buildBoton(
                    etiqueta: '8',
                    alPresionar: () => _ingresarDigito('8'),
                  ),
                  _buildBoton(
                    etiqueta: '9',
                    alPresionar: () => _ingresarDigito('9'),
                  ),
                  _buildBoton(
                    etiqueta: '÷',
                    alPresionar: () => _seleccionarOperacion('division'),
                    colorFondo: _operacionActual == 'division'
                        ? _accentColor
                        : _btnOperacion,
                    colorTexto: _operacionActual == 'division'
                        ? _bgColor
                        : _accentColor,
                  ),
                ],
              ),

              // ── Fila 3 ─────────────────────────────────────────
              Row(
                children: [
                  _buildBoton(
                    etiqueta: '4',
                    alPresionar: () => _ingresarDigito('4'),
                  ),
                  _buildBoton(
                    etiqueta: '5',
                    alPresionar: () => _ingresarDigito('5'),
                  ),
                  _buildBoton(
                    etiqueta: '6',
                    alPresionar: () => _ingresarDigito('6'),
                  ),
                  _buildBoton(
                    etiqueta: '×',
                    alPresionar: () => _seleccionarOperacion('multiplicacion'),
                    colorFondo: _operacionActual == 'multiplicacion'
                        ? _accentColor
                        : _btnOperacion,
                    colorTexto: _operacionActual == 'multiplicacion'
                        ? _bgColor
                        : _accentColor,
                  ),
                ],
              ),

              // ── Fila 4 ─────────────────────────────────────────
              Row(
                children: [
                  _buildBoton(
                    etiqueta: '1',
                    alPresionar: () => _ingresarDigito('1'),
                  ),
                  _buildBoton(
                    etiqueta: '2',
                    alPresionar: () => _ingresarDigito('2'),
                  ),
                  _buildBoton(
                    etiqueta: '3',
                    alPresionar: () => _ingresarDigito('3'),
                  ),
                  _buildBoton(
                    etiqueta: '−',
                    alPresionar: () => _seleccionarOperacion('resta'),
                    colorFondo: _operacionActual == 'resta'
                        ? _accentColor
                        : _btnOperacion,
                    colorTexto: _operacionActual == 'resta'
                        ? _bgColor
                        : _accentColor,
                  ),
                ],
              ),

              // ── Fila 5 ─────────────────────────────────────────
              Row(
                children: [
                  _buildBoton(
                    etiqueta: '⌫',
                    alPresionar: _borrarUltimo,
                    colorFondo: _btnEspecial,
                  ),
                  _buildBoton(
                    etiqueta: '0',
                    alPresionar: () => _ingresarDigito('0'),
                  ),
                  _buildBoton(
                    etiqueta: '.',
                    alPresionar: () => _ingresarDigito('.'),
                  ),
                  _buildBoton(
                    etiqueta: '+',
                    alPresionar: () => _seleccionarOperacion('suma'),
                    colorFondo: _operacionActual == 'suma'
                        ? _accentColor
                        : _btnOperacion,
                    colorTexto: _operacionActual == 'suma'
                        ? _bgColor
                        : _accentColor,
                  ),
                ],
              ),

              // ── Fila 6: igual ───────────────────────────────────
              Row(
                children: [
                  _buildBoton(
                    etiqueta: '=',
                    alPresionar: _calcularResultado,
                    esAccent: true,
                    ancho: true,
                    fontSize: 26,
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
