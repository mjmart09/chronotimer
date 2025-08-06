import 'package:flutter/material.dart';
import '../models/preajuste_tiempos.dart';
import '../services/servicio_audio.dart';
import 'package:gif/gif.dart';

class PantallaFinal extends StatefulWidget {
  final TiempoPreajuste preajuste;

  const PantallaFinal({super.key, required this.preajuste});

  @override
  State<PantallaFinal> createState() => _PantallaFinalState();
}

class _PantallaFinalState extends State<PantallaFinal>
    with TickerProviderStateMixin {
  final ServicioAudio _audioService = ServicioAudio();
  bool _pausado = false;

  // Controlador de animación para el efecto de GIF lento
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionLenta;

  // Controlador para el GIF
  late GifController gifController;

  @override
  void initState() {
    super.initState();
    
    // Configurar controlador del GIF
    gifController = GifController(vsync: this);
    
    // Configurar animación para el efecto cinematográfico
    _controladorAnimacion = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _animacionLenta = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeInOut),
    );
    
    // Iniciar música y animación
    _audioService.reproducirMusicaVictoria();
    _controladorAnimacion.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    gifController.dispose();
    _audioService.detenerTodo();
    super.dispose();
  }

  void _pausarReanudar() {
    setState(() {
      _pausado = !_pausado;
    });

    if (_pausado) {
      _audioService.pausarMusica();
      _controladorAnimacion.stop();
      gifController.stop();
    } else {
      _audioService.reanudarMusica();
      _controladorAnimacion.repeat(reverse: true);
      gifController.repeat();
    }
  }

  void _volverAlInicio() {
    _audioService.detenerTodo();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _repetirEjercicio() {
    _audioService.detenerTodo();
    Navigator.of(context).pop(); // Volver al timer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo con GIF
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animacionLenta,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_animacionLenta.value * 0.03),
                  child: Gif(
                    image: const AssetImage('assets/gifs/victory.gif'),
                    fps: 12,
                    autostart: Autostart.loop,
                    fit: BoxFit.cover,
                    placeholder: (context) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1A2A80).withOpacity(0.9),
                            const Color(0xFF483AA0).withOpacity(0.8),
                            Colors.purple.withOpacity(0.8),
                            Colors.teal.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay para mejorar legibilidad
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Mensaje principal
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Text(
                      'EJERCICIO TERMINADO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 8,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Indicador de música
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _pausado ? Icons.music_off : Icons.music_note,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _pausado
                              ? 'Música pausada'
                              : 'Reproduciendo música...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Botones de acción
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Fila de botones superiores
                        Row(
                          children: [
                            Expanded(
                              child: _construirBoton(
                                icono: Icons.refresh,
                                texto: 'Repetir',
                                onPressed: _repetirEjercicio,
                                color: const Color(0xFF483AA0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _construirBoton(
                                icono: _pausado ? Icons.play_arrow : Icons.pause,
                                texto: _pausado ? 'Reanudar' : 'Pausar',
                                onPressed: _pausarReanudar,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Botón principal
                        SizedBox(
                          width: double.infinity,
                          child: _construirBoton(
                            icono: Icons.home,
                            texto: 'Volver al Inicio',
                            onPressed: _volverAlInicio,
                            color: const Color(0xFF1A2A80),
                            esBotonPrincipal: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBoton({
    required IconData icono,
    required String texto,
    required VoidCallback onPressed,
    required Color color,
    bool esBotonPrincipal = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: esBotonPrincipal ? 24 : 20),
      label: Text(
        texto,
        style: TextStyle(
          fontSize: esBotonPrincipal ? 18 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: esBotonPrincipal ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: color.withOpacity(0.4),
      ),
    );
  }
}