import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/modelo_transacao.dart';
import '../modelos/modelo_categoria.dart';

class AuxiliarBancoDeDados {
  static final AuxiliarBancoDeDados instancia = AuxiliarBancoDeDados._init();
  static Database? _bancoDeDados;

  AuxiliarBancoDeDados._init();

  Future<Database> get bancoDeDados async {
    if (_bancoDeDados != null) return _bancoDeDados!;
    _bancoDeDados = await _iniciarBancoDeDados('dashboard_financeiro.db');
    return _bancoDeDados!;
  }

  Future<Database> _iniciarBancoDeDados(String caminho) async {
    final caminhoBancoDeDados = await getDatabasesPath();
    final path = join(caminhoBancoDeDados, caminho);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _criarBancoDeDados,
    );
  }

  Future<void> _criarBancoDeDados(Database db, int version) async {
    const tipoId = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const tipoTexto = 'TEXT NOT NULL';
    const tipoReal = 'REAL NOT NULL';
    const tipoInteiro = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE categorias (
        id $tipoId,
        nome $tipoTexto,
        codigoPontoIcone $tipoInteiro,
        valorCor $tipoInteiro,
        tipo $tipoTexto
      )
    ''');

    await db.execute('''
      CREATE TABLE transacoes (
        id $tipoId,
        descricao $tipoTexto,
        valor $tipoReal,
        data $tipoTexto,
        idCategoria $tipoInteiro,
        tipo $tipoTexto,
        observacao TEXT,
        FOREIGN KEY (idCategoria) REFERENCES categorias (id)
      )
    ''');
  }

  Future<List<ModeloCategoria>> obterCategorias() async {
    final db = await bancoDeDados;
    final mapas = await db.query('categorias');
    return mapas.map((mapa) => ModeloCategoria.deMapa(mapa)).toList();
  }

  Future<ModeloCategoria> obterCategoriaPorId(int id) async {
    final db = await bancoDeDados;
    final mapas = await db.query(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
    return ModeloCategoria.deMapa(mapas.first);
  }

  Future<int> inserirCategoria(ModeloCategoria categoria) async {
    final db = await bancoDeDados;
    return await db.insert('categorias', categoria.paraMapa());
  }

  Future<int> atualizarCategoria(ModeloCategoria categoria) async {
    final db = await bancoDeDados;
    return await db.update(
      'categorias',
      categoria.paraMapa(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> excluirCategoria(int id) async {
    final db = await bancoDeDados;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ModeloTransacao>> obterTransacoes({
    DateTime? dataInicio,
    DateTime? dataFim,
    List<int>? idsCategoria,
    String? tipo,
  }) async {
    final db = await bancoDeDados;
    String clausulaWhere = '1=1';
    List<dynamic> argumentosWhere = [];

    if (dataInicio != null) {
      clausulaWhere += ' AND data >= ?';
      argumentosWhere.add(dataInicio.toIso8601String());
    }

    if (dataFim != null) {
      clausulaWhere += ' AND data <= ?';
      argumentosWhere.add(dataFim.toIso8601String());
    }

    if (idsCategoria != null && idsCategoria.isNotEmpty) {
      final placeholders = List.filled(idsCategoria.length, '?').join(',');
      clausulaWhere += ' AND idCategoria IN ($placeholders)';
      argumentosWhere.addAll(idsCategoria);
    }

    if (tipo != null) {
      clausulaWhere += ' AND tipo = ?';
      argumentosWhere.add(tipo);
    }

    final mapas = await db.query(
      'transacoes',
      where: clausulaWhere,
      whereArgs: argumentosWhere,
      orderBy: 'data DESC',
    );

    return mapas.map((mapa) => ModeloTransacao.deMapa(mapa)).toList();
  }

  Future<int> inserirTransacao(ModeloTransacao transacao) async {
    final db = await bancoDeDados;
    return await db.insert('transacoes', transacao.paraMapa());
  }

  Future<int> atualizarTransacao(ModeloTransacao transacao) async {
    final db = await bancoDeDados;
    return await db.update(
      'transacoes',
      transacao.paraMapa(),
      where: 'id = ?',
      whereArgs: [transacao.id],
    );
  }

  Future<int> excluirTransacao(int id) async {
    final db = await bancoDeDados;
    return await db.delete(
      'transacoes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> obterResumo({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final transacoes = await obterTransacoes(
      dataInicio: dataInicio,
      dataFim: dataFim,
    );

    double receitas = 0;
    double despesas = 0;

    for (var transacao in transacoes) {
      if (transacao.tipo == TipoTransacao.receita) {
        receitas += transacao.valor;
      } else {
        despesas += transacao.valor;
      }
    }

    return {
      'receitas': receitas,
      'despesas': despesas,
      'saldo': receitas - despesas,
    };
  }

  Future<void> fechar() async {
    final db = await bancoDeDados;
    db.close();
  }
}
