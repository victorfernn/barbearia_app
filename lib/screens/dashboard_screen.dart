import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/weather_service.dart';
import '../models/agendamento.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
    _loadDashboardData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar dados sempre que a tela for exibida
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Provider.of<AppProvider>(
      context,
      listen: false,
    ).loadDashboardData();
  }

  Future<void> _loadWeatherData() async {
    try {
      // Tenta buscar dados reais da API
      final weather = await WeatherService.obterClimaPorCidade('Salvador,BR');
      if (weather != null && mounted) {
        setState(() {
          weatherData = weather;
        });
      } else {
        // Se falhar, usa dados fictícios
        if (mounted) {
          setState(() {
            weatherData = WeatherService.obterDadosFicticios();
          });
        }
      }
    } catch (e) {
      // Em caso de erro, usa dados fictícios
      if (mounted) {
        setState(() {
          weatherData = WeatherService.obterDadosFicticios();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboardData();
          await _loadWeatherData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildStatsCards(),
              const SizedBox(height: 16),
              _buildWeatherCard(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildRecentAppointments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo de volta!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aqui está um resumo do seu dia',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final dashboardData = appProvider.dashboardData;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Clientes',
                '${dashboardData['totalClientes'] ?? 0}',
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Hoje',
                '${dashboardData['agendamentosHoje'] ?? 0}',
                Icons.today,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Receita Mês',
                'R\$ ${(dashboardData['receitaMes'] ?? 0.0).toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (weatherData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.wb_sunny, size: 48, color: Colors.orange.shade400),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weatherData!['temperatura']}°C',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weatherData!['descricao'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    weatherData!['cidade'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Máx: ${weatherData!['temp_max']}°C'),
                Text('Mín: ${weatherData!['temp_min']}°C'),
                Text('Umidade: ${weatherData!['humidade']}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  'Novo\nAgendamento',
                  Icons.add_circle,
                  Colors.green,
                  () => _navigateToScreen(1),
                ),
                _buildQuickActionButton(
                  'Novo\nCliente',
                  Icons.person_add,
                  Colors.blue,
                  () => _navigateToScreen(2),
                ),
                _buildQuickActionButton(
                  'Ver\nRelatórios',
                  Icons.assessment,
                  Colors.purple,
                  () => _navigateToScreen(4),
                ),
                _buildQuickActionButton(
                  'Ver\nLocalização',
                  Icons.location_on,
                  Colors.red,
                  () => _navigateToScreen(5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRecentAppointments() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final recentAppointments = appProvider.agendamentos.take(5).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agendamentos Recentes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToScreen(1),
                      child: const Text('Ver Todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentAppointments.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Nenhum agendamento encontrado'),
                    ),
                  )
                else
                  ...recentAppointments.map(
                    (appointment) => ListTile(
                      onTap: () => _showAgendamentoDetails(appointment),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(appointment.status),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        appointment.clienteNome ?? 'Cliente não informado',
                      ),
                      subtitle: Text(
                        '${appointment.servicoNome} - ${appointment.dataFormatada} às ${appointment.horaInicio}',
                      ),
                      trailing: Chip(
                        label: Text(
                          appointment.statusFormatado,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(
                          appointment.status,
                        ).withValues(alpha: 0.1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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

  void _navigateToScreen(int index) {
    // Usar o GlobalKey do HomeScreen para trocar de aba
    homeScreenKey.currentState?.navigateToTab(index);
  }

  void _showAgendamentoDetails(Agendamento agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agendamento.clienteNome ?? 'Agendamento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Serviço', agendamento.servicoNome ?? 'N/A'),
              const SizedBox(height: 8),
              _buildDetailRow('Data', agendamento.dataFormatada),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Horário',
                '${agendamento.horaInicio} - ${agendamento.horaFim}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Status', agendamento.statusFormatado),
              const SizedBox(height: 8),
              _buildDetailRow('Valor', agendamento.valorFormatado),
              if (agendamento.observacoes != null &&
                  agendamento.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Observações', agendamento.observacoes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToScreen(1);
            },
            child: const Text('Ver Todos'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
