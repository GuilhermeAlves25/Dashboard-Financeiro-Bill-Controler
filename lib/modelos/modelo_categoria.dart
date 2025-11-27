import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ModeloCategoria extends Equatable {
  final int? id;
  final String nome;
  final IconData icone;
  final Color cor;
  final String tipo;

  const ModeloCategoria({
    this.id,
    required this.nome,
    required this.icone,
    required this.cor,
    required this.tipo,
  });

  ModeloCategoria copiarCom({
    int? id,
    String? nome,
    IconData? icone,
    Color? cor,
    String? tipo,
  }) {
    return ModeloCategoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      icone: icone ?? this.icone,
      cor: cor ?? this.cor,
      tipo: tipo ?? this.tipo,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'name': nome,
      'iconCodePoint': icone.codePoint,
      'colorValue': cor.value,
      'type': tipo,
    };
  }

  factory ModeloCategoria.deMapa(Map<String, dynamic> map) {
    return ModeloCategoria(
      id: map['id'] as int?,
      nome: map['name'] ?? '',
      icone: IconData(map['iconCodePoint'] ?? 0xe047, fontFamily: 'MaterialIcons'),
      cor: Color(map['colorValue'] ?? 0xFF000000),
      tipo: map['type'] ?? 'expense',
    );
  }

  @override
  List<Object?> get props => [id, nome, icone, cor, tipo];
}
