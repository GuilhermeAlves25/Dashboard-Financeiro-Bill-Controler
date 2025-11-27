import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../blocos/relatorios/relatorio_bloc.dart';
import '../blocos/categorias/categoria_bloc.dart';
import '../modelos/modelo_categoria.dart';

class TelaRelatorios extends StatefulWidget {
  const TelaRelatorios({super.key});

  @override
  State<TelaRelatorios> createState() => _EstadoTelaRelatorios();
}

class _EstadoTelaRelatorios extends State<TelaRelatorios> {
  DateTime _dataInicio = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _dataFim = DateTime.now();

  bool _eVisualizacaoGraficoBarras = false;

  @override
  void initState() {
    super.initState();
    _carregarRelatorio();
  }

  void _carregarRelatorio() {
    context.read<BlocoRelatorio>().add(GerarRelatorio(
      dataInicio: _dataInicio,
      dataFim: _dataFim,
    ));
  }

  Future<void> _selecionarIntervaloDatas() async {
    final DateTimeRange? selecionado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _dataInicio, end: _dataFim),
    );

    if (selecionado != null) {
      setState(() {
        _dataInicio = selecionado.start;
        _dataFim = selecionado.end;
        _carregarRelatorio();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<BlocoRelatorio, EstadoRelatorio>(
        listener: (context, state) {
          if (state is RelatorioExportado) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Relatório exportado: ${state.caminhoArquivo}')),
            );
          } else if (state is ErroRelatorio) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro: ${state.mensagem}')),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF1E3A8A),
              elevation: 0,
              pinned: true,
              floating: true,
              title: const Text('Relatórios', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  onPressed: () {
                    context.read<BlocoRelatorio>().add(ExportarParaCSV(
                      dataInicio: _dataInicio,
                      dataFim: _dataFim,
                    ));
                  },
                ),
              ],
              expandedHeight: 150.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
                    child: InkWell(
                      onTap: _selecionarIntervaloDatas,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(_dataInicio)} - ${DateFormat('dd/MM/yyyy').format(_dataFim)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<BlocoRelatorio, EstadoRelatorio>(
                builder: (context, state) {
                  if (state is RelatorioCarregando) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state is RelatorioGerado) {
                    final despesasPorCategoria = state.dadosRelatorio['despesasPorCategoria'] as Map<String, double>;
                    final receitasPorCategoria = state.dadosRelatorio['receitasPorCategoria'] as Map<String, double>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        if (despesasPorCategoria.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Despesas por Categoria',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _eVisualizacaoGraficoBarras ? Icons.pie_chart : Icons.bar_chart,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _eVisualizacaoGraficoBarras = !_eVisualizacaoGraficoBarras;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          BlocBuilder<BlocoCategoria, EstadoCategoria>(
                            builder: (context, categoryState) {
                              if (categoryState is CategoriaCarregada) {
                                return _eVisualizacaoGraficoBarras
                                    ? _construirGraficoBarras(despesasPorCategoria, categoryState.categorias)
                                    : Column(
                                  children: [
                                    _construirLegenda(despesasPorCategoria, categoryState.categorias),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 250,
                                      child: PieChart(
                                        PieChartData(
                                          sections: _construirSecoesGraficoPizza(
                                            despesasPorCategoria,
                                            categoryState.categorias,
                                          ),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                        if (receitasPorCategoria.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Receitas por Categoria',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          BlocBuilder<BlocoCategoria, EstadoCategoria>(
                            builder: (context, categoryState) {
                              if (categoryState is CategoriaCarregada) {
                                return _eVisualizacaoGraficoBarras
                                    ? _construirGraficoBarras(receitasPorCategoria, categoryState.categorias)
                                    : Column(
                                  children: [
                                    _construirLegenda(receitasPorCategoria, categoryState.categorias),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 250,
                                      child: PieChart(
                                        PieChartData(
                                          sections: _construirSecoesGraficoPizza(
                                            receitasPorCategoria,
                                            categoryState.categorias,
                                          ),
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ],
                        const SizedBox(height: 30),
                      ],
                    );
                  }

                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Text('Nenhum dado disponível para o período selecionado.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirGraficoBarras(Map<String, double> data, List<ModeloCategoria> allCategories) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text("Sem dados para exibir no gráfico.")),
      );
    }

    var sortedEntries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final List<BarChartGroupData> barGroups = [];
    int x = 0;
    for (var entry in sortedEntries) {
      final category = allCategories.firstWhere(
            (c) => c.nome == entry.key,
        orElse: () => ModeloCategoria(id: 0, nome: 'Outros', icone: Icons.help_outline, cor: Colors.grey, tipo: 'despesa'),
      );
      barGroups.add(BarChartGroupData(x: x++, barRods: [
        BarChartRodData(
          toY: entry.value,
          color: category.cor,
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ]));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (sortedEntries.first.value) * 1.2, 
            barGroups: barGroups,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < sortedEntries.length) {
                  return SideTitleWidget(axisSide: meta.axisSide, space: 8.0, child: Text(sortedEntries[index].key.characters.take(3).toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
                }
                return const Text('');
              }, reservedSize: 38)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (value, meta) => Text('R\$${value.toInt()}', style: const TextStyle(fontSize: 10)))),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100),
            barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipColor: (group) => Colors.blueGrey, getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final categoryName = sortedEntries[group.x].key;
              return BarTooltipItem('$categoryName\n', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), children: <TextSpan>[TextSpan(text: 'R\$ ${rod.toY.toStringAsFixed(2)}', style: const TextStyle(color: Colors.yellow))]);
            })),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _construirSecoesGraficoPizza(
      Map<String, double> dataByCategory,
      List<ModeloCategoria> categories,
      ) {
    if (dataByCategory.isEmpty) return [];

    final total = dataByCategory.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return [];

    return dataByCategory.entries.map((entry) {
      final category = categories.firstWhere(
            (c) => c.nome == entry.key,
        orElse: () => ModeloCategoria(id: 0, nome: 'Outros', icone: Icons.help_outline, cor: Colors.grey, tipo: 'despesa'),
      );

      final percentage = (entry.value / total * 100);

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: category.cor,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  Widget _construirLegenda(Map<String, double> data, List<ModeloCategoria> allCategories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: data.keys.map((categoryName) {
          final category = allCategories.firstWhere(
                (c) => c.nome == categoryName,
            orElse: () => ModeloCategoria(id: 0, nome: 'Outros', icone: Icons.help_outline, cor: Colors.grey, tipo: 'despesa'),
          );
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: category.cor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                category.nome,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
