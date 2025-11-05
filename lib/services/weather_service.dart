import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class WeatherService {
  static final Logger _logger = Logger();
  // Usando OpenWeatherMap API (gratuita)
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey =
      'SUA_API_KEY_AQUI'; // Substitua por uma chave válida

  static Future<Map<String, dynamic>?> obterClimaPorCidade(
    String cidade,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?q=$cidade&appid=$_apiKey&units=metric&lang=pt_br',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'cidade': data['name'],
          'pais': data['sys']['country'],
          'temperatura': data['main']['temp'].round(),
          'sensacao_termica': data['main']['feels_like'].round(),
          'temp_min': data['main']['temp_min'].round(),
          'temp_max': data['main']['temp_max'].round(),
          'humidade': data['main']['humidity'],
          'pressao': data['main']['pressure'],
          'descricao': data['weather'][0]['description'],
          'icone': data['weather'][0]['icon'],
          'velocidade_vento': data['wind']['speed'],
          'direcao_vento': data['wind']['deg'],
          'nuvens': data['clouds']['all'],
          'visibilidade': data['visibility'],
          'nascer_sol': DateTime.fromMillisecondsSinceEpoch(
            data['sys']['sunrise'] * 1000,
            isUtc: true,
          ).toLocal(),
          'por_sol': DateTime.fromMillisecondsSinceEpoch(
            data['sys']['sunset'] * 1000,
            isUtc: true,
          ).toLocal(),
        };
      } else if (response.statusCode == 401) {
        throw Exception('API Key inválida ou não configurada');
      } else if (response.statusCode == 404) {
        throw Exception('Cidade não encontrada');
      } else {
        throw Exception(
          'Erro ao obter dados climáticos: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e('Erro no serviço de clima: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> obterClimaPorCoordenadas(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=pt_br',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'cidade': data['name'],
          'pais': data['sys']['country'],
          'temperatura': data['main']['temp'].round(),
          'sensacao_termica': data['main']['feels_like'].round(),
          'temp_min': data['main']['temp_min'].round(),
          'temp_max': data['main']['temp_max'].round(),
          'humidade': data['main']['humidity'],
          'pressao': data['main']['pressure'],
          'descricao': data['weather'][0]['description'],
          'icone': data['weather'][0]['icon'],
          'velocidade_vento': data['wind']['speed'],
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      return null;
    } catch (e) {
      _logger.e('Erro ao obter clima por coordenadas: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> obterPrevisao5Dias(
    String cidade,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/forecast?q=$cidade&appid=$_apiKey&units=metric&lang=pt_br',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];

        return list
            .map<Map<String, dynamic>>(
              (item) => {
                'data_hora': DateTime.fromMillisecondsSinceEpoch(
                  item['dt'] * 1000,
                  isUtc: true,
                ).toLocal(),
                'temperatura': item['main']['temp'].round(),
                'temp_min': item['main']['temp_min'].round(),
                'temp_max': item['main']['temp_max'].round(),
                'humidade': item['main']['humidity'],
                'descricao': item['weather'][0]['description'],
                'icone': item['weather'][0]['icon'],
                'velocidade_vento': item['wind']['speed'],
                'probabilidade_chuva': item['pop'] * 100,
              },
            )
            .toList();
      }

      return [];
    } catch (e) {
      _logger.e('Erro ao obter previsão: $e');
      return [];
    }
  }

  static String obterIconeUrl(String iconeId) {
    return 'https://openweathermap.org/img/wn/$iconeId@2x.png';
  }

  static String obterDescricaoClima(int codigo) {
    switch (codigo) {
      case 200:
        return 'Trovoada com chuva fraca';
      case 201:
        return 'Trovoada com chuva';
      case 202:
        return 'Trovoada com chuva forte';
      case 300:
        return 'Garoa leve';
      case 301:
        return 'Garoa';
      case 302:
        return 'Garoa intensa';
      case 500:
        return 'Chuva leve';
      case 501:
        return 'Chuva moderada';
      case 502:
        return 'Chuva forte';
      case 600:
        return 'Neve leve';
      case 601:
        return 'Neve';
      case 602:
        return 'Neve forte';
      case 701:
        return 'Névoa';
      case 711:
        return 'Fumaça';
      case 721:
        return 'Neblina';
      case 741:
        return 'Nevoeiro';
      case 800:
        return 'Céu limpo';
      case 801:
        return 'Poucas nuvens';
      case 802:
        return 'Nuvens dispersas';
      case 803:
        return 'Nuvens quebradas';
      case 804:
        return 'Nublado';
      default:
        return 'Condição desconhecida';
    }
  }

  // Método para obter dados fictícios quando não há API key válida
  static Map<String, dynamic> obterDadosFicticios() {
    return {
      'cidade': 'São Paulo',
      'pais': 'BR',
      'temperatura': 23,
      'sensacao_termica': 25,
      'temp_min': 18,
      'temp_max': 28,
      'humidade': 65,
      'pressao': 1013,
      'descricao': 'Parcialmente nublado',
      'icone': '02d',
      'velocidade_vento': 3.5,
      'direcao_vento': 180,
      'nuvens': 40,
      'visibilidade': 10000,
      'nascer_sol': DateTime.now().copyWith(hour: 6, minute: 30),
      'por_sol': DateTime.now().copyWith(hour: 18, minute: 45),
    };
  }
}
