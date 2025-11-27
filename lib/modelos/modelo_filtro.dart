import 'package:equatable/equatable.dart';

class ModeloFiltro extends Equatable {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<int>? idsCategoria;
  final String? tipoTransacao; // 'receita', 'despesa', or null for all

  const ModeloFiltro({
    this.dataInicio,
    this.dataFim,
    this.idsCategoria,
    this.tipoTransacao,
  });

  ModeloFiltro copiarCom({
    DateTime? dataInicio,
    DateTime? dataFim,
    List<int>? idsCategoria,
    String? tipoTransacao,
  }) {
    return ModeloFiltro(
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      idsCategoria: idsCategoria ?? this.idsCategoria,
      tipoTransacao: tipoTransacao ?? this.tipoTransacao,
    );
  }

  bool get temFiltros =>
      dataInicio != null ||
      dataFim != null ||
      (idsCategoria != null && idsCategoria!.isNotEmpty) ||
      tipoTransacao != null;

  @override
  List<Object?> get props => [dataInicio, dataFim, idsCategoria, tipoTransacao];
}
