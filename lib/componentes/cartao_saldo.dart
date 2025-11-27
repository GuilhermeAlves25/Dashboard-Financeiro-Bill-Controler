import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartaoSaldo extends StatelessWidget {
  final String rotulo;
  final double valor;
  final bool eReceita;

  const CartaoSaldo({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.eReceita,
  });

  @override
  Widget build(BuildContext context) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                eReceita ? Icons.arrow_upward : Icons.arrow_downward,
                color: eReceita ? Colors.greenAccent : Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                rotulo,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatador.format(valor),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
