import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocos/transacoes/transacao_bloc.dart';
import '../blocos/categorias/categoria_bloc.dart';
import '../blocos/filtros/filtro_bloc.dart';
import '../modelos/modelo_transacao.dart';
import '../modelos/modelo_categoria.dart';
import '../modelos/modelo_filtro.dart';
import '../componentes/item_transacao.dart';
import 'tela_nova_transacao.dart';

class TelaTransacoes extends StatefulWidget {
  const TelaTransacoes({super.key});

  @override
  State<TelaTransacoes> createState() => _EstadoTelaTransacoes();
}

class _EstadoTelaTransacoes extends State<TelaTransacoes> {

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'pt_BR';
    context.read<BlocoTransacao>().add(CarregarTransacoes());
  }

  void _mostrarDialogoFiltro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const BottomSheetFiltro(),
    ).then((_) {
      final estadoFiltro = context.read<BlocoFiltro>().state;
      if (estadoFiltro is FiltroAtualizado) {
        final filtro = estadoFiltro.filtro;
        context.read<BlocoTransacao>().add(CarregarTransacoes(
              dataInicio: filtro.dataInicio,
              dataFim: filtro.dataFim,
              idsCategoria: filtro.idsCategoria,
              tipo: filtro.tipoTransacao,
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFF1E3A8A),
            elevation: 0,
            title: const Text(
              'Transações',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: _mostrarDialogoFiltro,
              ),
            ],
            pinned: true,
            floating: true,
          ),
          BlocBuilder<BlocoTransacao, EstadoTransacao>(
            builder: (context, estadoTransacao) {
              return BlocBuilder<BlocoCategoria, EstadoCategoria>(
                builder: (context, estadoCategoria) {
                  if (estadoTransacao is TransacaoCarregando) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (estadoTransacao is TransacaoCarregada &&
                      estadoCategoria is CategoriaCarregada) {
                    final transacoes = estadoTransacao.transacoes;
                    final categorias = estadoCategoria.categorias;

                    if (transacoes.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma transação encontrada',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final transacoesAgrupadas =
                    <String, List<ModeloTransacao>>{};
                    for (var transacao in transacoes) {
                      final chaveData =
                      DateFormat('yyyy-MM-dd').format(transacao.data);
                      if (!transacoesAgrupadas.containsKey(chaveData)) {
                        transacoesAgrupadas[chaveData] = [];
                      }
                      transacoesAgrupadas[chaveData]!.add(transacao);
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          20, 20, 20, 80), 
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final chaveData =
                            transacoesAgrupadas.keys.elementAt(index);
                            final transacoesDoDia =
                            transacoesAgrupadas[chaveData]!;
                            final data = DateTime.parse(chaveData);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    DateFormat('EEEE, d MMMM').format(data),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                ...transacoesDoDia.map((transacao) {
                                  final categoria = categorias.firstWhere(
                                        (c) => c.id == transacao.idCategoria,
                                    orElse: () => ModeloCategoria(
                                      id: 0,
                                      nome: 'Outros',
                                      icone: Icons.help_outline,
                                      cor: Colors.grey,
                                      tipo: 'despesa',
                                    ),
                                  );

                                  return ItemListaTransacao(
                                    transacao: transacao,
                                    categoria: categoria,
                                    aoTocar: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TelaAdicionarTransacao(
                                                transacao: transacao,
                                              ),
                                        ),
                                      ).then((_) {
                                        context
                                            .read<BlocoTransacao>()
                                            .add(CarregarTransacoes());
                                      });
                                    },
                                  );
                                }),
                              ],
                            );
                          },
                          childCount: transacoesAgrupadas.length,
                        ),
                      ),
                    );
                  }

                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Erro ao carregar transações'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class BottomSheetFiltro extends StatefulWidget {
  const BottomSheetFiltro({super.key});

  @override
  State<BottomSheetFiltro> createState() => _EstadoBottomSheetFiltro();
}

class _EstadoBottomSheetFiltro extends State<BottomSheetFiltro> {
  DateTime? _dataInicio;
  DateTime? _dataFim;
  List<int> _idsCategoriaSelecionados = [];
  String? _tipoSelecionado;

  @override
  void initState() {
    super.initState();
    final estadoFiltro = context.read<BlocoFiltro>().state;
    if (estadoFiltro is FiltroAtualizado) {
      _dataInicio = estadoFiltro.filtro.dataInicio;
      _dataFim = estadoFiltro.filtro.dataFim;
      _idsCategoriaSelecionados = estadoFiltro.filtro.idsCategoria ?? [];
      _tipoSelecionado = estadoFiltro.filtro.tipoTransacao;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<BlocoFiltro>().add(LimparFiltro());
                    setState(() {
                      _dataInicio = null;
                      _dataFim = null;
                      _idsCategoriaSelecionados = [];
                      _tipoSelecionado = null;
                    });
                  },
                  child: const Text('Limpar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Período',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: _dataInicio ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (data != null) {
                        setState(() => _dataInicio = data);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _dataInicio != null
                            ? DateFormat('dd/MM/yyyy').format(_dataInicio!)
                            : 'Data inicial',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: _dataFim ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (data != null) {
                        setState(() => _dataFim = data);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _dataFim != null
                            ? DateFormat('dd/MM/yyyy').format(_dataFim!)
                            : 'Data final',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Tipo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _construirChipTipo('Todas', null),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _construirChipTipo('Receitas', 'receita'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _construirChipTipo('Despesas', 'despesa'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Categorias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<BlocoCategoria, EstadoCategoria>(
              builder: (context, state) {
                if (state is CategoriaCarregada) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.categorias.map((categoria) {
                      final isSelected =
                      _idsCategoriaSelecionados.contains(categoria.id);
                      return FilterChip(
                        label: Text(categoria.nome),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _idsCategoriaSelecionados.add(categoria.id!);
                            } else {
                              _idsCategoriaSelecionados.remove(categoria.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<BlocoFiltro>().add(AtualizarFiltro(
                    ModeloFiltro(
                      dataInicio: _dataInicio,
                      dataFim: _dataFim,
                      idsCategoria: _idsCategoriaSelecionados.isEmpty
                          ? null
                          : _idsCategoriaSelecionados,
                      tipoTransacao: _tipoSelecionado,
                    ),
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirChipTipo(String label, String? tipo) {
    final isSelected = _tipoSelecionado == tipo;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      selected: isSelected,
      selectedColor: const Color(0xFF1E3A8A),
      onSelected: (selected) {
        setState(() => _tipoSelecionado = selected ? tipo : null);
      },
    );
  }
}
