import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/preajuste_tiempos.dart';
import '../states/estados_preajustes.dart';
import '../widgets/tarjeta_preajuste.dart';
import 'crear_editar.dart';
import 'pantalla_timer.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  void initState() {
    super.initState();
    // Cargamos los preajustes cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProveedorPreajustes>().cargarPreajustes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChronoTimer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A2A80),
        elevation: 0,
        centerTitle: true,
      ),
      
      // Boton crear nuevos preajustes
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarDialogoCrearPreajuste();
        },
        backgroundColor: const Color(0xFF483AA0), // Boton crear
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Crear nuevo preajuste',
      ),
      
      body: Consumer<ProveedorPreajustes>(
        builder: (context, proveedor, child) {
          // Mostrar indicador de carga
          if (proveedor.cargando) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Cargando preajustes...'),
                ],
              ),
            );
          }

          // Mostrar mensaje de error si hay alguno
          if (proveedor.mensajeError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error cargando preajustes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    proveedor.mensajeError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => proveedor.cargarPreajustes(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Contenido principal
          return Column(
            children: [
              // Sección de Inicio Rápido
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color.fromARGB(255, 102, 136, 187)!, Color(0xFF1A2A80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 56, 56, 70),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /*
                    const Icon(
                      Icons.flash_on,
                      size: 48,
                      color: Colors.white,
                    ),
                    */
                    const SizedBox(height: 12),
                    const Text(
                      'Inicio Rápido',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '5 sets • 30s trabajo • 15s descanso',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _iniciarTimerRapido(proveedor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 56, 56, 70),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Comenzar Ahora',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sección de Preajustes Guardados
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Mis Preajustes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${proveedor.cantidadPreajustes} preajustes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lista de preajustes o mensaje de lista vacía
              Expanded(
                child: proveedor.preajustes.isEmpty
                    ? _construirListaVacia()
                    : ListView.builder(
                        itemCount: proveedor.preajustes.length,
                        itemBuilder: (context, index) {
                          final preajuste = proveedor.preajustes[index];
                          return TarjetaPreajuste(
                            preajuste: preajuste,
                            alPresionar: () => _iniciarTimer(preajuste),
                            alEditar: () => _editarPreajuste(preajuste),
                            alEliminar: () => _confirmarEliminarPreajuste(proveedor, preajuste),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Mostrar cuando no hay preajustes guardados
  Widget _construirListaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes preajustes guardados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear tu primer preajuste',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Acciones
  // Iniciar un timer específico
  void _iniciarTimer(TiempoPreajuste preajuste) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaTimer(preajuste: preajuste),
      ),
    );
  }

  // Iniciar el timer rápido
  void _iniciarTimerRapido(ProveedorPreajustes proveedor) {
    final preajusteRapido = proveedor.obtenerPreajusteInicioRapido();
    _iniciarTimer(preajusteRapido);
  }

  // Editar un preajuste existente
  void _editarPreajuste(TiempoPreajuste preajuste) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaCrearEditar(preajusteParaEditar: preajuste),
      ),
    );
  }

  // Diálogo de confirmación para eliminar un preajuste
  void _confirmarEliminarPreajuste(ProveedorPreajustes proveedor, TiempoPreajuste preajuste) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Preajuste'),
          content: Text('¿Estás seguro de eliminar "${preajuste.nombrePreajuste}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final resultado = await proveedor.eliminarPreajuste(preajuste.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        resultado 
                          ? 'Preajuste eliminado exitosamente'
                          : 'Error eliminando preajuste',
                      ),
                      backgroundColor: resultado ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo simple para crear un nuevo preajuste
    void _mostrarDialogoCrearPreajuste() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PantallaCrearEditar(),
      ),
    );
  }
}