import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'barbearia.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de clientes
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT,
        endereco TEXT,
        data_nascimento TEXT,
        observacoes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabela de serviços
    await db.execute('''
      CREATE TABLE servicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT,
        preco REAL NOT NULL,
        duracao INTEGER NOT NULL,
        ativo INTEGER DEFAULT 1
      )
    ''');

    // Tabela de agendamentos
    await db.execute('''
      CREATE TABLE agendamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        servico_id INTEGER NOT NULL,
        data_agendamento TEXT NOT NULL,
        hora_inicio TEXT NOT NULL,
        hora_fim TEXT NOT NULL,
        status TEXT DEFAULT 'agendado',
        observacoes TEXT,
        valor_total REAL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cliente_id) REFERENCES clientes (id),
        FOREIGN KEY (servico_id) REFERENCES servicos (id)
      )
    ''');

    // Tabela de funcionários
    await db.execute('''
      CREATE TABLE funcionarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT,
        cargo TEXT NOT NULL,
        salario REAL,
        data_contratacao TEXT,
        ativo INTEGER DEFAULT 1
      )
    ''');

    // Inserir dados iniciais
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Serviços padrão
    await db.insert('servicos', {
      'nome': 'Corte Masculino',
      'descricao': 'Corte de cabelo masculino tradicional',
      'preco': 25.00,
      'duracao': 30,
    });

    await db.insert('servicos', {
      'nome': 'Barba',
      'descricao': 'Aparar e modelar barba',
      'preco': 15.00,
      'duracao': 20,
    });

    await db.insert('servicos', {
      'nome': 'Corte + Barba',
      'descricao': 'Pacote completo com corte e barba',
      'preco': 35.00,
      'duracao': 45,
    });

    await db.insert('servicos', {
      'nome': 'Sobrancelha',
      'descricao': 'Modelagem de sobrancelha',
      'preco': 10.00,
      'duracao': 15,
    });

    // Funcionário padrão
    await db.insert('funcionarios', {
      'nome': 'João Barbeiro',
      'telefone': '(11) 99999-9999',
      'email': 'joao@barbearia.com',
      'cargo': 'Barbeiro Senior',
      'salario': 2500.00,
      'data_contratacao': DateTime.now().toIso8601String(),
    });
  }

  // CRUD para Clientes
  Future<int> insertCliente(Map<String, dynamic> cliente) async {
    final db = await database;
    return await db.insert('clientes', cliente);
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await database;
    return await db.query('clientes', orderBy: 'nome ASC');
  }

  Future<Map<String, dynamic>?> getCliente(int id) async {
    final db = await database;
    final result = await db.query('clientes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateCliente(int id, Map<String, dynamic> cliente) async {
    final db = await database;
    return await db.update(
      'clientes',
      cliente,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCliente(int id) async {
    final db = await database;
    return await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para Serviços
  Future<int> insertServico(Map<String, dynamic> servico) async {
    final db = await database;
    return await db.insert('servicos', servico);
  }

  Future<List<Map<String, dynamic>>> getServicos() async {
    final db = await database;
    return await db.query('servicos', where: 'ativo = 1', orderBy: 'nome ASC');
  }

  Future<int> updateServico(int id, Map<String, dynamic> servico) async {
    final db = await database;
    return await db.update(
      'servicos',
      servico,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteServico(int id) async {
    final db = await database;
    return await db.update(
      'servicos',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD para Agendamentos
  Future<int> insertAgendamento(Map<String, dynamic> agendamento) async {
    final db = await database;
    return await db.insert('agendamentos', agendamento);
  }

  Future<List<Map<String, dynamic>>> getAgendamentos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome, s.preco as servico_preco
      FROM agendamentos a
      JOIN clientes c ON a.cliente_id = c.id
      JOIN servicos s ON a.servico_id = s.id
      ORDER BY a.data_agendamento DESC, a.hora_inicio ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getAgendamentosByDate(String date) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome
      FROM agendamentos a
      JOIN clientes c ON a.cliente_id = c.id
      JOIN servicos s ON a.servico_id = s.id
      WHERE a.data_agendamento = ?
      ORDER BY a.hora_inicio ASC
    ''',
      [date],
    );
  }

  Future<int> updateAgendamento(
    int id,
    Map<String, dynamic> agendamento,
  ) async {
    final db = await database;
    return await db.update(
      'agendamentos',
      agendamento,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAgendamento(int id) async {
    final db = await database;
    return await db.delete('agendamentos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para Funcionários
  Future<int> insertFuncionario(Map<String, dynamic> funcionario) async {
    final db = await database;
    return await db.insert('funcionarios', funcionario);
  }

  Future<List<Map<String, dynamic>>> getFuncionarios() async {
    final db = await database;
    return await db.query(
      'funcionarios',
      where: 'ativo = 1',
      orderBy: 'nome ASC',
    );
  }

  Future<int> updateFuncionario(
    int id,
    Map<String, dynamic> funcionario,
  ) async {
    final db = await database;
    return await db.update(
      'funcionarios',
      funcionario,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Relatórios
  Future<List<Map<String, dynamic>>> getRelatorioAgendamentos(
    String dataInicio,
    String dataFim,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT a.*, c.nome as cliente_nome, s.nome as servico_nome, s.preco
      FROM agendamentos a
      JOIN clientes c ON a.cliente_id = c.id
      JOIN servicos s ON a.servico_id = s.id
      WHERE a.data_agendamento BETWEEN ? AND ?
      ORDER BY a.data_agendamento DESC
    ''',
      [dataInicio, dataFim],
    );
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final db = await database;

    final hoje = DateTime.now();
    final hojeStr = hoje.toIso8601String().substring(0, 10);

    final totalClientes =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM clientes'),
        ) ??
        0;

    final agendamentosHoje =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM agendamentos WHERE data_agendamento = ?',
            [hojeStr],
          ),
        ) ??
        0;

    // Calcular receita do mês atual
    final inicioMes = DateTime(hoje.year, hoje.month, 1);
    final fimMes = DateTime(hoje.year, hoje.month + 1, 0);
    final inicioMesStr = inicioMes.toIso8601String().substring(0, 10);
    final fimMesStr = fimMes.toIso8601String().substring(0, 10);

    final receitaMesResult = await db.rawQuery('''
      SELECT SUM(COALESCE(a.valor_total, s.preco)) as total 
      FROM agendamentos a 
      JOIN servicos s ON a.servico_id = s.id 
      WHERE a.data_agendamento >= ? 
      AND a.data_agendamento <= ?
      AND a.status = 'concluido'
    ''', [inicioMesStr, fimMesStr]);

    final receitaMes = (receitaMesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'totalClientes': totalClientes,
      'agendamentosHoje': agendamentosHoje,
      'receitaMes': receitaMes,
    };
  }
}
