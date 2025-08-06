import 'dart:async';
import 'package:flutter/material.dart';
import '../models/preajuste_tiempos.dart';
import '../services/servicio_audio.dart';
import 'package:gif/gif.dart';

class PantallaTimer extends StatefulWidget {
  final TiempoPreajuste preajuste;

  const PantallaTimer({super.key, required this.preajuste});

  @override
  State<PantallaTimer> createState() => _PantallaTimerState();
}

class _PantallaTimerState extends State<PantallaTimer>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _tiempoRestante = 0;
  int _setActual = 0;
  bool _pausado = false;
  bool _completado = false;

  // Estados del timer
  String _faseActual = 'preparacion';
  Color _colorFondo = Colors.orange;

  // Servicio de audio
  final ServicioAudio _audioService = ServicioAudio();

  // Control para evitar sonidos repetitivos
  bool _countdownReproducido = false;

  // Controlador de animación para el efecto de GIF lento
  late AnimationController _controladorAnimacion;
  late Animation<double> _animacionLenta;

  // Controlador para el GIF (nuevo paquete)
  late GifController gifController;

  @override
  void initState() {
    super.initState();
    
    // Configurar controlador del GIF (nuevo paquete)
    gifController = GifController(vsync: this);
    
    // Configurar animación para el efecto cinematográfico
    _controladorAnimacion = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _animacionLenta = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorAnimacion, curve: Curves.easeInOut),
    );
    
    _iniciarTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controladorAnimacion.dispose();
    gifController.dispose();
    _audioService.detenerTodo();
    super.dispose();
  }

  void _iniciarTimer() {
    _faseActual = 'preparacion';
    _tiempoRestante = widget.preajuste.preparacionTiempo;
    _setActual = 1;
    _countdownReproducido = false;
    _actualizarColor();
    _iniciarCountdown();
  }

  void _iniciarCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_pausado) {
        setState(() {
          if (_tiempoRestante > 0) {
            // Reproducir cuando quedan 3 segundos
            if (_tiempoRestante == 4 && !_countdownReproducido) {
              _audioService.reproducirCountdown();
              _countdownReproducido = true;
            }

            _tiempoRestante--;
          } else {
            // Reproducir sonido de transición cuando llega a 0
            _audioService.reproducirTransicionFase();
            _siguienteFase();
          }
        });
      }
    });
  }

  void _siguienteFase() {
    _countdownReproducido = false;

    switch (_faseActual) {
      case 'preparacion':
        _faseActual = 'trabajo';
        _tiempoRestante = widget.preajuste.trabajoTiempo;
        break;

      case 'trabajo':
        if (_setActual < widget.preajuste.sets) {
          _faseActual = 'descanso';
          _tiempoRestante = widget.preajuste.descansoTiempo;
        } else {
          _faseActual = 'enfriamiento';
          _tiempoRestante = widget.preajuste.enfriamientoTiempo;
        }
        break;

      case 'descanso':
        _setActual++;
        _faseActual = 'trabajo';
        _tiempoRestante = widget.preajuste.trabajoTiempo;
        break;

      case 'enfriamiento':
        _completarTimer();
        return;
    }

    _actualizarColor();
  }

  void _actualizarColor() {
    setState(() {
      switch (_faseActual) {
        case 'preparacion':
          _colorFondo = Colors.orange;
          break;
        case 'trabajo':
          _colorFondo = Colors.green;
          break;
        case 'descanso':
          _colorFondo = Colors.blue;
          break;
        case 'enfriamiento':
          _colorFondo = Colors.purple;
          break;
      }
    });
  }

  void _completarTimer() {
    _timer?.cancel();
    setState(() {
      _completado = true;
      _colorFondo = Colors.teal;
    });
    
    // Reproducir música con mejor logging
    _audioService.reproducirMusicaVictoria();
    
    // Hacer que la animación sea más lenta
    _controladorAnimacion.repeat(reverse: true);
    
    
    // Mostrar estado del reproductor para debug
    Future.delayed(const Duration(seconds: 2), () {
      _audioService.mostrarEstadoReproductor();
    });
  }

  void _pausarReanudar() {
    setState(() {
      _pausado = !_pausado;
    });

    if (_completado) {
      if (_pausado) {
        _audioService.pausarMusica();
        _controladorAnimacion.stop();
        gifController.stop(); // Pausar el GIF
      } else {
        _audioService.reanudarMusica();
        _controladorAnimacion.repeat(reverse: true);
        // Reanudar el gif
        gifController.repeat();
      }

      // Mostrar estado después del cambio
      Future.delayed(const Duration(milliseconds: 500), () {
        _audioService.mostrarEstadoReproductor();
      });
    }
  }

  void _reiniciarTimer() {
    _timer?.cancel();
    _controladorAnimacion.stop();
    gifController.stop(); // Detener el gif
    _audioService.detenerMusica();
    setState(() {
      _pausado = false;
      _completado = false;
    });
    _iniciarTimer();
  }

  String _obtenerTextoFase() {
    switch (_faseActual) {
      case 'preparacion':
        return 'PREPARACIÓN';
      case 'trabajo':
        return 'TRABAJO';
      case 'descanso':
        return 'DESCANSO';
      case 'enfriamiento':
        return 'ENFRIAMIENTO';
      default:
        return '';
    }
  }

  String _formatearTiempo(int segundos) {
    final minutos = (segundos / 60).floor();
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _completado ? Colors.transparent : _colorFondo,
      appBar: _completado
          ? null
          : AppBar(
              title: Text(
                widget.preajuste.nombrePreajuste,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: _colorFondo.withOpacity(0.8),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _audioService.detenerTodo();
                  Navigator.of(context).pop();
                },
              ),
            ),
      body: _completado
          ? _construirPantallaCompletado()
          : _construirPantallaTimer(),
    );
  }

  Widget _construirPantallaTimer() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Información del set actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Set $_setActual de ${widget.preajuste.sets}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            // Fase actual
            Text(
              _obtenerTextoFase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 20),

            // Indicador visual cuando quedan 3 segundos o menos
            if (_tiempoRestante <= 3 && _tiempoRestante > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '¡ÚLTIMOS ${_tiempoRestante} SEGUNDOS!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Tiempo restante (display principal)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: _tiempoRestante <= 3 ? Colors.red : Colors.white,
                  width: _tiempoRestante <= 3 ? 6 : 4,
                ),
                boxShadow: _tiempoRestante <= 3
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _formatearTiempo(_tiempoRestante),
                  style: TextStyle(
                    color: _tiempoRestante <= 3
                        ? Colors.red[100]
                        : Colors.white,
                    fontSize: _tiempoRestante <= 3 ? 52 : 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Controles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón reiniciar
                FloatingActionButton(
                  onPressed: _reiniciarTimer,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),

                // Botón pausar/reanudar
                FloatingActionButton.large(
                  onPressed: _pausarReanudar,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _pausado ? Icons.play_arrow : Icons.pause,
                    color: _colorFondo,
                    size: 40,
                  ),
                ),

                // Botón para parar
                FloatingActionButton(
                  onPressed: () {
                    _audioService.detenerTodo();
                    Navigator.of(context).pop();
                  },
                  backgroundColor: Colors.red.withOpacity(0.8),
                  child: const Icon(Icons.stop, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Indicador de pausa
            if (_pausado)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PAUSADO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirPantallaCompletado() {
    return Stack(
      children: [
        // Pantalla completa con velocidad controlada
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animacionLenta,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animacionLenta.value * 0.03),
                child: Gif(
                  image: const AssetImage('assets/gifs/celebration.gif'),
                  fps: 12,
                  //controller: gifController,                 
                  //duration: const Duration(seconds: 10),
                  autostart: Autostart.loop,
                  fit: BoxFit.cover,
                  placeholder: (context) => Container(
                    // Si no existe gif 
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _colorFondo.withOpacity(0.9),
                          _colorFondo.withOpacity(0.7),
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

        // overlay para que se pueda leer
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        // Contenido encima del gif
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Espaciador superior
                const Spacer(flex: 2),

                // Titulo principal
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    '¡ENTRENAMIENTO\nCOMPLETADO!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 6,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subtitulos
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    'Has completado exitosamente:\n"${widget.preajuste.nombrePreajuste}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Indicador de musica
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
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

                // Espaciador flexible
                const Spacer(flex: 3),

                // BOTONES DE ACCIÓN
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
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
                      // Primera fila de botones
                      Row(
                        children: [
                          Expanded(
                            child: _construirBotonCompletado(
                              icono: Icons.refresh,
                              texto: 'Repetir',
                              onPressed: _reiniciarTimer,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _construirBotonCompletado(
                              icono: _pausado ? Icons.play_arrow : Icons.pause,
                              texto: _pausado ? 'Reanudar' : 'Pausar',
                              onPressed: _pausarReanudar,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Botón de inicio
                      SizedBox(
                        width: double.infinity,
                        child: _construirBotonCompletado(
                          icono: Icons.home,
                          texto: 'Volver al Inicio',
                          onPressed: () {
                            _audioService.detenerTodo();
                            Navigator.of(context).pop();
                          },
                          color: _colorFondo,
                          esBotonPrincipal: true,
                        ),
                      ),
                    ],
                  ),
                ),

                // Espaciador inferior
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Método auxiliar para crear botones
  Widget _construirBotonCompletado({
    required IconData icono,
    required String texto,
    required VoidCallback onPressed,
    required Color color,
    bool esBotonPrincipal = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: esBotonPrincipal ? 26 : 22),
      label: Text(
        texto,
        style: TextStyle(
          fontSize: esBotonPrincipal ? 19 : 16,
          fontWeight: esBotonPrincipal ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: esBotonPrincipal ? 30 : 20,
          vertical: esBotonPrincipal ? 18 : 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: esBotonPrincipal ? 12 : 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }
}