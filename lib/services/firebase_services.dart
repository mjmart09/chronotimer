// lib/services/firebase_services.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preajuste_tiempos.dart';
import 'dart:math';

class FirebaseServices {
  // conexion a la base de datos
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // nombre de la coleccion
  static const String _coleccionPreajustes = 'preajustes_tiempos';

  // Crear un nuevo preajuste
  Future<void> crearPreajuste(TiempoPreajuste preajuste) async {
    try {
      await _firestore
          .collection(_coleccionPreajustes)
          .doc(preajuste.id)
          .set(preajuste.toFirestore());

      print('Preajuste creado: ${preajuste.nombrePreajuste}');
    } catch (error) {
      print('Error creando el preajuste: $error');
      throw Exception('No se creo el preajuste: $error');
    }
  }


  // Obtener todos los preajustes
  Future<List<TiempoPreajuste>> obtenerTodosLosPreajustes() async {
    try {
      final querySnapshot = await _firestore
      .collection(_coleccionPreajustes)
      .orderBy('fechaCreacion', descending: true)
      .get();

      return querySnapshot.docs
            .map((doc) => TiempoPreajuste.fromFirestore(doc.data()))
            .toList();
    } catch (error) {
      print('Error al obtener los preajustes: $error');
      throw Exception('No se cargaron los preajustes: $error');
    }
  }


  // Cuando se modifica carga la version mas actual
  Stream<List<TiempoPreajuste>> streamPreajustes() {
    return _firestore
        .collection(_coleccionPreajustes)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TiempoPreajuste.fromFirestore(doc.data()))
            .toList());
  }



  // Actualizar, modificar un ajuste que ya existe
  Future<void> actualizarPreajuste(TiempoPreajuste preajuste) async {
    try {
      await _firestore
          .collection(_coleccionPreajustes)
          .doc(preajuste.id)
          .update(preajuste.toFirestore());

      print('Preajuste actualizado: ${preajuste.nombrePreajuste}');
    } catch (error) {
      print('Error actualizando el preajuste: $error');
      throw Exception('No se actualizo el preajuste: $error');
    }
  }


  // Eliminar
  Future<void> eliminarPreajuste(String preajusteId) async {
    try {
      await _firestore
          .collection(_coleccionPreajustes)
          .doc(preajusteId)
          .delete();

      print('Preajuste eliminado');
    } catch (error) {
      print('Error eliminando preajuste: $error');
      throw Exception('No se elimino el preajuste: $error');
    }
  }


  // Crea un preajuste de inicio rapido
  TiempoPreajuste crearPreajusteInicioRapido() {
    // Genera un id basado en el tiempo actual
    final String id = 'inicio_rapido_${DateTime.now().millisecondsSinceEpoch}';
    
    return TiempoPreajuste(
      id: id,
      nombrePreajuste: 'Inicio Rápido',
      preparacionTiempo: 10,    // 10 segundos para prepararse
      sets: 3,                  // 3 rondas
      trabajoTiempo: 90,        // 1m30s de ejercicio
      descansoTiempo: 15,       // 15 segundos de descanso
      enfriamientoTiempo: 60,   // 1 minuto de enfriamiento
      fechaCreacion: DateTime.now(),
    );
  }
 

}