import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CepService {
  static final Logger _logger = Logger();
  static const String _baseUrl = 'https://viacep.com.br/ws';

  static Future<Map<String, dynamic>?> buscarCep(String cep) async {
    try {
      // Remove caracteres não numéricos do CEP
      final cepLimpo = cep.replaceAll(RegExp(r'\D'), '');

      if (cepLimpo.length != 8) {
        throw Exception('CEP deve conter 8 dígitos');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$cepLimpo/json/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['erro'] == true) {
          throw Exception('CEP não encontrado');
        }

        return {
          'cep': data['cep'],
          'logradouro': data['logradouro'],
          'complemento': data['complemento'],
          'bairro': data['bairro'],
          'localidade': data['localidade'],
          'uf': data['uf'],
          'ibge': data['ibge'],
          'gia': data['gia'],
          'ddd': data['ddd'],
          'siafi': data['siafi'],
          'endereco_completo':
              '${data['logradouro']}, ${data['bairro']}, ${data['localidade']} - ${data['uf']}',
        };
      } else {
        throw Exception('Erro ao consultar CEP: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Erro no serviço de CEP: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> buscarCepsPorEndereco(
    String uf,
    String cidade,
    String logradouro,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$uf/$cidade/$logradouro/json/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return data
              .map<Map<String, dynamic>>(
                (item) => {
                  'cep': item['cep'],
                  'logradouro': item['logradouro'],
                  'complemento': item['complemento'],
                  'bairro': item['bairro'],
                  'localidade': item['localidade'],
                  'uf': item['uf'],
                },
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.e('Erro ao buscar CEPs por endereço: $e');
      return [];
    }
  }

  static String formatarCep(String cep) {
    final cepLimpo = cep.replaceAll(RegExp(r'\D'), '');
    if (cepLimpo.length == 8) {
      return '${cepLimpo.substring(0, 5)}-${cepLimpo.substring(5)}';
    }
    return cep;
  }

  static bool validarCep(String cep) {
    final cepLimpo = cep.replaceAll(RegExp(r'\D'), '');
    return cepLimpo.length == 8 && RegExp(r'^\d{8}$').hasMatch(cepLimpo);
  }
}
