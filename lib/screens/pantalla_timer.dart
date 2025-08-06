import 'dart:async';
import 'package:flutter/material.dart';
import '../models/preajuste_tiempos.dart';
import '../services/servicio_audio.dart';
import 'pantalla_final.dart';

class PantallaTimer extends StatefulWidget {
  final TiempoPreajuste preajuste;

  const PantallaTimer({super.key, required this.preajuste});

  @override
  State<PantallaTimer> createState() => _PantallaTimerState();
}

class _PantallaTimerState extends State<PantallaTimer> {
  Timer? _timer;
  int _tiempoRestante = 0;
  int _setActual = 0;
  bool _pausado = false;

  // Estados del timer
  String _faseActual = 'preparacion';
  Color _colorFondo = Colors.orange;

  // Servicio de audio
  final ServicioAudio _audioService = ServicioAudio();

  // Control para evitar sonidos repetitivos
  bool _countdownReproducido = false;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    
    // Navegar a la pantalla final
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PantallaFinal(preajuste: widget.preajuste),
      ),
    );
  }

  void _pausarReanudar() {
    setState(() {
      _pausado = !_pausado;
    });
  }

  void _reiniciarTimer() {
    _timer?.cancel();
    _audioService.detenerTodo();
    setState(() {
      _pausado = false;
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
      backgroundColor: _colorFondo,
      appBar: AppBar(
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
      body: SafeArea(
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
      ),
    );
  }
}