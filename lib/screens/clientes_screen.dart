import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/cliente.dart';
import '../services/cep_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                if (appProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final clientes = _filtrarClientes(appProvider.clientes);

                if (clientes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum cliente encontrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return _buildClienteCard(cliente);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClienteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Buscar clientes...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  List<Cliente> _filtrarClientes(List<Cliente> clientes) {
    if (_searchQuery.isEmpty) return clientes;

    return clientes.where((cliente) {
      return cliente.nome.toLowerCase().contains(_searchQuery) ||
          cliente.telefone.contains(_searchQuery) ||
          (cliente.email?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Widget _buildClienteCard(Cliente cliente) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            cliente.nome.isNotEmpty ? cliente.nome[0].toUpperCase() : 'C',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        title: Text(
          cliente.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(cliente.telefone),
              ],
            ),
            if (cliente.email != null && cliente.email!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(cliente.email!)),
                ],
              ),
            ],
            if (cliente.endereco != null && cliente.endereco!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(cliente.endereco!)),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, cliente),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ver',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver Detalhes'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'editar',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
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

  void _handleMenuAction(String action, Cliente cliente) {
    switch (action) {
      case 'ver':
        _showClienteDetails(cliente);
        break;
      case 'editar':
        _showClienteDialog(cliente: cliente);
        break;
      case 'deletar':
        _showDeleteConfirmation(cliente);
        break;
    }
  }

  void _showClienteDetails(Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cliente.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Telefone', cliente.telefone, Icons.phone),
            if (cliente.email != null && cliente.email!.isNotEmpty)
              _buildDetailRow('Email', cliente.email!, Icons.email),
            if (cliente.endereco != null && cliente.endereco!.isNotEmpty)
              _buildDetailRow('Endereço', cliente.endereco!, Icons.location_on),
            if (cliente.dataNascimento != null)
              _buildDetailRow(
                'Data de Nascimento',
                DateFormat('dd/MM/yyyy').format(cliente.dataNascimento!),
                Icons.cake,
              ),
            if (cliente.observacoes != null && cliente.observacoes!.isNotEmpty)
              _buildDetailRow('Observações', cliente.observacoes!, Icons.notes),
            if (cliente.createdAt != null)
              _buildDetailRow(
                'Cadastrado em',
                DateFormat('dd/MM/yyyy HH:mm').format(cliente.createdAt!),
                Icons.schedule,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showClienteDialog(cliente: cliente);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClienteDialog({Cliente? cliente}) {
    showDialog(
      context: context,
      builder: (context) => ClienteFormDialog(cliente: cliente),
    );
  }

  void _showDeleteConfirmation(Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o cliente ${cliente.nome}?',
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
              ).deleteCliente(cliente.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class ClienteFormDialog extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormDialog({super.key, this.cliente});

  @override
  State<ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends State<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cepController = TextEditingController();
  final _observacoesController = TextEditingController();
  DateTime? _dataNascimento;
  bool _isLoadingCep = false;

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      _nomeController.text = widget.cliente!.nome;
      _telefoneController.text = widget.cliente!.telefone;
      _emailController.text = widget.cliente!.email ?? '';
      _cepController.text = widget.cliente!.cep ?? '';
      _enderecoController.text = widget.cliente!.endereco ?? '';
      _observacoesController.text = widget.cliente!.observacoes ?? '';
      _dataNascimento = widget.cliente!.dataNascimento;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '(00) 0 0000-0000',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _TelefoneInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefone é obrigatório';
                    }
                    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
                      return 'Telefone inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email inválido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cepController,
                        decoration: const InputDecoration(
                          labelText: 'CEP',
                          prefixIcon: Icon(Icons.location_city),
                          hintText: '00000-000',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CepInputFormatter(),
                        ],
                        onChanged: (value) {
                          if (value.replaceAll(RegExp(r'\D'), '').length == 8) {
                            _buscarCep(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isLoadingCep)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    child: Text(
                      _dataNascimento != null
                          ? DateFormat('dd/MM/yyyy').format(_dataNascimento!)
                          : 'Selecionar data',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacoesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon: Icon(Icons.notes),
                  ),
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
        ElevatedButton(onPressed: _saveCliente, child: const Text('Salvar')),
      ],
    );
  }

  Future<void> _buscarCep(String cep) async {
    setState(() {
      _isLoadingCep = true;
    });

    try {
      final cepData = await CepService.buscarCep(cep);
      if (cepData != null && mounted) {
        setState(() {
          _enderecoController.text = cepData['endereco_completo'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao buscar CEP: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCep = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dataNascimento ??
          DateTime.now().subtract(const Duration(days: 6570)), // 18 anos atrás
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dataNascimento = picked);
    }
  }

  void _saveCliente() {
    if (_formKey.currentState!.validate()) {
      final cliente = Cliente(
        id: widget.cliente?.id,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        cep: _cepController.text.isEmpty ? null : _cepController.text,
        endereco: _enderecoController.text.isEmpty
            ? null
            : _enderecoController.text,
        dataNascimento: _dataNascimento,
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
      );

      if (widget.cliente == null) {
        Provider.of<AppProvider>(context, listen: false).addCliente(cliente);
      } else {
        Provider.of<AppProvider>(context, listen: false).updateCliente(cliente);
      }

      Navigator.pop(context);
    }
  }
}

/// Formatter para máscara de telefone (00) 0 0000-0000
class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    
    // Adiciona o DDD
    if (digitsOnly.length >= 1) {
      formatted = '(${digitsOnly.substring(0, digitsOnly.length >= 2 ? 2 : 1)}';
    }
    
    if (digitsOnly.length >= 3) {
      formatted += ') ${digitsOnly[2]}';
    }
    
    // Adiciona o resto do número
    if (digitsOnly.length >= 4) {
      final restLength = digitsOnly.length - 3;
      final rest = digitsOnly.substring(3);
      
      if (restLength <= 4) {
        // Formato (00) 0 0000
        formatted += ' ${rest}';
      } else {
        // Formato (00) 0 0000-0000
        formatted += ' ${rest.substring(0, 4)}';
        if (restLength > 4) {
          formatted += '-${rest.substring(4, restLength > 8 ? 8 : restLength)}';
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter para máscara de CEP 00000-000
class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    
    if (digitsOnly.length <= 5) {
      formatted = digitsOnly;
    } else {
      formatted = '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, digitsOnly.length > 8 ? 8 : digitsOnly.length)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
