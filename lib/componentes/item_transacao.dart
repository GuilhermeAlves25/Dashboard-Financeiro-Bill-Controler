import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modelos/modelo_transacao.dart';
import '../modelos/modelo_categoria.dart';

class ItemListaTransacao extends StatelessWidget {
  final ModeloTransacao transacao;
  final ModeloCategoria categoria;
  final VoidCallback aoTocar;

  const ItemListaTransacao({
    super.key,
    required this.transacao,
    required this.categoria,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final eReceita = transacao.tipo == TipoTransacao.receita;

    return InkWell(
      onTap: aoTocar,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoria.cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoria.icone,
                color: categoria.cor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transacao.descricao,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoria.nome,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatador.format(transacao.valor),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: eReceita ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM').format(transacao.data),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
