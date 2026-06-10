import 'package:flutter/material.dart';
import '../logica/operaciones.dart';
import '../logica/conversiones.dart';

void main() {
  runApp(const ConvertidorApp());
}

class ConvertidorApp extends StatelessWidget {
  const ConvertidorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertidor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: const PantallaConvertidor(),
    );
  }
}

class PantallaConvertidor extends StatefulWidget {
  const PantallaConvertidor({super.key});

  @override
  State<PantallaConvertidor> createState() => _PantallaConvertidorState();
}

class _PantallaConvertidorState extends State<PantallaConvertidor> {
  String _valorEntrada = '0';
  String _valorSalida = '0';
  String _unidadOrigen = 'cm';
  String _unidadDestino = 'in';
  String _expresion = '';
  bool _mostrarTeclado = true;

  // ── Colores del tema ────────────────────────────────────────────
  static const Color _bgColor = Color(0xFF0D0D0D);
  static const Color _pantallaColor = Color(0xFF1A1A1A);
  static const Color _accentColor = Color(0xFFE8FF47);
  static const Color _btnOperacion = Color(0xFF2A2A2A);
  static const Color _btnNumero = Color(0xFF1E1E1E);
  static const Color _btnEspecial = Color(0xFF222222);
  static const Color _txtPrimario = Color(0xFFFFFFFF);
  static const Color _txtSecundario = Color(0xFF888888);

  // ── Lista de unidades disponibles ───────────────────────────────
  final List<Map<String, dynamic>> _unidades = [
    {'nombre': 'Centímetros', 'sigla': 'cm', 'tipo': 'longitud'},
    {'nombre': 'Pulgadas', 'sigla': 'in', 'tipo': 'longitud'},
    {'nombre': 'Metros', 'sigla': 'm', 'tipo': 'longitud'},
    {'nombre': 'Pies', 'sigla': 'ft', 'tipo': 'longitud'},
    {'nombre': 'Yardas', 'sigla': 'yd', 'tipo': 'longitud'},
    {'nombre': 'Kilómetros', 'sigla': 'km', 'tipo': 'longitud'},
    {'nombre': 'Millas', 'sigla': 'mi', 'tipo': 'longitud'},
  ];

  // ── Función de conversión principal ────────────────────────────
  double _convertir(double valor, String desde, String hacia) {
    // Primero convertir a metros (unidad base)
    double enMetros;

    switch (desde) {
      case 'cm':
        enMetros = valor / 100;
        break;
      case 'in':
        enMetros = valor / 39.3701;
        break;
      case 'm':
        enMetros = valor;
        break;
      case 'ft':
        enMetros = valor / 3.28084;
        break;
      case 'yd':
        enMetros = valor / 1.09361;
        break;
      case 'km':
        enMetros = valor * 1000;
        break;
      case 'mi':
        enMetros = valor * 1609.34;
        break;
      default:
        enMetros = valor;
    }

    // Luego convertir desde metros a la unidad destino
    switch (hacia) {
      case 'cm':
        return enMetros * 100;
      case 'in':
        return enMetros * 39.3701;
      case 'm':
        return enMetros;
      case 'ft':
        return enMetros * 3.28084;
      case 'yd':
        return enMetros * 1.09361;
      case 'km':
        return enMetros / 1000;
      case 'mi':
        return enMetros / 1609.34;
      default:
        return enMetros;
    }
  }

  // ── Actualizar conversión ──────────────────────────────────────
  void _actualizarConversion() {
    setState(() {
      try {
        final valor = double.tryParse(_valorEntrada) ?? 0;
        final resultado = _convertir(valor, _unidadOrigen, _unidadDestino);
        _valorSalida = _formatearNumero(resultado);
        _expresion =
            '${_formatearNumero(valor)} $_unidadOrigen = ${_formatearNumero(resultado)} $_unidadDestino';
      } catch (e) {
        _valorSalida = 'Error';
        _expresion = 'Error en la conversión';
      }
    });
  }

  // ── Cambiar unidades ───────────────────────────────────────────
  void _intercambiarUnidades() {
    setState(() {
      final temp = _unidadOrigen;
      _unidadOrigen = _unidadDestino;
      _unidadDestino = temp;
      _actualizarConversion();
    });
  }

  // ── Lógica de entrada de números ───────────────────────────────
  void _ingresarDigito(String digito) {
    setState(() {
      if (_valorEntrada == '0' && digito != '.') {
        _valorEntrada = digito;
      } else {
        if (digito == '.' && _valorEntrada.contains('.')) return;
        _valorEntrada = _valorEntrada + digito;
      }
      _actualizarConversion();
    });
  }

