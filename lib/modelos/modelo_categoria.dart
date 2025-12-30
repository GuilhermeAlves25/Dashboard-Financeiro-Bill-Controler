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
      'nome': nome,
      'codigoPontoIcone': icone.codePoint,
      'valorCor': cor.value,
      'tipo': tipo,
    };
  }

  factory ModeloCategoria.deMapa(Map<String, dynamic> map) {
    return ModeloCategoria(
      id: map['id'] as int?,
      nome: map['nome'] ?? '',
      icone: IconData(map['codigoPontoIcone'] ?? 0xe047, fontFamily: 'MaterialIcons'),
      cor: Color(map['valorCor'] ?? 0xFF000000),
      tipo: map['tipo'] ?? 'expense',
    );
  }

  @override
  List<Object?> get props => [id, nome, icone, cor, tipo];
}
