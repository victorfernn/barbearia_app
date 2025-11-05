class Servico {
  final int? id;
  final String nome;
  final String? descricao;
  final double preco;
  final int duracao; // em minutos
  final bool ativo;

  Servico({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.duracao,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'duracao': duracao,
      'ativo': ativo ? 1 : 0,
    };
  }

  static Servico fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id']?.toInt(),
      nome: map['nome'] ?? '',
      descricao: map['descricao'],
      preco: (map['preco'] ?? 0.0).toDouble(),
      duracao: map['duracao']?.toInt() ?? 0,
      ativo: (map['ativo'] ?? 1) == 1,
    );
  }

  Servico copyWith({
    int? id,
    String? nome,
    String? descricao,
    double? preco,
    int? duracao,
    bool? ativo,
  }) {
    return Servico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      duracao: duracao ?? this.duracao,
      ativo: ativo ?? this.ativo,
    );
  }

  String get duracaoFormatada {
    if (duracao < 60) {
      return '${duracao}min';
    } else {
      final horas = duracao ~/ 60;
      final minutos = duracao % 60;
      if (minutos == 0) {
        return '${horas}h';
      } else {
        return '${horas}h ${minutos}min';
      }
    }
  }

  String get precoFormatado {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  String toString() {
    return 'Servico{id: $id, nome: $nome, preco: $preco, duracao: $duracao}';
  }
}
