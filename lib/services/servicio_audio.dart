import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class ServicioAudio {
  // Instancia para usarlo de forma global
  static final ServicioAudio _instance = ServicioAudio._internal();
  factory ServicioAudio() => _instance;
  ServicioAudio._internal() {
    _inicializarReproductores();
  }

  // Reproductores de audio separados para diferentes sonidos
  final AudioPlayer _reproductorEfectos = AudioPlayer();
  final AudioPlayer _reproductorMusica = AudioPlayer();

  // Control de volumen y estado
  bool _efectosHabilitados = true;
  bool _musicaHabilitada = true;
  double _volumenEfectos = 0.8;
  double _volumenMusica = 0.6;

  // Controlar el estado de la música
  bool _musicaReproduciendose = false;
  String? _archivoMusicaActual;


  void _inicializarReproductores() {
    // Configuración para los efectos de sonido
    _reproductorEfectos.setReleaseMode(ReleaseMode.stop);
    _reproductorEfectos.setPlayerMode(PlayerMode.lowLatency);

    // Configuracion para música de fondo
    _reproductorMusica.setReleaseMode(ReleaseMode.stop); // No liberar automáticamente
    _reproductorMusica.setPlayerMode(PlayerMode.mediaPlayer); // Mejor para archivos largos

    // Monitorear el estado del reproductor de música
    _reproductorMusica.onPlayerStateChanged.listen((PlayerState estado) {
      print('EL estado de música cambió a: $estado');
      switch (estado) {
        case PlayerState.playing:
          _musicaReproduciendose = true;
          break;
        case PlayerState.paused:
          // NO modificar _musicaReproduciendose aquí, porque debe parar
          break;
        case PlayerState.stopped:
        case PlayerState.completed:
          _musicaReproduciendose = false;
          _archivoMusicaActual = null;
          break;
        case PlayerState.disposed:
          _musicaReproduciendose = false;
          _archivoMusicaActual = null;
          break;
      }
    });

    // Monitor de errores
    _reproductorMusica.onPlayerComplete.listen((_) {
      print('La música termino, reiniciando...');
      // Reiniciar la música automáticamente
      if (_archivoMusicaActual == 'victory_music.mp3' && _musicaHabilitada) {
        _reproducirMusicaVictoriaContinua();
      }
    });

    print('Reproductores de audio iniciados');
  }

  // Getters y setters 

  bool get efectosHabilitados => _efectosHabilitados;
  bool get musicaHabilitada => _musicaHabilitada;
  bool get musicaReproduciendose => _musicaReproduciendose;
  double get volumenEfectos => _volumenEfectos;
  double get volumenMusica => _volumenMusica;

  void configurarVolumenEfectos(double volumen) {
    _volumenEfectos = volumen.clamp(0.0, 1.0);
    _reproductorEfectos.setVolume(_volumenEfectos);
  }

  void configurarVolumenMusica(double volumen) {
    _volumenMusica = volumen.clamp(0.0, 1.0);
    _reproductorMusica.setVolume(_volumenMusica);
  }

  void habilitarEfectos(bool habilitar) {
    _efectosHabilitados = habilitar;
  }

  void habilitarMusica(bool habilitar) {
    _musicaHabilitada = habilitar;
    if (!habilitar) {
      detenerMusica();
    }
  }

  // Reproduccion de efectos de sonido
  Future<void> reproducirCountdown() async {
    if (!_efectosHabilitados) return;
    
    try {
      await _reproductorEfectos.stop();
      await _reproductorEfectos.setVolume(_volumenEfectos);
      await _reproductorEfectos.play(AssetSource('sounds/countdown_3_2_1.mp3'));
      print('Reproduciendo sonido de cuenta atras');
    } catch (error) {
      print('Error reproduciendo cuenta atras: $error');
    }
  }

  Future<void> reproducirTransicionFase() async {
    if (!_efectosHabilitados) return;
    
    try {
      await _reproductorEfectos.stop();
      await _reproductorEfectos.setVolume(_volumenEfectos);
      await _reproductorEfectos.play(AssetSource('sounds/radio_beep.mp3'));
      print('Reproduciendo sonido de transición');
    } catch (error) {
      print('Error reproduciendo transición: $error');
    }
  }

  // Reproduccion de musica
  Future<void> reproducirMusicaVictoria() async {
    if (!_musicaHabilitada) return;
    
    try {
      // Detener cualquier música anterior completamente
      await _reproductorMusica.stop();
      
      // Esperar un momento para asegurar que se detuvo completamente
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Configurar el reproductor antes de reproducir
      await _reproductorMusica.setVolume(_volumenMusica);
      await _reproductorMusica.setReleaseMode(ReleaseMode.stop);
      await _reproductorMusica.setPlayerMode(PlayerMode.mediaPlayer);
      
      // Marcar el archivo actual
      _archivoMusicaActual = 'victory_music.mp3';
      
      await _reproductorMusica.play(
        AssetSource('sounds/victory_music.mp3'),
        mode: PlayerMode.mediaPlayer, // Para archivos largos
        volume: _volumenMusica,
      );
      
      print('Música de fin de ejercicio iniciada');
      print('Volumen configurado a: $_volumenMusica');
      print('Modo de reproductor: MediaPlayer');
      
    } catch (error) {
      print('Error reproduciendo música de fin de ejercicio: $error');
      _musicaReproduciendose = false;
      _archivoMusicaActual = null;
    }
  }

  // Método privado para reproducir música de forma continua
  Future<void> _reproducirMusicaVictoriaContinua() async {
    if (!_musicaHabilitada || _archivoMusicaActual != 'victory_music.mp3') return;
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Pequeña pausa
      await _reproductorMusica.play(
        AssetSource('sounds/victory_music.mp3'),
        mode: PlayerMode.mediaPlayer,
        volume: _volumenMusica,
      );
      print('Música de victoria reiniciada automáticamente');
    } catch (error) {
      print('Error reiniciando música: $error');
    }
  }

  Future<void> detenerMusica() async {
    try {
      _archivoMusicaActual = null;
      await _reproductorMusica.stop();
      _musicaReproduciendose = false;
      print('Música detenida');
    } catch (error) {
      print('Error deteniendo música: $error');
    }
  }

  Future<void> pausarMusica() async {
    try {
      if (_musicaReproduciendose) {
        await _reproductorMusica.pause();
        print('Música pausada');
      }
    } catch (error) {
      print('Error al pausar la música: $error');
    }
  }

  Future<void> reanudarMusica() async {
    try {
      // Verifica si hay música para reanudar
      final playerState = _reproductorMusica.state;
      if (playerState == PlayerState.paused) {
        await _reproductorMusica.resume();
        print('Música reanudada');
      } else if (!_musicaReproduciendose && _archivoMusicaActual != null) {
        // Si se para, reinicia
        await reproducirMusicaVictoria();
      }
    } catch (error) {
      print('Error reanudando música: $error');
    }
  }

  // Método para obtener información del estado actual
  Future<void> mostrarEstadoReproductor() async {
    try {
      final estadoMusica = _reproductorMusica.state;
      final posicion = await _reproductorMusica.getCurrentPosition();
      final duracion = await _reproductorMusica.getDuration();
      
      print('Estado del reproductor');
      print('Estado: $estadoMusica');
      print('Posición: ${posicion?.inSeconds}s');
      print('Duración: ${duracion?.inSeconds}s');
      print('Archivo actual: $_archivoMusicaActual');
      print('Música habilitada: $_musicaHabilitada');
      print('Volumen: $_volumenMusica');
    } catch (error) {
      print('Error obteniendo estado: $error');
    }
  }

  // Limpiar recursos
  Future<void> detenerTodo() async {
    try {
      _archivoMusicaActual = null;
      _musicaReproduciendose = false;
      
      await Future.wait([
        _reproductorEfectos.stop(),
        _reproductorMusica.stop(),
      ]);
      
      print('Todos los efectos de sonido se pararon');
    } catch (error) {
      print('Error deteniendo sonidos: $error');
    }
  }

  void dispose() {
    _archivoMusicaActual = null;
    _musicaReproduciendose = false;
    
    _reproductorEfectos.dispose();
    _reproductorMusica.dispose();
    
    print('Se limpio el servicio de audio');
  }
}