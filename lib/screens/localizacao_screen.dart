import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class LocalizacaoScreen extends StatefulWidget {
  const LocalizacaoScreen({super.key});

  @override
  State<LocalizacaoScreen> createState() => _LocalizacaoScreenState();
}

class _LocalizacaoScreenState extends State<LocalizacaoScreen> {
  Position? _currentPosition;
  Map<String, dynamic>? _barbeariaInfo;
  double? _distanceToBarbearia;
  bool _isLoadingLocation = false;
  String? _locationError;
  Map<String, dynamic>? _weatherData;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadBarbeariaInfo();
    _loadWeatherData();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBarbeariaCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildWeatherCard(),
            const SizedBox(height: 16),
            _buildDirectionsCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: _isLoadingLocation
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildBarbeariaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.store,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _barbeariaInfo?['nome'] ?? 'Barbearia Premium',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sua barbearia de confiança',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on,
              'Endereço',
              _barbeariaInfo?['endereco'] ??
                  'Rua das Flores, 123 - Centro, São Paulo - SP',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.phone,
              'Telefone',
              _barbeariaInfo?['telefone'] ?? '(11) 99999-9999',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Horário',
              _barbeariaInfo?['horario'] ?? 'Segunda a Sábado: 8h às 20h',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Sua Localização',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_locationError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Erro de Localização',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                          Text(_locationError!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => LocationService.openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('Configurações'),
                    ),
                  ),
                ],
              ),
            ] else if (_currentPosition != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Localização Obtida',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentAddress ?? 'Obtendo endereço...',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    if (_distanceToBarbearia != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Distância até a barbearia: ${LocationService.formatDistance(_distanceToBarbearia!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_searching,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Buscando localização...')),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_weatherData == null) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange.shade400),
                const SizedBox(width: 8),
                Text(
                  'Condições Climáticas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        size: 32,
                        color: Colors.orange.shade400,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_weatherData!['temperatura']}°C',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weatherData!['descricao'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sensação térmica: ${_weatherData!['sensacao_termica']}°C',
                      ),
                      Text(
                        'Máx: ${_weatherData!['temp_max']}°C | Mín: ${_weatherData!['temp_min']}°C',
                      ),
                      Text('Umidade: ${_weatherData!['humidade']}%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Como Chegar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.directions_car, color: Colors.blue.shade600),
              ),
              title: const Text('Abrir no Google Maps'),
              subtitle: const Text('Navegação por GPS'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _openGoogleMaps,
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_walk,
                  color: Colors.green.shade600,
                ),
              ),
              title: const Text('Direções a Pé'),
              subtitle: const Text('Rotas para pedestres'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _openWalkingDirections,
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_transit,
                  color: Colors.orange.shade600,
                ),
              ),
              title: const Text('Transporte Público'),
              subtitle: const Text('Ônibus e metrô'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _openPublicTransport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
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
    );
  }

  Future<void> _loadBarbeariaInfo() async {
    final info = await LocationService.getBarbeariaLocation();
    setState(() {
      _barbeariaInfo = info;
    });
  }

  Future<void> _loadWeatherData() async {
    try {
      // Tenta buscar dados reais da API
      final weather = await WeatherService.obterClimaPorCidade('Salvador,BR');
      if (weather != null && mounted) {
        setState(() {
          _weatherData = weather;
        });
      } else {
        // Se falhar, usa dados fictícios
        setState(() {
          _weatherData = WeatherService.obterDadosFicticios();
        });
      }
    } catch (e) {
      // Em caso de erro, usa dados fictícios
      if (mounted) {
        setState(() {
          _weatherData = WeatherService.obterDadosFicticios();
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await LocationService.getCurrentLocation();

      if (position != null) {
        final distance = await LocationService.getDistanceToBarbearia();
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _currentPosition = position;
          _distanceToBarbearia = distance;
          _currentAddress = address ?? 'Endereço não disponível';
        });
      } else {
        setState(() {
          _locationError = 'Não foi possível obter a localização';
        });
      }
    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _openGoogleMaps() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Abrindo Google Maps... (Funcionalidade em desenvolvimento)',
        ),
      ),
    );
    // Implementar abertura do Google Maps com coordenadas da barbearia
  }

  void _openWalkingDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Abrindo direções a pé... (Funcionalidade em desenvolvimento)',
        ),
      ),
    );
    // Implementar direções a pé
  }

  void _openPublicTransport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Abrindo transporte público... (Funcionalidade em desenvolvimento)',
        ),
      ),
    );
    // Implementar direções de transporte público
  }
}
