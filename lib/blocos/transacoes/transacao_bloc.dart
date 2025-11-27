import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../modelos/modelo_transacao.dart';
import '../../dados/banco_dados.dart';


abstract class EventoTransacao extends Equatable {
  @override
  List<Object?> get props => [];
}

class CarregarTransacoes extends EventoTransacao {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final List<int>? idsCategoria;
  final String? tipo;

  CarregarTransacoes({
    this.dataInicio,
    this.dataFim,
    this.idsCategoria,
    this.tipo,
  });

  @override
  List<Object?> get props => [dataInicio, dataFim, idsCategoria, tipo];
}

class AdicionarTransacao extends EventoTransacao {
  final ModeloTransacao transacao;

  AdicionarTransacao(this.transacao);

  @override
  List<Object?> get props => [transacao];
}

class AtualizarTransacao extends EventoTransacao {
  final ModeloTransacao transacao;

  AtualizarTransacao(this.transacao);

  @override
  List<Object?> get props => [transacao];
}

class ExcluirTransacao extends EventoTransacao {
  final int id;

  ExcluirTransacao(this.id);

  @override
  List<Object?> get props => [id];
}


abstract class EstadoTransacao extends Equatable {
  @override
  List<Object?> get props => [];
}

class TransacaoInicial extends EstadoTransacao {}

class TransacaoCarregando extends EstadoTransacao {}

class TransacaoCarregada extends EstadoTransacao {
  final List<ModeloTransacao> transacoes;

  TransacaoCarregada(this.transacoes);

  @override
  List<Object?> get props => [transacoes];
}

class ErroTransacao extends EstadoTransacao {
  final String mensagem;

  ErroTransacao(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class OperacaoTransacaoSucesso extends EstadoTransacao {
  final String mensagem;

  OperacaoTransacaoSucesso(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}


class BlocoTransacao extends Bloc<EventoTransacao, EstadoTransacao> {
  final AuxiliarBancoDeDados _auxiliarBancoDeDados;

  BlocoTransacao({AuxiliarBancoDeDados? auxiliarBancoDeDados})
      : _auxiliarBancoDeDados = auxiliarBancoDeDados ?? AuxiliarBancoDeDados.instancia,
        super(TransacaoInicial()) {
    on<CarregarTransacoes>(_aoCarregarTransacoes);
    on<AdicionarTransacao>(_aoAdicionarTransacao);
    on<AtualizarTransacao>(_aoAtualizarTransacao);
    on<ExcluirTransacao>(_aoExcluirTransacao);
  }

  Future<void> _aoCarregarTransacoes(
    CarregarTransacoes event,
    Emitter<EstadoTransacao> emit,
  ) async {
    emit(TransacaoCarregando());
    try {
      final transacoes = await _auxiliarBancoDeDados.obterTransacoes(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        idsCategoria: event.idsCategoria,
        tipo: event.tipo,
      );
      emit(TransacaoCarregada(transacoes));
    } catch (e) {
      emit(ErroTransacao(e.toString()));
    }
  }

  Future<void> _aoAdicionarTransacao(
    AdicionarTransacao event,
    Emitter<EstadoTransacao> emit,
  ) async {
    try {
      await _auxiliarBancoDeDados.inserirTransacao(event.transacao);
      emit(OperacaoTransacaoSucesso('Transação adicionada com sucesso'));
      add(CarregarTransacoes());
    } catch (e) {
      emit(ErroTransacao(e.toString()));
    }
  }

  Future<void> _aoAtualizarTransacao(
    AtualizarTransacao event,
    Emitter<EstadoTransacao> emit,
  ) async {
    try {
      await _auxiliarBancoDeDados.atualizarTransacao(event.transacao);
      emit(OperacaoTransacaoSucesso('Transação atualizada com sucesso'));
      add(CarregarTransacoes());
    } catch (e) {
      emit(ErroTransacao(e.toString()));
    }
  }

  Future<void> _aoExcluirTransacao(
    ExcluirTransacao event,
    Emitter<EstadoTransacao> emit,
  ) async {
    try {
      await _auxiliarBancoDeDados.excluirTransacao(event.id);
      emit(OperacaoTransacaoSucesso('Transação excluída com sucesso'));
      add(CarregarTransacoes());
    } catch (e) {
      emit(ErroTransacao(e.toString()));
    }
  }
}
