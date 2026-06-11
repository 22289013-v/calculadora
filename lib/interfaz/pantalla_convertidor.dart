import 'package:flutter/material.dart';
import '../com_sistemas.dart';
import '../converters/base_converter.dart';

class PantallaConvertidor extends StatefulWidget {
  const PantallaConvertidor({super.key});

  @override
  State<PantallaConvertidor> createState() => _PantallaConvertidorState();
}

class _PantallaConvertidorState extends State<PantallaConvertidor>
    with SingleTickerProviderStateMixin {
  // ── Colores ─────────────────────────────────────────────────────
  static const Color _bgColor       = Color(0xFF0D0D0D);
  static const Color _cardColor     = Color(0xFF1A1A1A);
  static const Color _btnColor      = Color(0xFF222222);
  static const Color _accentColor   = Color(0xFFE8FF47);
  static const Color _txtPrimario   = Color(0xFFFFFFFF);
  static const Color _txtSecundario = Color(0xFF888888);
  static const Color _borderColor   = Color(0xFF2E2E2E);

  // ── Modo activo ─────────────────────────────────────────────────
  bool _modoBases = true; // true = bases, false = longitud

  // ── Estado bases ────────────────────────────────────────────────
  final _baseInputCtrl = TextEditingController();
  int _baseOrigen = 10;
  final Map<String, int> _bases = {
    'DEC': 10, 'BIN': 2, 'OCT': 8, 'HEX': 16,
  };
  Map<String, String> _resultadosBases = {
    'DEC': '', 'BIN': '', 'OCT': '', 'HEX': '',
  };
  String? _errorBase;

  // ── Estado longitud ─────────────────────────────────────────────
  final _longInputCtrl = TextEditingController();
  String _unidadOrigen = 'cm';

  Map<String, double Function(double)> get _conversiones => {
    'cm': (v) => v,
    'in': (v) => cmToInches(v),
    'm':  (v) => v / 100,
    'ft': (v) => mToFeet(v / 100),
    'yd': (v) => mToYards(v / 100),
    'km': (v) => v / 100000,
    'mi': (v) => kmToMiles(v / 100000),
  };

  Map<String, double Function(double)> get _toCm => {
    'cm': (v) => v,
    'in': (v) => inchesToCm(v),
    'm':  (v) => v * 100,
    'ft': (v) => feetToM(v) * 100,
    'yd': (v) => yardsToM(v) * 100,
    'km': (v) => v * 100000,
    'mi': (v) => milesToKm(v) * 100000,
  };

  Map<String, String> _resultadosLong = {};
  String? _errorLong;

  final Map<String, String> _labelLong = {
    'cm': 'Centímetros',
    'in': 'Pulgadas',
    'm':  'Metros',
    'ft': 'Pies',
    'yd': 'Yardas',
    'km': 'Kilómetros',
    'mi': 'Millas',
  };

  @override
  void dispose() {
    _baseInputCtrl.dispose();
    _longInputCtrl.dispose();
    super.dispose();
  }

  // ── Lógica ──────────────────────────────────────────────────────
  void _convertirBases(String input) {
    if (input.trim().isEmpty) {
      setState(() {
        _resultadosBases = {'DEC': '', 'BIN': '', 'OCT': '', 'HEX': ''};
        _errorBase = null;
      });
      return;
    }
    setState(() {
      _errorBase = null;
      for (final entry in _bases.entries) {
        if (entry.value == _baseOrigen) {
          _resultadosBases[entry.key] = input.trim().toUpperCase();
        } else {
          final res = BaseConverter.convertBase(input, _baseOrigen, entry.value);
          _resultadosBases[entry.key] = res;
          if (res == 'Error') _errorBase = 'Entrada inválida para base $_baseOrigen';
        }
      }
    });
  }

  void _convertirLongitud(String input) {
    if (input.trim().isEmpty) {
      setState(() { _resultadosLong = {}; _errorLong = null; });
      return;
    }
    final valor = double.tryParse(input.replaceAll(',', '.'));
    if (valor == null) {
      setState(() { _errorLong = 'Ingresa un número válido'; _resultadosLong = {}; });
      return;
    }
    setState(() {
      _errorLong = null;
      final enCm = _toCm[_unidadOrigen]!(valor);
      _resultadosLong = {};
      for (final entry in _conversiones.entries) {
        if (entry.key != _unidadOrigen) {
          _resultadosLong[entry.key] = _formatear(entry.value(enCm));
        }
      }
    });
  }

  String _formatear(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    String s = v.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  void _alternarModo() {
    setState(() {
      _modoBases = !_modoBases;
      // Limpiar estado del modo anterior
      _baseInputCtrl.clear();
      _longInputCtrl.clear();
      _resultadosBases = {'DEC': '', 'BIN': '', 'OCT': '', 'HEX': ''};
      _resultadosLong = {};
      _errorBase = null;
      _errorLong = null;
    });
  }

  // ── Widgets ─────────────────────────────────────────────────────
  Widget _toggleModo() {
    return Container(
      decoration: BoxDecoration(
        color: _btnColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleOpcion(
            label: 'Bases',
            icono: Icons.code_rounded,
            activo: _modoBases,
            onTap: () { if (!_modoBases) _alternarModo(); },
          ),
          _toggleOpcion(
            label: 'Longitud',
            icono: Icons.straighten_rounded,
            activo: !_modoBases,
            onTap: () { if (_modoBases) _alternarModo(); },
          ),
        ],
      ),
    );
  }

  Widget _toggleOpcion({
    required String label,
    required IconData icono,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: activo ? _accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 16, color: activo ? _bgColor : _txtSecundario),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activo ? _bgColor : _txtSecundario,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    bool hexMode = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: hexMode
            ? TextInputType.text
            : const TextInputType.numberWithOptions(decimal: true),
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          color: _txtPrimario,
          fontSize: 20,
          fontFamily: 'monospace',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF444444), fontSize: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF555555), size: 18),
                  onPressed: () { controller.clear(); onChanged(''); },
                )
              : null,
        ),
      ),
    );
  }

  // Selector estilo Wrap (chips) unificado
  Widget _selectorChips({
    required List<String> opciones,
    required String seleccionado,
    required ValueChanged<String> onSeleccionar,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: opciones.map((op) {
        final activo = op == seleccionado;
        return GestureDetector(
          onTap: () => onSeleccionar(op),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: activo ? _accentColor : _btnColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              op.toUpperCase(),
              style: TextStyle(
                color: activo ? _bgColor : _txtSecundario,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _resultadoBase(String label, String valor) {
    final esOrigen = _bases[label] == _baseOrigen;
    final Map<String, String> nombresBase = {
      'DEC': 'Decimal',
      'BIN': 'Binario',
      'OCT': 'Octal',
      'HEX': 'Hexadecimal',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: esOrigen ? const Color(0xFF1F2010) : _btnColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esOrigen ? _accentColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: esOrigen ? _accentColor : _accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                nombresBase[label] ?? label,
                style: const TextStyle(color: _txtSecundario, fontSize: 11),
              ),
            ],
          ),
          Flexible(
            child: Text(
              valor.isEmpty ? '—' : valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valor == 'Error'
                    ? Colors.redAccent
                    : (valor.isEmpty ? const Color(0xFF333333) : _txtPrimario),
                fontFamily: 'monospace',
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultadoLong(String unidad, String valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _btnColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unidad.toUpperCase(),
                style: const TextStyle(
                  color: _accentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                _labelLong[unidad] ?? unidad,
                style: const TextStyle(color: _txtSecundario, fontSize: 11),
              ),
            ],
          ),
          Text(
            valor,
            style: const TextStyle(
              color: _txtPrimario,
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: _txtPrimario,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: _accentColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text(
              'Convertidor',
              style: TextStyle(fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Botón toggle ─────────────────────────────────────────
          _toggleModo(),
          const SizedBox(height: 24),

          // ── Contenido según modo ─────────────────────────────────
          if (_modoBases) ...[
            // Selector de base origen
            _selectorChips(
              opciones: _bases.keys.toList(),
              seleccionado: _bases.entries
                  .firstWhere((e) => e.value == _baseOrigen)
                  .key,
              onSeleccionar: (op) {
                setState(() {
                  _baseOrigen = _bases[op]!;
                  _baseInputCtrl.clear();
                  _resultadosBases = {'DEC': '', 'BIN': '', 'OCT': '', 'HEX': ''};
                  _errorBase = null;
                });
              },
            ),
            const SizedBox(height: 12),

            _inputField(
              controller: _baseInputCtrl,
              hint: 'Ingresa el número…',
              hexMode: _baseOrigen == 16,
              onChanged: _convertirBases,
            ),

            if (_errorBase != null) ...[
              const SizedBox(height: 8),
              Text(_errorBase!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],

            const SizedBox(height: 12),

            Column(
              children: _bases.keys
                  .map((k) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _resultadoBase(k, _resultadosBases[k] ?? ''),
                      ))
                  .toList(),
            ),
          ] else ...[
            // Selector de unidad origen
            _selectorChips(
              opciones: _conversiones.keys.toList(),
              seleccionado: _unidadOrigen,
              onSeleccionar: (op) {
                setState(() {
                  _unidadOrigen = op;
                  _longInputCtrl.clear();
                  _resultadosLong = {};
                  _errorLong = null;
                });
              },
            ),
            const SizedBox(height: 12),

            _inputField(
              controller: _longInputCtrl,
              hint: 'Ingresa el valor…',
              onChanged: _convertirLongitud,
            ),

            if (_errorLong != null) ...[
              const SizedBox(height: 8),
              Text(_errorLong!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],

            const SizedBox(height: 12),

            if (_resultadosLong.isNotEmpty)
              Column(
                children: _resultadosLong.entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _resultadoLong(e.key, e.value),
                        ))
                    .toList(),
              ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}