  void _borrarUltimo() {
    setState(() {
      if (_valorEntrada.length <= 1 ||
          (_valorEntrada.startsWith('-') && _valorEntrada.length == 2)) {
        _valorEntrada = '0';
      } else {
        _valorEntrada = _valorEntrada.substring(0, _valorEntrada.length - 1);
      }
      _actualizarConversion();
    });
  }

  void _limpiar() {
    setState(() {
      _valorEntrada = '0';
      _valorSalida = '0';
      _expresion = '';
      _actualizarConversion();
    });
  }

  void _cambiarSigno() {
    setState(() {
      final valor = double.tryParse(_valorEntrada);
      if (valor != null && valor != 0) {
        _valorEntrada = _formatearNumero(valor * -1);
        _actualizarConversion();
      }
    });
  }

  String _formatearNumero(double num) {
    if (num == num.truncateToDouble() && !num.isInfinite) {
      final entero = num.toInt();
      return entero.toString();
    }
    String s = num.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // ── Widgets ─────────────────────────────────────────────────────

  Widget _buildPantalla() {
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
          // Selectores de unidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUnidadSelector(_unidadOrigen, true),
              IconButton(
                icon: const Icon(Icons.swap_horiz, color: _accentColor),
                onPressed: _intercambiarUnidades,
              ),
              _buildUnidadSelector(_unidadDestino, false),
            ],
          ),
          const SizedBox(height: 16),
          // Valor de entrada
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _valorEntrada),
                  style: TextStyle(
                    color: _txtPrimario,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _valorEntrada = '0';
                      } else {
                        _valorEntrada = value;
                      }
                      _actualizarConversion();
                    });
                  },
                ),
              ),
            ],
          ),
          const Divider(color: _txtSecundario, height: 20),
          // Valor de salida
          Row(
            children: [
              Expanded(
                child: Text(
                  _valorSalida,
                  style: TextStyle(
                    color: _accentColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Expresión
          SizedBox(
            height: 24,
            child: Text(
              _expresion,
              style: TextStyle(
                color: _txtSecundario,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadSelector(String unidadActual, bool esOrigen) {
    final unidad = _unidades.firstWhere((u) => u['sigla'] == unidadActual);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _btnEspecial,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: unidadActual,
        dropdownColor: _btnEspecial,
        underline: const SizedBox(),
        style: TextStyle(
          color: _txtPrimario,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        iconEnabledColor: _accentColor,
        onChanged: (String? nuevaUnidad) {
          if (nuevaUnidad != null) {
            setState(() {
              if (esOrigen) {
                _unidadOrigen = nuevaUnidad;
              } else {
                _unidadDestino = nuevaUnidad;
              }
              _actualizarConversion();
            });
          }
        },
        items: _unidades.map<DropdownMenuItem<String>>((unidad) {
          return DropdownMenuItem<String>(
            value: unidad['sigla'],
            child: Text('${unidad['nombre']} (${unidad['sigla']})'),
          );
        }).toList(),
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
              height: 65,
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
      appBar: AppBar(
        title: const Text('Convertidor de Longitud'),
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarTeclado ? Icons.keyboard_hide : Icons.keyboard,
              color: _accentColor,
            ),
            onPressed: () {
              setState(() {
                _mostrarTeclado = !_mostrarTeclado;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Pantalla principal
              _buildPantalla(),

              const SizedBox(height: 20),

              // Teclado numérico (condicional)
              if (_mostrarTeclado) ...[
                // ── Fila 1: funciones especiales ───────────────────
                Row(
                  children: [
                    _buildBoton(
                      etiqueta: 'C',
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
                      etiqueta: '⌫',
                      alPresionar: _borrarUltimo,
                      colorFondo: _btnEspecial,
                    ),
                    _buildBoton(
                      etiqueta: '⌨️',
                      alPresionar: () {
                        setState(() {
                          _mostrarTeclado = false;
                        });
                      },
                      colorFondo: _btnOperacion,
                      colorTexto: _accentColor,
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
                  ],
                ),

                // ── Fila 5 ─────────────────────────────────────────
                Row(
                  children: [
                    _buildBoton(
                      etiqueta: '0',
                      alPresionar: () => _ingresarDigito('0'),
                    ),
                    _buildBoton(
                      etiqueta: '.',
                      alPresionar: () => _ingresarDigito('.'),
                    ),
                  ],
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
