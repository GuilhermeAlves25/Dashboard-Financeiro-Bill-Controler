import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocos/categorias/categoria_bloc.dart';
import '../modelos/modelo_categoria.dart';

class TelaAdicionarCategoria extends StatefulWidget {
  final String tipo;

  const TelaAdicionarCategoria({super.key, required this.tipo});

  @override
  State<TelaAdicionarCategoria> createState() => _EstadoTelaAdicionarCategoria();
}

class _EstadoTelaAdicionarCategoria extends State<TelaAdicionarCategoria> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controladorNome = TextEditingController();
  Color _corSelecionada = Colors.blue;
  IconData _iconeSelecionado = Icons.star;

  final List<Color> _cores = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple, 
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan, 
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime, 
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey
  ];

  final List<IconData> _icones = [
    Icons.home, Icons.directions_car, Icons.restaurant, Icons.shopping_cart,
    Icons.local_hospital, Icons.school, Icons.movie, Icons.flight, 
    Icons.attach_money, Icons.work, Icons.trending_up, Icons.phone, 
    Icons.pets, Icons.fitness_center, Icons.card_giftcard, Icons.book,
  ];

  void _salvarCategoria() {
    if (_chaveFormulario.currentState!.validate()) {
      final novaCategoria = ModeloCategoria(
        nome: _controladorNome.text,
        icone: _iconeSelecionado,
        cor: _corSelecionada,
        tipo: widget.tipo,
      );
      context.read<BlocoCategoria>().add(AdicionarCategoria(novaCategoria));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Categoria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _chaveFormulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _controladorNome,
                decoration: const InputDecoration(
                  labelText: 'Nome da Categoria',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite um nome para a categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text('Cor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cores.map((cor) {
                  return GestureDetector(
                    onTap: () => setState(() => _corSelecionada = cor),
                    child: CircleAvatar(
                      backgroundColor: cor,
                      child: _corSelecionada == cor ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Text('Ícone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icones.map((icone) {
                  return GestureDetector(
                    onTap: () => setState(() => _iconeSelecionado = icone),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _iconeSelecionado == icone ? Theme.of(context).primaryColor.withAlpha(50) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icone, color: _iconeSelecionado == icone ? Theme.of(context).primaryColor : Colors.black54),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarCategoria,
                  child: const Text('Salvar Categoria'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
