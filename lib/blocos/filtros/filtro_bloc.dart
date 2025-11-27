import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../modelos/modelo_filtro.dart';


abstract class EventoFiltro extends Equatable {
  @override
  List<Object?> get props => [];
}

class AtualizarFiltro extends EventoFiltro {
  final ModeloFiltro filtro;

  AtualizarFiltro(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

class LimparFiltro extends EventoFiltro {}

class DefinirIntervaloDatas extends EventoFiltro {
  final DateTime? dataInicio;
  final DateTime? dataFim;

  DefinirIntervaloDatas({this.dataInicio, this.dataFim});

  @override
  List<Object?> get props => [dataInicio, dataFim];
}

class DefinirFiltroCategoria extends EventoFiltro {
  final List<int> idsCategoria;

  DefinirFiltroCategoria(this.idsCategoria);

  @override
  List<Object?> get props => [idsCategoria];
}

class DefinirFiltroTipoTransacao extends EventoFiltro {
  final String? tipoTransacao;

  DefinirFiltroTipoTransacao(this.tipoTransacao);

  @override
  List<Object?> get props => [tipoTransacao];
}


abstract class EstadoFiltro extends Equatable {
  @override
  List<Object?> get props => [];
}

class FiltroInicial extends EstadoFiltro {
  final ModeloFiltro filtro;

  FiltroInicial({ModeloFiltro? filtro}) : filtro = filtro ?? const ModeloFiltro();

  @override
  List<Object?> get props => [filtro];
}

class FiltroAtualizado extends EstadoFiltro {
  final ModeloFiltro filtro;

  FiltroAtualizado(this.filtro);

  @override
  List<Object?> get props => [filtro];
}


class BlocoFiltro extends Bloc<EventoFiltro, EstadoFiltro> {
  BlocoFiltro() : super(FiltroInicial()) {
    on<AtualizarFiltro>(_aoAtualizarFiltro);
    on<LimparFiltro>(_aoLimparFiltro);
    on<DefinirIntervaloDatas>(_aoDefinirIntervaloDatas);
    on<DefinirFiltroCategoria>(_aoDefinirFiltroCategoria);
    on<DefinirFiltroTipoTransacao>(_aoDefinirFiltroTipoTransacao);
  }

  void _aoAtualizarFiltro(AtualizarFiltro event, Emitter<EstadoFiltro> emit) {
    emit(FiltroAtualizado(event.filtro));
  }

  void _aoLimparFiltro(LimparFiltro event, Emitter<EstadoFiltro> emit) {
    emit(FiltroInicial());
  }

  void _aoDefinirIntervaloDatas(DefinirIntervaloDatas event, Emitter<EstadoFiltro> emit) {
    final filtroAtual = _obterFiltroAtual();
    final novoFiltro = filtroAtual.copiarCom(
      dataInicio: event.dataInicio,
      dataFim: event.dataFim,
    );
    emit(FiltroAtualizado(novoFiltro));
  }

  void _aoDefinirFiltroCategoria(DefinirFiltroCategoria event, Emitter<EstadoFiltro> emit) {
    final filtroAtual = _obterFiltroAtual();
    final novoFiltro = filtroAtual.copiarCom(idsCategoria: event.idsCategoria);
    emit(FiltroAtualizado(novoFiltro));
  }

  void _aoDefinirFiltroTipoTransacao(
    DefinirFiltroTipoTransacao event,
    Emitter<EstadoFiltro> emit,
  ) {
    final filtroAtual = _obterFiltroAtual();
    final novoFiltro = filtroAtual.copiarCom(tipoTransacao: event.tipoTransacao);
    emit(FiltroAtualizado(novoFiltro));
  }

  ModeloFiltro _obterFiltroAtual() {
    if (state is FiltroAtualizado) {
      return (state as FiltroAtualizado).filtro;
    } else if (state is FiltroInicial) {
      return (state as FiltroInicial).filtro;
    }
    return const ModeloFiltro();
  }
}
