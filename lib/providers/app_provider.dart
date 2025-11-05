import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/cliente.dart';
import '../models/agendamento.dart';
import '../models/servico.dart';
import '../models/funcionario.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Cliente> _clientes = [];
  List<Agendamento> _agendamentos = [];
  List<Servico> _servicos = [];
  List<Funcionario> _funcionarios = [];
  Map<String, dynamic> _dashboardData = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Cliente> get clientes => _clientes;
  List<Agendamento> get agendamentos => _agendamentos;
  List<Servico> get servicos => _servicos;
  List<Funcionario> get funcionarios => _funcionarios;
  Map<String, dynamic> get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Métodos para controle de estado
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Carregar dados iniciais
  Future<void> loadInitialData() async {
    setLoading(true);
    clearError();

    try {
      await Future.wait([
        loadClientes(),
        loadAgendamentos(),
        loadServicos(),
        loadFuncionarios(),
        loadDashboardData(),
      ]);
    } catch (e) {
      setError('Erro ao carregar dados: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // CRUD Clientes
  Future<void> loadClientes() async {
    try {
      final clientesData = await _databaseHelper.getClientes();
      _clientes = clientesData.map((data) => Cliente.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar clientes: ${e.toString()}');
    }
  }

  Future<void> addCliente(Cliente cliente) async {
    try {
      await _databaseHelper.insertCliente(cliente.toMap());
      await loadClientes();
    } catch (e) {
      setError('Erro ao adicionar cliente: ${e.toString()}');
    }
  }

  Future<void> updateCliente(Cliente cliente) async {
    try {
      if (cliente.id != null) {
        await _databaseHelper.updateCliente(cliente.id!, cliente.toMap());
        await loadClientes();
      }
    } catch (e) {
      setError('Erro ao atualizar cliente: ${e.toString()}');
    }
  }

  Future<void> deleteCliente(int id) async {
    try {
      await _databaseHelper.deleteCliente(id);
      await loadClientes();
    } catch (e) {
      setError('Erro ao deletar cliente: ${e.toString()}');
    }
  }

  // CRUD Agendamentos
  Future<void> loadAgendamentos() async {
    try {
      final agendamentosData = await _databaseHelper.getAgendamentos();
      _agendamentos = agendamentosData
          .map((data) => Agendamento.fromMap(data))
          .toList();
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar agendamentos: ${e.toString()}');
    }
  }

  Future<void> addAgendamento(Agendamento agendamento) async {
    try {
      await _databaseHelper.insertAgendamento(agendamento.toMap());
      await loadAgendamentos();
      await loadDashboardData(); // Atualizar dashboard
    } catch (e) {
      setError('Erro ao adicionar agendamento: ${e.toString()}');
    }
  }

  Future<void> updateAgendamento(Agendamento agendamento) async {
    try {
      if (agendamento.id != null) {
        await _databaseHelper.updateAgendamento(
          agendamento.id!,
          agendamento.toMap(),
        );
        await loadAgendamentos();
        await loadDashboardData(); // Atualizar dashboard
      }
    } catch (e) {
      setError('Erro ao atualizar agendamento: ${e.toString()}');
    }
  }

  Future<void> deleteAgendamento(int id) async {
    try {
      await _databaseHelper.deleteAgendamento(id);
      await loadAgendamentos();
      await loadDashboardData(); // Atualizar dashboard
    } catch (e) {
      setError('Erro ao deletar agendamento: ${e.toString()}');
    }
  }

  // CRUD Serviços
  Future<void> loadServicos() async {
    try {
      final servicosData = await _databaseHelper.getServicos();
      _servicos = servicosData.map((data) => Servico.fromMap(data)).toList();
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar serviços: ${e.toString()}');
    }
  }

  Future<void> addServico(Servico servico) async {
    try {
      await _databaseHelper.insertServico(servico.toMap());
      await loadServicos();
    } catch (e) {
      setError('Erro ao adicionar serviço: ${e.toString()}');
    }
  }

  Future<void> updateServico(Servico servico) async {
    try {
      if (servico.id != null) {
        await _databaseHelper.updateServico(servico.id!, servico.toMap());
        await loadServicos();
      }
    } catch (e) {
      setError('Erro ao atualizar serviço: ${e.toString()}');
    }
  }

  // CRUD Funcionários
  Future<void> loadFuncionarios() async {
    try {
      final funcionariosData = await _databaseHelper.getFuncionarios();
      _funcionarios = funcionariosData
          .map((data) => Funcionario.fromMap(data))
          .toList();
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar funcionários: ${e.toString()}');
    }
  }

  Future<void> addFuncionario(Funcionario funcionario) async {
    try {
      await _databaseHelper.insertFuncionario(funcionario.toMap());
      await loadFuncionarios();
    } catch (e) {
      setError('Erro ao adicionar funcionário: ${e.toString()}');
    }
  }

  Future<void> updateFuncionario(Funcionario funcionario) async {
    try {
      if (funcionario.id != null) {
        await _databaseHelper.updateFuncionario(
          funcionario.id!,
          funcionario.toMap(),
        );
        await loadFuncionarios();
      }
    } catch (e) {
      setError('Erro ao atualizar funcionário: ${e.toString()}');
    }
  }

  // Dashboard
  Future<void> loadDashboardData() async {
    try {
      _dashboardData = await _databaseHelper.getDashboardData();
      notifyListeners();
    } catch (e) {
      setError('Erro ao carregar dados do dashboard: ${e.toString()}');
    }
  }

  // Buscar agendamentos por data
  Future<List<Agendamento>> getAgendamentosByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().substring(0, 10);
      final agendamentosData = await _databaseHelper.getAgendamentosByDate(
        dateStr,
      );
      return agendamentosData.map((data) => Agendamento.fromMap(data)).toList();
    } catch (e) {
      setError('Erro ao carregar agendamentos por data: ${e.toString()}');
      return [];
    }
  }

  // Relatórios
  Future<List<Agendamento>> getRelatorioAgendamentos(
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    try {
      final inicioStr = dataInicio.toIso8601String().substring(0, 10);
      final fimStr = dataFim.toIso8601String().substring(0, 10);
      final agendamentosData = await _databaseHelper.getRelatorioAgendamentos(
        inicioStr,
        fimStr,
      );
      return agendamentosData.map((data) => Agendamento.fromMap(data)).toList();
    } catch (e) {
      setError('Erro ao gerar relatório: ${e.toString()}');
      return [];
    }
  }
}
