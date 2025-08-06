import 'package:flutter/material.dart';
import '../models/preajuste_tiempos.dart';

class TarjetaPreajuste extends StatelessWidget {
  final TiempoPreajuste preajuste;
  final VoidCallback? alPresionar;
  final VoidCallback? alEditar;
  final VoidCallback? alEliminar;

  const TarjetaPreajuste({
    super.key,
    required this.preajuste,
    this.alPresionar,
    this.alEditar,
    this.alEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula datos a mostrar
    final duracionTotal = preajuste.obtenerDuracionTotal();
    final minutos = (duracionTotal / 60).floor();
    final segundos = duracionTotal % 60;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior
              //Nombre del preajuste y botones de acción
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preajuste.nombrePreajuste,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Botones editar y eliminar
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'editar':
                          alEditar?.call();
                          break;
                        case 'eliminar':
                          alEliminar?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información del preajuste
              // 2 columnas
              Row(
                children: [
                  Expanded(
                    child: _construirInfoItem(
                      icono: Icons.fitness_center,
                      etiqueta: 'Sets',
                      valor: '${preajuste.sets}',
                      context: context,
                    ),
                  ),
                  Expanded(
                    child: _construirInfoItem(
                      icono: Icons.timer,
                      etiqueta: 'Trabajo',
                      valor: '${preajuste.trabajoTiempo}s',
                      context: context,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _construirInfoItem(
                      icono: Icons.pause_circle,
                      etiqueta: 'Descanso',
                      valor: '${preajuste.descansoTiempo}s',
                      context: context,
                    ),
                  ),
                  Expanded(
                    child: _construirInfoItem(
                      icono: Icons.schedule,
                      etiqueta: 'Total',
                      valor: segundos == 0 ? '${minutos}m' : '${minutos}m ${segundos}s',
                      context: context,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botón para iniciar el reloj
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: alPresionar,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Empezar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2A80),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirInfoItem({
    required IconData icono,
    required String etiqueta,
    required String valor,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          icono,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$etiqueta: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          valor,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}