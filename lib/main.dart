import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocos/transacoes/transacao_bloc.dart';
import 'blocos/categorias/categoria_bloc.dart';
import 'blocos/filtros/filtro_bloc.dart';
import 'blocos/relatorios/relatorio_bloc.dart';
import 'telas/tela_inicio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BlocoTransacao()),
        BlocProvider(
          create: (context) => BlocoCategoria()..add(CarregarCategorias()),
        ),
        BlocProvider(create: (context) => BlocoFiltro()),
        BlocProvider(create: (context) => BlocoRelatorio()),
      ],
      child: MaterialApp(
        title: 'Bill Controler',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1E3A8A),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
          ),
          useMaterial3: true,
        ),
        home: const TelaInicio(),
      ),
    );
  }
}
