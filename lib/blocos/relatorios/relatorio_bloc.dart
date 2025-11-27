import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../../modelos/modelo_transacao.dart';
import '../../dados/banco_dados.dart';
import '../../modelos/modelo_categoria.dart';

abstract class EventoRelatorio extends Equatable {
  @override
  List<Object?> get props => [];
}

class GerarRelatorio extends EventoRelatorio {
  final DateTime? dataInicio;
  final DateTime? dataFim;

  GerarRelatorio({this.dataInicio, this.dataFim});

  @override
  List<Object?> get props => [dataInicio, dataFim];
}

class ExportarParaCSV extends EventoRelatorio {
  final DateTime? dataInicio;
  final DateTime? dataFim;

  ExportarParaCSV({this.dataInicio, this.dataFim});

  @override
  List<Object?> get props => [dataInicio, dataFim];
}

abstract class EstadoRelatorio extends Equatable {
  @override
  List<Object?> get props => [];
}

class RelatorioInicial extends EstadoRelatorio {}

class RelatorioCarregando extends EstadoRelatorio {}

class RelatorioGerado extends EstadoRelatorio {
  final Map<String, dynamic> dadosRelatorio;

  RelatorioGerado(this.dadosRelatorio);

  @override
  List<Object?> get props => [dadosRelatorio];
}

class RelatorioExportado extends EstadoRelatorio {
  final String caminhoArquivo;

  RelatorioExportado(this.caminhoArquivo);

  @override
  List<Object?> get props => [caminhoArquivo];
}

class ErroRelatorio extends EstadoRelatorio {
  final String mensagem;

  ErroRelatorio(this.mensagem);

  @override
  List<Object?> get props => [mensagem];
}

class BlocoRelatorio extends Bloc<EventoRelatorio, EstadoRelatorio> {
  final AuxiliarBancoDeDados _auxiliarBancoDeDados;

  BlocoRelatorio({AuxiliarBancoDeDados? auxiliarBancoDeDados})
      : _auxiliarBancoDeDados = auxiliarBancoDeDados ?? AuxiliarBancoDeDados.instancia,
        super(RelatorioInicial()) {
    on<GerarRelatorio>(_aoGerarRelatorio);
    on<ExportarParaCSV>(_aoExportarParaCSV);
  }

  Future<void> _aoGerarRelatorio(
    GerarRelatorio event,
    Emitter<EstadoRelatorio> emit,
  ) async {
    emit(RelatorioCarregando());
    try {
      final transacoes = await _auxiliarBancoDeDados.obterTransacoes(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );

      final resumo = await _auxiliarBancoDeDados.obterResumo(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );

      final categorias = await _auxiliarBancoDeDados.obterCategorias();
      final mapaCategorias = {for (var c in categorias) c.id!: c.nome};

      final Map<String, double> despesasPorCategoria = {};
      final Map<String, double> receitasPorCategoria = {};

      for (var transacao in transacoes) {
        final nomeCategoria = mapaCategorias[transacao.idCategoria] ?? 'Desconhecida';
        if (transacao.tipo == TipoTransacao.despesa) {
          despesasPorCategoria[nomeCategoria] =
              (despesasPorCategoria[nomeCategoria] ?? 0) + transacao.valor;
        } else {
          receitasPorCategoria[nomeCategoria] =
              (receitasPorCategoria[nomeCategoria] ?? 0) + transacao.valor;
        }
      }

      final Map<String, double> despesasPorData = {};
      final Map<String, double> receitasPorData = {};

      for (var transacao in transacoes) {
        final chaveData = DateFormat('yyyy-MM-dd').format(transacao.data);
        if (transacao.tipo == TipoTransacao.despesa) {
          despesasPorData[chaveData] = (despesasPorData[chaveData] ?? 0) + transacao.valor;
        } else {
          receitasPorData[chaveData] = (receitasPorData[chaveData] ?? 0) + transacao.valor;
        }
      }

      emit(RelatorioGerado({
        'resumo': resumo,
        'transacoes': transacoes,
        'despesasPorCategoria': despesasPorCategoria,
        'receitasPorCategoria': receitasPorCategoria,
        'despesasPorData': despesasPorData,
        'receitasPorData': receitasPorData,
      }));
    } catch (e) {
      emit(ErroRelatorio(e.toString()));
    }
  }

  Future<void> _aoExportarParaCSV(
    ExportarParaCSV event,
    Emitter<EstadoRelatorio> emit,
  ) async {
    emit(RelatorioCarregando());
    try {
      final transacoes = await _auxiliarBancoDeDados.obterTransacoes(
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
      );

      final categorias = await _auxiliarBancoDeDados.obterCategorias();
      final mapaCategorias = {for (var c in categorias) c.id!: c.nome};

      List<List<dynamic>> linhas = [];
      linhas.add(['Data', 'Descrição', 'Categoria', 'Tipo', 'Valor', 'Observação']);

      for (var transacao in transacoes) {
        final nomeCategoria = mapaCategorias[transacao.idCategoria] ?? 'Desconhecida';
        linhas.add([
          DateFormat('dd/MM/yyyy').format(transacao.data),
          transacao.descricao,
          nomeCategoria,
          transacao.tipo == TipoTransacao.receita ? 'Receita' : 'Despesa',
          transacao.valor.toStringAsFixed(2),
          transacao.observacao ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(linhas);

      final diretorio = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final caminhoArquivo = '${diretorio.path}/relatorio_$timestamp.csv';

      final arquivo = File(caminhoArquivo);
      await arquivo.writeAsString(csv);

      emit(RelatorioExportado(caminhoArquivo));
    } catch (e) {
      emit(ErroRelatorio(e.toString()));
    }
  }
}
