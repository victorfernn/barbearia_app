import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final Logger _logger = Logger();
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verifica se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }

      // Verifica permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      // Obtém a localização atual
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return position;
    } catch (e) {
      _logger.e('Erro ao obter localização: $e');
      return null;
    }
  }

  static Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  static String getPermissionStatusMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Permissão de localização negada';
      case LocationPermission.deniedForever:
        return 'Permissão de localização negada permanentemente';
      case LocationPermission.whileInUse:
        return 'Permissão concedida apenas durante o uso';
      case LocationPermission.always:
        return 'Permissão concedida sempre';
      default:
        return 'Status de permissão desconhecido';
    }
  }

  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Coordenadas da barbearia (exemplo - substitua pelas coordenadas reais)
  static const double barbeariaLatitude = -23.5505; // São Paulo
  static const double barbeariaLongitude = -46.6333; // São Paulo

  static Future<Map<String, dynamic>> getBarbeariaLocation() async {
    return {
      'latitude': barbeariaLatitude,
      'longitude': barbeariaLongitude,
      'nome': 'Barbearia Premium',
      'endereco': 'Rua das Flores, 123 - Centro, São Paulo - SP',
      'telefone': '(11) 99999-9999',
      'horario': 'Segunda a Sábado: 8h às 20h',
    };
  }

  static Future<double?> getDistanceToBarbearia() async {
    try {
      Position? currentPosition = await getCurrentLocation();
      if (currentPosition != null) {
        double distance = await getDistanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          barbeariaLatitude,
          barbeariaLongitude,
        );
        return distance;
      }
    } catch (e) {
      _logger.e('Erro ao calcular distância para a barbearia: $e');
    }
    return null;
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  static Future<Stream<Position>?> getLocationStream() async {
    try {
      LocationPermission permission = await checkLocationPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestLocationPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Atualiza a cada 10 metros
          ),
        );
      }
    } catch (e) {
      _logger.e('Erro ao obter stream de localização: $e');
    }
    return null;
  }
}
