import 'package:equatable/equatable.dart';

class ModeloTransacao extends Equatable {
  final int? id;
  final String descricao;
  final double valor;
  final DateTime data;
  final int idCategoria;
  final TipoTransacao tipo;
  final String? observacao;

  const ModeloTransacao({
    this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.idCategoria,
    required this.tipo,
    this.observacao,
  });

  ModeloTransacao copiarCom({
    int? id,
    String? descricao,
    double? valor,
    DateTime? data,
    int? idCategoria,
    TipoTransacao? tipo,
    String? observacao,
  }) {
    return ModeloTransacao(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      idCategoria: idCategoria ?? this.idCategoria,
      tipo: tipo ?? this.tipo,
      observacao: observacao ?? this.observacao,
    );
  }

  Map<String, dynamic> paraMapa() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'idCategoria': idCategoria,
      'tipo': tipo.name,
      'observacao': observacao,
    };
  }

  factory ModeloTransacao.deMapa(Map<String, dynamic> map) {
    return ModeloTransacao(
      id: map['id'],
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      data: DateTime.parse(map['data']),
      idCategoria: map['idCategoria'] ?? 0,
      tipo: TipoTransacao.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoTransacao.despesa,
      ),
      observacao: map['observacao'],
    );
  }

  @override
  List<Object?> get props => [id, descricao, valor, data, idCategoria, tipo, observacao];
}

enum TipoTransacao {
  receita,
  despesa,
}
