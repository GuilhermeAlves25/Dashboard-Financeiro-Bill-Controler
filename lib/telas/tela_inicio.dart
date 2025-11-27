import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocos/transacoes/transacao_bloc.dart';
import '../blocos/categorias/categoria_bloc.dart';
import '../blocos/filtros/filtro_bloc.dart';
import '../blocos/relatorios/relatorio_bloc.dart';
import '../modelos/modelo_transacao.dart';
import '../modelos/modelo_categoria.dart';
import '../componentes/cartao_saldo.dart';
import '../componentes/item_transacao.dart';
import 'tela_nova_transacao.dart';
import 'tela_transacoes.dart';
import 'tela_relatorios.dart';

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  State<TelaInicio> createState() => _EstadoTelaInicio();
}

class _EstadoTelaInicio extends State<TelaInicio> {
  int _indiceSelecionado = 0;
  DateTime _mesAtual = DateTime.now();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'pt_BR';
    context.read<BlocoCategoria>().add(CarregarCategorias());
    _carregarTransacoes();
  }

  void _carregarTransacoes() {
    final dataInicio = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final dataFim = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);

    context.read<BlocoTransacao>().add(CarregarTransacoes(
          dataInicio: dataInicio,
          dataFim: dataFim,
        ));

    context.read<BlocoRelatorio>().add(GerarRelatorio(
      dataInicio: dataInicio,
      dataFim: dataFim,
    ));
  }

  void _mudarMes(int delta) {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + delta);
      _carregarTransacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: const Color(0xFF1E3A8A),
              elevation: 0,
              pinned: true,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              expandedHeight: 330.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: const Color(0xFF1E3A8A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.white),
                              onPressed: () => _mudarMes(-1),
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_mesAtual),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Colors.white),
                              onPressed: () => _mudarMes(1),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<BlocoRelatorio, EstadoRelatorio>(
                        builder: (context, state) {
                          if (state is RelatorioGerado) {
                            final resumo = state.dadosRelatorio['resumo'] as Map<String, double>;
                            final receitas = resumo['receitas'] ?? 0.0;
                            final despesas = resumo['despesas'] ?? 0.0;
                            final saldo = receitas - despesas;

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CartaoSaldo(
                                          rotulo: 'Receitas',
                                          valor: receitas,
                                          eReceita: true,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CartaoSaldo(
                                          rotulo: 'Despesas',
                                          valor: despesas,
                                          eReceita: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  CartaoSaldo(
                                    rotulo: 'Balanço Mensal',
                                    valor: saldo,
                                    eReceita: saldo >= 0,
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox(height: 190); 
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: _construirTelaAtual(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TelaAdicionarTransacao(),
            ),
          ).then((_) => _carregarTransacoes());
        },
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _indiceSelecionado == 0 ? const Color(0xFF1E3A8A) : Colors.grey,
              ),
              onPressed: () => setState(() => _indiceSelecionado = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.list,
                color: _indiceSelecionado == 1 ? const Color(0xFF1E3A8A) : Colors.grey,
              ),
              onPressed: () => setState(() => _indiceSelecionado = 1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(
                Icons.pie_chart,
                color: _indiceSelecionado == 2 ? const Color(0xFF1E3A8A) : Colors.grey,
              ),
              onPressed: () => setState(() => _indiceSelecionado = 2),
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: _indiceSelecionado == 3 ? const Color(0xFF1E3A8A) : Colors.grey,
              ),
              onPressed: () => setState(() => _indiceSelecionado = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirTelaAtual() {
    switch (_indiceSelecionado) {
      case 0:
        return _construirListaTransacoes();
      case 1:
        return const TelaTransacoes();
      case 2:
        return const TelaRelatorios();
      case 3:
        return _construirTelaConfiguracoes();
      default:
        return _construirListaTransacoes();
    }
  }

  Widget _construirListaTransacoes() {
    return BlocBuilder<BlocoTransacao, EstadoTransacao>(
      builder: (context, estadoTransacao) {
        return BlocBuilder<BlocoCategoria, EstadoCategoria>(
          builder: (context, estadoCategoria) {
            if (estadoTransacao is TransacaoCarregando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (estadoTransacao is TransacaoCarregada && estadoCategoria is CategoriaCarregada) {
              final transacoes = estadoTransacao.transacoes;
              final categorias = estadoCategoria.categorias;

              if (transacoes.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma transação encontrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: transacoes.length,
                itemBuilder: (context, index) {
                  final transacao = transacoes[index];
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
                      // Navigate to edit screen
                    },
                  );
                },
              );
            }

            return const Center(child: Text('Erro ao carregar transações'));
          },
        );
      },
    );
  }

  Widget _construirTelaConfiguracoes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Configurações',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
