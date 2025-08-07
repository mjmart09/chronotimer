// lib/models/preajuste_tiempos.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TiempoPreajuste {
  // identificador unico
  final String id;

  // nombre de los preajustes
  final String nombrePreajuste;

  // tiempo de preparacion en segundos
  final int preparacionTiempo;

  // numero de sets o rondas
  final int sets;

  // tiempo de trabajo (ejercicios)
  final int trabajoTiempo;

  // tiempo de descanso en segundos
  final int descansoTiempo;

  // tiempo de enfriamiento en segundos
  final int enfriamientoTiempo;

  // cuando se creo el preajuste
  final DateTime fechaCreacion;

  // Constructor -> crea nuevos preajustes
  // Todos son obligatorios
  TiempoPreajuste({
    required this.id,
    required this.nombrePreajuste,
    required this.preparacionTiempo,
    required this.sets,
    required this.trabajoTiempo,
    required this.descansoTiempo,
    required this.enfriamientoTiempo,
    required this.fechaCreacion,
  });

  // Diccionario
  // De un objeto a un diccionario
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nombrePreajuste': nombrePreajuste,
      'preparacionTiempo': preparacionTiempo,
      'sets': sets,
      'trabajoTiempo': trabajoTiempo,
      'descansoTiempo': descansoTiempo,
      'enfriamientoTiempo': enfriamientoTiempo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Obtiene datos de firestore y los convierte en un objeto
  factory TiempoPreajuste.fromFirestore(Map<String, dynamic> datos) {
    return TiempoPreajuste(
      id: datos['id'] ?? '', // si no hay id, va vacio por defecto
      nombrePreajuste: datos['nombrePreajuste'] ?? 'Sin nombre',
      preparacionTiempo: datos['preparacionTiempo'] ?? 10,
      sets: datos['sets'] ?? 1,
      trabajoTiempo: datos['trabajoTiempo'] ?? 30,
      descansoTiempo: datos['descansoTiempo'] ?? 15,
      enfriamientoTiempo: datos['enfriamientoTiempo'] ?? 0,
      fechaCreacion: DateTime.fromMillisecondsSinceEpoch(
        datos['fechaCreacion'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Calcula el tiempo total de la rutina
  int obtenerDuracionTotal() {
    // Preparacion + (Sets * (Trabajo + Descanso)) + Enfriamiento
    return preparacionTiempo +
        (sets * trabajoTiempo) +
        ((sets - 1) *
            descansoTiempo) + // -1 porque despues de la ultima ronda no hay descanso
        enfriamientoTiempo;
  }

  // Copia del preajuste
  // para editar los que ya tiene
  TiempoPreajuste copyWith({
    String? id,
    String? nombrePreajuste,
    int? preparacionTiempo,
    int? sets,
    int? trabajoTiempo,
    int? descansoTiempo,
    int? enfriamientoTiempo,
    DateTime? fechaCreacion,
  }) {
    return TiempoPreajuste(
      id: id ?? this.id,
      nombrePreajuste: nombrePreajuste ?? this.nombrePreajuste,
      preparacionTiempo: preparacionTiempo ?? this.preparacionTiempo,
      sets: sets ?? this.sets,
      trabajoTiempo: trabajoTiempo ?? this.trabajoTiempo,
      descansoTiempo: descansoTiempo ?? this.descansoTiempo,
      enfriamientoTiempo: enfriamientoTiempo ?? this.enfriamientoTiempo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Función para debugging (para imprimir el preajuste)
  @override
  String toString() {
    return 'TiempoPreajuste(nombre: $nombrePreajuste, sets: $sets, trabajo: ${trabajoTiempo}s, descanso: ${descansoTiempo}s)';
  }
}
