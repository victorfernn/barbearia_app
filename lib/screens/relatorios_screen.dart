import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/agendamento.dart';
import '../models/cliente.dart';
import '../services/report_service.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  DateTime _dataInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dataFim = DateTime.now();
  String _tipoRelatorio = 'agendamentos';
  List<dynamic> _relatorioData = [];
  bool _isLoadingRelatorio = false;

  @override
  void initState() {
    super.initState();
    _loadRelatorio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportFilters(),
            const SizedBox(height: 16),
            _buildReportActions(),
            const SizedBox(height: 16),
            _buildReportSummary(),
            const SizedBox(height: 16),
            _buildReportData(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros do Relatório',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipoRelatorio,
              decoration: const InputDecoration(
                labelText: 'Tipo de Relatório',
                prefixIcon: Icon(Icons.assessment),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'agendamentos',
                  child: Text('Relatório de Agendamentos'),
                ),
                DropdownMenuItem(
                  value: 'receita',
                  child: Text('Relatório de Receita'),
                ),
                DropdownMenuItem(
                  value: 'servicos',
                  child: Text('Relatório de Serviços'),
                ),
                DropdownMenuItem(
                  value: 'clientes',
                  child: Text('Relatório de Clientes'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _tipoRelatorio = value!;
                });
                _loadRelatorio();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data Início',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_dataInicio)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data Fim',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_dataFim)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoadingRelatorio ? null : _loadRelatorio,
                child: _isLoadingRelatorio
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Gerar Relatório'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportActions() {
    if (_relatorioData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exportar Relatório',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportToPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Exportar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportToExcel,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Exportar Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary() {
    if (_relatorioData.isEmpty) return const SizedBox.shrink();

    if (_tipoRelatorio == 'clientes') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo do Relatório',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                'Total de Clientes',
                _relatorioData.length.toString(),
                Icons.people,
                Colors.blue,
              ),
            ],
          ),
        ),
      );
    }

    // Para agendamentos, receita e serviços
    final agendamentos = _relatorioData.cast<Agendamento>();
    final totalAgendamentos = agendamentos.length;
    final totalReceita = agendamentos
        .where((a) => a.status == 'concluido')
        .fold(0.0, (sum, a) => sum + (a.valorTotal ?? a.servicoPreco ?? 0.0));

    final agendamentosConcluidos = agendamentos
        .where((a) => a.status == 'concluido')
        .length;

    final agendamentosCancelados = agendamentos
        .where((a) => a.status == 'cancelado')
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tipoRelatorio == 'receita' ? 'Resumo Financeiro' : 'Resumo do Período',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total de Agendamentos',
                    totalAgendamentos.toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Concluídos',
                    agendamentosConcluidos.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Cancelados',
                    agendamentosCancelados.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Receita Total',
                    'R\$ ${totalReceita.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportData() {
    if (_isLoadingRelatorio) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_relatorioData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.assessment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum dado encontrado para o período selecionado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados do Relatório',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_tipoRelatorio == 'clientes')
              _buildClientesList()
            else
              _buildAgendamentosList(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientesList() {
    final clientes = _relatorioData.cast<Cliente>();
    final displayCount = clientes.length > 10 ? 10 : clientes.length;
    
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final cliente = clientes[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
              title: Text(cliente.nome),
              subtitle: Text('${cliente.telefone}${cliente.email != null ? ' • ${cliente.email}' : ''}'),
              trailing: cliente.createdAt != null
                  ? Text(
                      DateFormat('dd/MM/yyyy').format(cliente.createdAt!),
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            );
          },
        ),
        if (clientes.length > 10) ...[
          const Divider(),
          Text(
            '... e mais ${clientes.length - 10} clientes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildAgendamentosList() {
    final agendamentos = _relatorioData.cast<Agendamento>();
    final displayCount = agendamentos.length > 10 ? 10 : agendamentos.length;
    
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final agendamento = agendamentos[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(agendamento.status),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: Text(
                agendamento.clienteNome ?? 'Cliente não informado',
              ),
              subtitle: Text(
                '${agendamento.servicoNome} - ${agendamento.dataFormatada}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    agendamento.valorFormatado,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                  Text(
                    agendamento.statusFormatado,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(agendamento.status),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (agendamentos.length > 10) ...[
          const Divider(),
          Text(
            '... e mais ${agendamentos.length - 10} registros',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'agendado':
        return Colors.blue;
      case 'confirmado':
        return Colors.green;
      case 'em_andamento':
        return Colors.orange;
      case 'concluido':
        return Colors.purple;
      case 'cancelado':
        return Colors.red;
      case 'nao_compareceu':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate(bool isInicio) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataInicio : _dataFim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
          if (_dataInicio.isAfter(_dataFim)) {
            _dataFim = _dataInicio.add(const Duration(days: 1));
          }
        } else {
          _dataFim = picked;
          if (_dataFim.isBefore(_dataInicio)) {
            _dataInicio = _dataFim.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  Future<void> _loadRelatorio() async {
    setState(() {
      _isLoadingRelatorio = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      switch (_tipoRelatorio) {
        case 'agendamentos':
        case 'receita':
        case 'servicos':
          final agendamentos = await appProvider.getRelatorioAgendamentos(
            _dataInicio,
            _dataFim,
          );
          setState(() {
            _relatorioData = agendamentos;
          });
          break;
        case 'clientes':
          setState(() {
            _relatorioData = appProvider.clientes;
          });
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao gerar relatório: $e')));
      }
    } finally {
      setState(() {
        _isLoadingRelatorio = false;
      });
    }
  }

  Future<void> _exportToPdf() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gerando PDF...')));

      final periodo =
          '${DateFormat('dd/MM/yyyy').format(_dataInicio)} a ${DateFormat('dd/MM/yyyy').format(_dataFim)}';
      String? filePath;

      switch (_tipoRelatorio) {
        case 'agendamentos':
          filePath = await ReportService.generateAgendamentosPDF(
            _relatorioData as List<Agendamento>,
            periodo,
          );
          break;
        case 'receita':
          filePath = await ReportService.generateReceitaPDF(
            _relatorioData as List<Agendamento>,
            periodo,
          );
          break;
        case 'servicos':
          filePath = await ReportService.generateServicosPDF(
            _relatorioData as List<Agendamento>,
            periodo,
          );
          break;
        case 'clientes':
          filePath = await ReportService.generateClientesPDF(
            _relatorioData.cast<Cliente>(),
          );
          break;
      }

      if (filePath != null) {
        await ReportService.shareFile(filePath, 'relatorio_$_tipoRelatorio.pdf');
      } else {
        throw Exception('Erro ao gerar arquivo PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar PDF: $e')));
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gerando Excel...')));

      final periodo =
          '${DateFormat('dd/MM/yyyy').format(_dataInicio)} a ${DateFormat('dd/MM/yyyy').format(_dataFim)}';
      String? filePath;

      switch (_tipoRelatorio) {
        case 'agendamentos':
          filePath = await ReportService.generateAgendamentosExcel(
            _relatorioData as List<Agendamento>,
            periodo,
          );
          break;
        case 'receita':
          filePath = await ReportService.generateReceitaExcel(
            _relatorioData as List<Agendamento>,
            periodo,
          );
          break;
        case 'servicos':
          filePath = await ReportService.generateServicosExcel(
            _relatorioData as List<Agendamento>,
            periodo,
          );
          break;
        case 'clientes':
          filePath = await ReportService.generateClientesExcel(
            _relatorioData.cast<Cliente>(),
          );
          break;
      }

      if (filePath != null) {
        await ReportService.shareFile(filePath, 'relatorio_$_tipoRelatorio.xlsx');
      } else {
        throw Exception('Erro ao gerar arquivo Excel');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao exportar Excel: $e')));
      }
    }
  }
}
