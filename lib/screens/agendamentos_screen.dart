import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/agendamento.dart';
import '../models/cliente.dart';
import '../models/servico.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  String _filtroStatus = 'todos';
  DateTime _filtroData = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                if (appProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final agendamentos = _filtrarAgendamentos(
                  appProvider.agendamentos,
                );

                if (agendamentos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum agendamento encontrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: agendamentos.length,
                  itemBuilder: (context, index) {
                    final agendamento = agendamentos[index];
                    return _buildAgendamentoCard(agendamento);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAgendamentoDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filtroStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'agendado',
                        child: Text('Agendado'),
                      ),
                      DropdownMenuItem(
                        value: 'confirmado',
                        child: Text('Confirmado'),
                      ),
                      DropdownMenuItem(
                        value: 'em_andamento',
                        child: Text('Em Andamento'),
                      ),
                      DropdownMenuItem(
                        value: 'concluido',
                        child: Text('Concluído'),
                      ),
                      DropdownMenuItem(
                        value: 'cancelado',
                        child: Text('Cancelado'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtroStatus = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        suffixIcon: Icon(Icons.calendar_today),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_filtroData)),
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

  List<Agendamento> _filtrarAgendamentos(List<Agendamento> agendamentos) {
    return agendamentos.where((agendamento) {
      final statusMatch =
          _filtroStatus == 'todos' || agendamento.status == _filtroStatus;
      final dataMatch =
          agendamento.dataAgendamento.day == _filtroData.day &&
          agendamento.dataAgendamento.month == _filtroData.month &&
          agendamento.dataAgendamento.year == _filtroData.year;
      return statusMatch && dataMatch;
    }).toList();
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getStatusColor(agendamento.status),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        title: Text(agendamento.clienteNome ?? 'Cliente não informado'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Serviço: ${agendamento.servicoNome}'),
            Text('Horário: ${agendamento.horaInicio} - ${agendamento.horaFim}'),
            Text('Valor: ${agendamento.valorFormatado}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, agendamento),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'status',
              child: ListTile(
                leading: Icon(Icons.update),
                title: Text('Alterar Status'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'deletar',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Deletar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
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

  void _handleMenuAction(String action, Agendamento agendamento) {
    switch (action) {
      case 'editar':
        _showAgendamentoDialog(agendamento: agendamento);
        break;
      case 'status':
        _showStatusDialog(agendamento);
        break;
      case 'deletar':
        _showDeleteConfirmation(agendamento);
        break;
    }
  }

  void _showAgendamentoDialog({Agendamento? agendamento}) {
    showDialog(
      context: context,
      builder: (context) => AgendamentoFormDialog(agendamento: agendamento),
    );
  }

  void _showStatusDialog(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: StatefulBuilder(
          builder: (context, setState) {
            String selectedStatus = agendamento.status;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [
                        'agendado',
                        'confirmado',
                        'em_andamento',
                        'concluido',
                        'cancelado',
                        'nao_compareceu',
                      ]
                      .map(
                        (status) => ListTile(
                          title: Text(_formatStatus(status)),
                          leading: Icon(
                            selectedStatus == status 
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: selectedStatus == status 
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                          onTap: () {
                            _updateStatus(agendamento, status);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            );
          },
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'agendado':
        return 'Agendado';
      case 'confirmado':
        return 'Confirmado';
      case 'em_andamento':
        return 'Em Andamento';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      case 'nao_compareceu':
        return 'Não Compareceu';
      default:
        return status;
    }
  }

  void _updateStatus(Agendamento agendamento, String newStatus) {
    final updatedAgendamento = agendamento.copyWith(status: newStatus);
    Provider.of<AppProvider>(
      context,
      listen: false,
    ).updateAgendamento(updatedAgendamento);
  }

  void _showDeleteConfirmation(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o agendamento de ${agendamento.clienteNome}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppProvider>(
                context,
                listen: false,
              ).deleteAgendamento(agendamento.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filtroData,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _filtroData) {
      setState(() {
        _filtroData = picked;
      });
    }
  }
}

class AgendamentoFormDialog extends StatefulWidget {
  final Agendamento? agendamento;

  const AgendamentoFormDialog({super.key, this.agendamento});

  @override
  State<AgendamentoFormDialog> createState() => _AgendamentoFormDialogState();
}

class _AgendamentoFormDialogState extends State<AgendamentoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  Cliente? _selectedCliente;
  Servico? _selectedServico;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _horaInicio = TimeOfDay.now();
  TimeOfDay _horaFim = TimeOfDay.now();
  final _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.agendamento != null) {
      _selectedDate = widget.agendamento!.dataAgendamento;
      _horaInicio = TimeOfDay(
        hour: int.parse(widget.agendamento!.horaInicio.split(':')[0]),
        minute: int.parse(widget.agendamento!.horaInicio.split(':')[1]),
      );
      _horaFim = TimeOfDay(
        hour: int.parse(widget.agendamento!.horaFim.split(':')[0]),
        minute: int.parse(widget.agendamento!.horaFim.split(':')[1]),
      );
      _observacoesController.text = widget.agendamento!.observacoes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.agendamento == null ? 'Novo Agendamento' : 'Editar Agendamento',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return DropdownButtonFormField<Cliente>(
                      initialValue: _selectedCliente,
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      items: appProvider.clientes
                          .map(
                            (cliente) => DropdownMenuItem(
                              value: cliente,
                              child: Text(cliente.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCliente = value),
                      validator: (value) =>
                          value == null ? 'Selecione um cliente' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<AppProvider>(
                  builder: (context, appProvider, child) {
                    return DropdownButtonFormField<Servico>(
                      initialValue: _selectedServico,
                      decoration: const InputDecoration(labelText: 'Serviço'),
                      items: appProvider.servicos
                          .map(
                            (servico) => DropdownMenuItem(
                              value: servico,
                              child: Text(
                                '${servico.nome} - ${servico.precoFormatado}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedServico = value),
                      validator: (value) =>
                          value == null ? 'Selecione um serviço' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Hora Início',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(_horaInicio.format(context)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Hora Fim',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(_horaFim.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacoesController,
                  decoration: const InputDecoration(labelText: 'Observações'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveAgendamento,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horaInicio : _horaFim,
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
        } else {
          _horaFim = picked;
        }
      });
    }
  }

  void _saveAgendamento() {
    if (_formKey.currentState!.validate()) {
      final agendamento = Agendamento(
        id: widget.agendamento?.id,
        clienteId: _selectedCliente!.id!,
        servicoId: _selectedServico!.id!,
        dataAgendamento: _selectedDate,
        horaInicio:
            '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}',
        horaFim:
            '${_horaFim.hour.toString().padLeft(2, '0')}:${_horaFim.minute.toString().padLeft(2, '0')}',
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
        valorTotal: _selectedServico!.preco,
        status: widget.agendamento?.status ?? 'agendado',
      );

      if (widget.agendamento == null) {
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).addAgendamento(agendamento);
      } else {
        Provider.of<AppProvider>(
          context,
          listen: false,
        ).updateAgendamento(agendamento);
      }

      Navigator.pop(context);
    }
  }
}
