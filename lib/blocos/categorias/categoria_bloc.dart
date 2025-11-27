import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../modelos/modelo_categoria.dart';
import '../../dados/banco_dados.dart';

// Eventos
abstract class EventoCategoria extends Equatable {
  @override
  List<Object?> get props => [];
}

class CarregarCategorias extends EventoCategoria {}

class AdicionarCategoria extends EventoCategoria {
  final ModeloCategoria categoria;

  AdicionarCategoria(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class AtualizarCategoria extends EventoCategoria {
  final ModeloCategoria categoria;

  AtualizarCategoria(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class ExcluirCategoria extends EventoCategoria {
  final int id;

  ExcluirCategoria(this.id);

  @override
  List<Object?> get props => [id];
}

// Estados
abstract class EstadoCategoria extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoriaInicial extends EstadoCategoria {}

class CategoriaCarregando extends EstadoCategoria {}

class CategoriaCarregada extends EstadoCategoria {
  final List<ModeloCategoria> categorias;

  CategoriaCarregada(this.categorias);

  @override
  List<Object?> get props => [categorias];
}

class ErroCategoria extends EstadoCategoria {
  final String mensagem;

  ErroCategoria(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class OperacaoCategoriaSucesso extends EstadoCategoria {
  final String mensagem;

  OperacaoCategoriaSucesso(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

// BLoC
class BlocoCategoria extends Bloc<EventoCategoria, EstadoCategoria> {
  final AuxiliarBancoDeDados _auxiliarBancoDeDados;

  BlocoCategoria({AuxiliarBancoDeDados? auxiliarBancoDeDados})
      : _auxiliarBancoDeDados = auxiliarBancoDeDados ?? AuxiliarBancoDeDados.instancia,
        super(CategoriaInicial()) {
    on<CarregarCategorias>(_aoCarregarCategorias);
    on<AdicionarCategoria>(_aoAdicionarCategoria);
    on<AtualizarCategoria>(_aoAtualizarCategoria);
    on<ExcluirCategoria>(_aoExcluirCategoria);
  }

  Future<void> _aoCarregarCategorias(
    CarregarCategorias event,
    Emitter<EstadoCategoria> emit,
  ) async {
    emit(CategoriaCarregando());
    try {
      final categorias = await _auxiliarBancoDeDados.obterCategorias();
      emit(CategoriaCarregada(categorias));
    } catch (e) {
      emit(ErroCategoria(e.toString()));
    }
  }

  Future<void> _aoAdicionarCategoria(
    AdicionarCategoria event,
    Emitter<EstadoCategoria> emit,
  ) async {
    try {
      await _auxiliarBancoDeDados.inserirCategoria(event.categoria);
      emit(OperacaoCategoriaSucesso('Categoria adicionada com sucesso'));
      add(CarregarCategorias());
    } catch (e) {
      emit(ErroCategoria(e.toString()));
    }
  }

  Future<void> _aoAtualizarCategoria(
    AtualizarCategoria event,
    Emitter<EstadoCategoria> emit,
  ) async {
    try {
      await _auxiliarBancoDeDados.atualizarCategoria(event.categoria);
      emit(OperacaoCategoriaSucesso('Categoria atualizada com sucesso'));
      add(CarregarCategorias());
    } catch (e) {
      emit(ErroCategoria(e.toString()));
    }
  }

  Future<void> _aoExcluirCategoria(
    ExcluirCategoria event,
    Emitter<EstadoCategoria> emit,
  ) async {
    try {
      await _auxiliarBancoDeDados.excluirCategoria(event.id);
      emit(OperacaoCategoriaSucesso('Categoria excluída com sucesso'));
      add(CarregarCategorias());
    } catch (e) {
      emit(ErroCategoria(e.toString()));
    }
  }
}
