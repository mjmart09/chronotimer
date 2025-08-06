// lib/states/estados_preajustes.dart

import 'package:flutter/foundation.dart';
import '../models/preajuste_tiempos.dart';
import '../services/firebase_services.dart';

class ProveedorPreajustes extends ChangeNotifier {
  // Conexion con firebase
  final FirebaseServices _firebaseServices = FirebaseServices();

  List<TiempoPreajuste> _preajustes = [];

  // Estados de carga
  bool _cargando = false;
  String? _mensajeError;

  // Acceder a los datos 
  List<TiempoPreajuste> get preajustes => List.unmodifiable(_preajustes);
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;
  int get cantidadPreajustes => _preajustes.length;

  // Cargar preajustes
  Future<void> cargarPreajustes() async {
    _establecerCargando(true);
    _limpiarError();

    try {
      _preajustes = await _firebaseServices.obtenerTodosLosPreajustes();
      print('Se cargaron ${_preajustes.length} preajustes');
    } catch (error) {
      _establecerError('Error cargado preajustes: $error');
      print('Error en cargar preajustes $error');
    } finally {
      _establecerCargando(false);
    }
  }

  // Agregar preajuste
  Future<bool> agregarPreajuste(TiempoPreajuste preajuste) async {
    _limpiarError();

    try {
      await _firebaseServices.crearPreajuste(preajuste);

      // Si se guarda correctamente, se agrega 
      _preajustes.insert(0, preajuste);
      notifyListeners();

      print('Preajuste agregado correctamente ${preajuste.nombrePreajuste}');
      return true;
    } catch (error) {
      _establecerError('Error creando preajuste: $error');
      print('Error en agregar prejuste: $error');
      return false;
    }
  }


  // Actualizar preajuste
  Future<bool> actualizarPreajuste(TiempoPreajuste preajusteActualizado) async {
    _limpiarError();

    try {
      await _firebaseServices.actualizarPreajuste(preajusteActualizado);
      
      // Busca el preajuste y lo reemplaza
      final index = _preajustes.indexWhere((p) => p.id == preajusteActualizado.id);
      if (index != -1) {
        _preajustes[index] = preajusteActualizado;
        notifyListeners();
      }
      
      print('Preajuste actualizado exitosamente: ${preajusteActualizado.nombrePreajuste}');
      return true;
    } catch (error) {
      _establecerError('Error actualizando preajuste: $error');
      print('Error en actualizar preajuste: $error');
      return false;
    }
  }


  // Eliminar preajuste
  Future<bool> eliminarPreajuste(String preajusteId) async {
    _limpiarError();

    try {
      await _firebaseServices.eliminarPreajuste(preajusteId);
      
      // Si es exitoso se elimina
      _preajustes.removeWhere((p) => p.id == preajusteId);
      notifyListeners();
      
      print('Preajuste eliminado exitosamente');
      return true;
    } catch (error) {
      _establecerError('Error eliminando preajuste: $error');
      print('Error en eliminarPreajuste: $error');
      return false;
    }
  }


  // Inicio rapido (preajuste por defecto)
  TiempoPreajuste obtenerPreajusteInicioRapido() {
    return _firebaseServices.crearPreajusteInicioRapido();
  }


  // Buscar preajuste por su id
  TiempoPreajuste? buscarPreajustePorId(String id) {
    try {
      return _preajustes.firstWhere((p) => p.id == id);
    } catch (error) {
      return null; // Da null si no encuentra el preajuste
    }
  }


  // Actualizar en tiempo real
  Stream<List<TiempoPreajuste>> obtenerStreamPreajustes() {
    return _firebaseServices.streamPreajustes();
  }


  // Metodos privados, manejan el estado interno de los estados
  void _establecerCargando(bool cargando) {
    _cargando = cargando;
    notifyListeners();
  }

  void _establecerError(String error) {
    _mensajeError = error;
    notifyListeners();
  }

  void _limpiarError() {
    _mensajeError = null;
    notifyListeners();
  }
}
