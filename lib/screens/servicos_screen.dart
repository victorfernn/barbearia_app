import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/servico.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
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

                final servicos = _filtrarServicos(appProvider.servicos);

                if (servicos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.content_cut, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum serviço encontrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    final servico = servicos[index];
                    return _buildServicoCard(servico);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServicoDialog(),
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
            labelText: 'Buscar serviços...',
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

  List<Servico> _filtrarServicos(List<Servico> servicos) {
    if (_searchQuery.isEmpty) return servicos;

    return servicos.where((servico) {
      return servico.nome.toLowerCase().contains(_searchQuery) ||
          (servico.descricao?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  Widget _buildServicoCard(Servico servico) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.content_cut,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          servico.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (servico.descricao != null && servico.descricao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(servico.descricao!),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  servico.duracaoFormatada,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  servico.precoFormatado,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, servico),
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
              value: 'duplicar',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Duplicar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'desativar',
              child: ListTile(
                leading: Icon(Icons.visibility_off, color: Colors.orange),
                title: Text(
                  'Desativar',
                  style: TextStyle(color: Colors.orange),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        isThreeLine: servico.descricao != null && servico.descricao!.isNotEmpty,
      ),
    );
  }

  void _handleMenuAction(String action, Servico servico) {
    switch (action) {
      case 'editar':
        _showServicoDialog(servico: servico);
        break;
      case 'duplicar':
        _duplicarServico(servico);
        break;
      case 'desativar':
        _showDesativarConfirmation(servico);
        break;
    }
  }

  void _showServicoDialog({Servico? servico}) {
    showDialog(
      context: context,
      builder: (context) => ServicoFormDialog(servico: servico),
    );
  }

  void _duplicarServico(Servico servico) {
    final novoServico = Servico(
      nome: '${servico.nome} (Cópia)',
      descricao: servico.descricao,
      preco: servico.preco,
      duracao: servico.duracao,
    );
    Provider.of<AppProvider>(context, listen: false).addServico(novoServico);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Serviço duplicado com sucesso!')),
    );
  }

  void _showDesativarConfirmation(Servico servico) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Desativação'),
        content: Text(
          'Tem certeza que deseja desativar o serviço "${servico.nome}"?\n\nEle não aparecerá mais na lista de agendamentos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final servicoDesativado = servico.copyWith(ativo: false);
              Provider.of<AppProvider>(
                context,
                listen: false,
              ).updateServico(servicoDesativado);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Serviço desativado com sucesso!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }
}

class ServicoFormDialog extends StatefulWidget {
  final Servico? servico;

  const ServicoFormDialog({super.key, this.servico});

  @override
  State<ServicoFormDialog> createState() => _ServicoFormDialogState();
}

class _ServicoFormDialogState extends State<ServicoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _duracaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _nomeController.text = widget.servico!.nome;
      _descricaoController.text = widget.servico!.descricao ?? '';
      _precoController.text = widget.servico!.preco
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _duracaoController.text = widget.servico!.duracao.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.servico == null ? 'Novo Serviço' : 'Editar Serviço'),
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
                    labelText: 'Nome do Serviço *',
                    prefixIcon: Icon(Icons.content_cut),
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
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precoController,
                        decoration: const InputDecoration(
                          labelText: 'Preço *',
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: '0,00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Preço é obrigatório';
                          }
                          final preco = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (preco == null || preco <= 0) {
                            return 'Preço inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _duracaoController,
                        decoration: const InputDecoration(
                          labelText: 'Duração (min) *',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Duração é obrigatória';
                          }
                          final duracao = int.tryParse(value);
                          if (duracao == null || duracao <= 0) {
                            return 'Duração inválida';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'O preço e duração serão utilizados automaticamente nos agendamentos.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
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
        ElevatedButton(onPressed: _saveServico, child: const Text('Salvar')),
      ],
    );
  }

  void _saveServico() {
    if (_formKey.currentState!.validate()) {
      final preco = double.parse(_precoController.text.replaceAll(',', '.'));
      final duracao = int.parse(_duracaoController.text);

      final servico = Servico(
        id: widget.servico?.id,
        nome: _nomeController.text,
        descricao: _descricaoController.text.isEmpty
            ? null
            : _descricaoController.text,
        preco: preco,
        duracao: duracao,
        ativo: widget.servico?.ativo ?? true,
      );

      if (widget.servico == null) {
        Provider.of<AppProvider>(context, listen: false).addServico(servico);
      } else {
        Provider.of<AppProvider>(context, listen: false).updateServico(servico);
      }

      Navigator.pop(context);
    }
  }
}
