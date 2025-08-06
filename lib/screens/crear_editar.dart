import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/preajuste_tiempos.dart';
import '../states/estados_preajustes.dart';

class PantallaCrearEditar extends StatefulWidget {
  final TiempoPreajuste? preajusteParaEditar;

  const PantallaCrearEditar({
    super.key,
    this.preajusteParaEditar,
  });

  @override
  State<PantallaCrearEditar> createState() => _PantallaCrearEditarState();
}

class _PantallaCrearEditarState extends State<PantallaCrearEditar> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  
  // Controladores para los campos numéricos
  int _preparacionTiempo = 10;
  int _sets = 5;
  int _trabajoTiempo = 30;
  int _descansoTiempo = 15;
  int _enfriamientoTiempo = 60;
  
  bool _guardando = false;
  bool get _esEdicion => widget.preajusteParaEditar != null;

  @override
  void initState() {
    super.initState();
    _inicializarFormulario();
  }

  void _inicializarFormulario() {
    if (_esEdicion) {
      final preajuste = widget.preajusteParaEditar!;
      _nombreController.text = preajuste.nombrePreajuste;
      _preparacionTiempo = preajuste.preparacionTiempo;
      _sets = preajuste.sets;
      _trabajoTiempo = preajuste.trabajoTiempo;
      _descansoTiempo = preajuste.descansoTiempo;
      _enfriamientoTiempo = preajuste.enfriamientoTiempo;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  int _calcularTiempoTotal() {
    return _preparacionTiempo + 
           (_sets * _trabajoTiempo) + 
           ((_sets - 1) * _descansoTiempo) + 
           _enfriamientoTiempo;
  }

  String _formatearTiempo(int segundos) {
    final minutos = (segundos / 60).floor();
    final segs = segundos % 60;
    if (minutos == 0) return '${segs}s';
    return segs == 0 ? '${minutos}m' : '${minutos}m ${segs}s';
  }

  @override
  Widget build(BuildContext context) {
    final tiempoTotal = _calcularTiempoTotal();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Preajuste' : 'Nuevo Preajuste'),
        backgroundColor: const Color(0xFF1A2A80),
        foregroundColor: Colors.white,
      ),
      
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa del tiempo total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 56, 56, 70),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Duración Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatearTiempo(tiempoTotal),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nombre del preajuste
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Preajuste',
                  hintText: 'Ej: Cardio Intenso',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Campos numéricos simplificados
              _construirCampoNumerico('Preparación (seg)', _preparacionTiempo, (valor) {
                setState(() => _preparacionTiempo = valor);
              }),

              _construirCampoNumerico('Sets', _sets, (valor) {
                setState(() => _sets = valor);
              }),

              _construirCampoNumerico('Trabajo (seg)', _trabajoTiempo, (valor) {
                setState(() => _trabajoTiempo = valor);
              }),

              _construirCampoNumerico('Descanso (seg)', _descansoTiempo, (valor) {
                setState(() => _descansoTiempo = valor);
              }),

              _construirCampoNumerico('Enfriamiento (seg)', _enfriamientoTiempo, (valor) {
                setState(() => _enfriamientoTiempo = valor);
              }),

              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarPreajuste,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A2A80),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)
                    ),
                  ),
                  child: Text(
                    _guardando 
                      ? 'Guardando...' 
                      : _esEdicion 
                        ? 'Actualizar' 
                        : 'Crear Preajuste',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCampoNumerico(String titulo, int valor, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: valor > 0 ? () => onChanged(valor - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: Color.fromARGB(255, 82, 17, 82),
          ),
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              valor.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () => onChanged(valor + 1),
            icon: const Icon(Icons.add_circle_outline),
            color: Color.fromARGB(255, 82, 17, 82),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarPreajuste() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final proveedor = Provider.of<ProveedorPreajustes>(context, listen: false);
      
      final preajuste = TiempoPreajuste(
        id: _esEdicion 
          ? widget.preajusteParaEditar!.id 
          : DateTime.now().millisecondsSinceEpoch.toString(),
        nombrePreajuste: _nombreController.text.trim(),
        preparacionTiempo: _preparacionTiempo,
        sets: _sets,
        trabajoTiempo: _trabajoTiempo,
        descansoTiempo: _descansoTiempo,
        enfriamientoTiempo: _enfriamientoTiempo,
        fechaCreacion: _esEdicion 
          ? widget.preajusteParaEditar!.fechaCreacion 
          : DateTime.now(),
      );

      bool resultado;
      if (_esEdicion) {
        resultado = await proveedor.actualizarPreajuste(preajuste);
      } else {
        resultado = await proveedor.agregarPreajuste(preajuste);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resultado 
                ? (_esEdicion ? 'Actualizado exitosamente' : 'Creado exitosamente')
                : 'Error al guardar',
            ),
            backgroundColor: resultado ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }
}