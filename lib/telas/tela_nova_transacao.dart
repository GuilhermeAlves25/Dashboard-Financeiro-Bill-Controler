import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocos/transacoes/transacao_bloc.dart';
import '../blocos/categorias/categoria_bloc.dart';
import '../modelos/modelo_transacao.dart';
import '../modelos/modelo_categoria.dart';
import 'tela_nova_categoria.dart';

class TelaAdicionarTransacao extends StatefulWidget {
  final ModeloTransacao? transacao;

  const TelaAdicionarTransacao({super.key, this.transacao});

  @override
  State<TelaAdicionarTransacao> createState() => _EstadoTelaAdicionarTransacao();
}

class _EstadoTelaAdicionarTransacao extends State<TelaAdicionarTransacao> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorValor = TextEditingController();
  final _controladorDescricao = TextEditingController();
  final _controladorObservacao = TextEditingController();
  
  DateTime _dataSelecionada = DateTime.now();
  int? _idCategoriaSelecionada;
  TipoTransacao _tipoSelecionado = TipoTransacao.despesa;
  String _moedaSelecionada = 'BRL';

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {
      _controladorValor.text = widget.transacao!.valor.toString();
      _controladorDescricao.text = widget.transacao!.descricao;
      _controladorObservacao.text = widget.transacao!.observacao ?? '';
      _dataSelecionada = widget.transacao!.data;
      _idCategoriaSelecionada = widget.transacao!.idCategoria;
      _tipoSelecionado = widget.transacao!.tipo;
    }
  }

  @override
  void dispose() {
    _controladorValor.dispose();
    _controladorDescricao.dispose();
    _controladorObservacao.dispose();
    super.dispose();
  }

  void _salvarTransacao() {
    if (_chaveFormulario.currentState!.validate() && _idCategoriaSelecionada != null) {
      final transacao = ModeloTransacao(
        id: widget.transacao?.id,
        descricao: _controladorDescricao.text,
        valor: double.parse(_controladorValor.text.replaceAll(',', '.')),
        data: _dataSelecionada,
        idCategoria: _idCategoriaSelecionada!,
        tipo: _tipoSelecionado,
        observacao: _controladorObservacao.text.isEmpty ? null : _controladorObservacao.text,
      );

      if (widget.transacao == null) {
        context.read<BlocoTransacao>().add(AdicionarTransacao(transacao));
      } else {
        context.read<BlocoTransacao>().add(AtualizarTransacao(transacao));
      }

      Navigator.pop(context);
    } else if (_idCategoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.transacao == null ? 'Nova transação' : 'Editar transação',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _chaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Valor da transação',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controladorValor,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0,00',
                          border: InputBorder.none,
                          prefixText: 'R\$',
                          prefixStyle: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite um valor';
                          }
                          return null;
                        },
                      ),
                    ),
                    DropdownButton<String>(
                      value: _moedaSelecionada,
                      items: ['BRL', 'USD', 'EUR'].map((moeda) {
                        return DropdownMenuItem(
                          value: moeda,
                          child: Text(moeda),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _moedaSelecionada = value!);
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: _construirBotaoTipo(
                        rotulo: 'Receita',
                        icone: Icons.arrow_upward,
                        tipo: TipoTransacao.receita,
                        cor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _construirBotaoTipo(
                        rotulo: 'Despesa',
                        icone: Icons.arrow_downward,
                        tipo: TipoTransacao.despesa,
                        cor: Colors.red,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categoria',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TelaAdicionarCategoria(tipo: _tipoSelecionado.name),
                          ),
                        );
                      },
                      child: const Text('+ Nova Categoria'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                BlocBuilder<BlocoCategoria, EstadoCategoria>(
                  builder: (context, state) {
                    if (state is CategoriaCarregada) {
                      final categorias = state.categorias
                          .where((c) => c.tipo == _tipoSelecionado.name)
                          .toList();
                      
                      if (categorias.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Nenhuma categoria disponível para ${_tipoSelecionado == TipoTransacao.receita ? "receitas" : "despesas"}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }
                      
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categorias.map((categoria) {
                          final isSelected = _idCategoriaSelecionada == categoria.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _idCategoriaSelecionada = categoria.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? categoria.cor.withAlpha((255 * 0.2).round())
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? categoria.cor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    categoria.icone,
                                    size: 20,
                                    color: isSelected
                                        ? categoria.cor
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    categoria.nome,
                                    style: TextStyle(
                                      color: isSelected
                                          ? categoria.cor
                                          : Colors.grey[700],
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else if (state is ErroCategoria) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 10),
                            Text(
                              'Erro ao carregar categorias',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              state.mensagem,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                context.read<BlocoCategoria>().add(CarregarCategorias());
                              },
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is CategoriaInicial) {
                      context.read<BlocoCategoria>().add(CarregarCategorias());
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'Descrição',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _controladorDescricao,
                  decoration: InputDecoration(
                    hintText: 'Digite a descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite uma descrição';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dataSelecionada,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _dataSelecionada = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Observação (opcional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _controladorObservacao,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Digite uma observação',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _salvarTransacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.transacao == null ? 'Adicionar' : 'Atualizar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirBotaoTipo({
    required String rotulo,
    required IconData icone,
    required TipoTransacao tipo,
    required Color cor,
  }) {
    final isSelected = _tipoSelecionado == tipo;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoSelecionado = tipo;
          _idCategoriaSelecionada = null; 
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? cor.withAlpha((255 * 0.1).round()) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cor,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              rotulo,
              style: TextStyle(
                color: isSelected ? cor : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
