class Funcionario {
  final int? id;
  final String nome;
  final String telefone;
  final String? email;
  final String cargo;
  final double? salario;
  final DateTime? dataContratacao;
  final bool ativo;

  Funcionario({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    required this.cargo,
    this.salario,
    this.dataContratacao,
    this.ativo = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'cargo': cargo,
      'salario': salario,
      'data_contratacao': dataContratacao?.toIso8601String(),
      'ativo': ativo ? 1 : 0,
    };
  }

  static Funcionario fromMap(Map<String, dynamic> map) {
    return Funcionario(
      id: map['id']?.toInt(),
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'],
      cargo: map['cargo'] ?? '',
      salario: map['salario']?.toDouble(),
      dataContratacao: map['data_contratacao'] != null
          ? DateTime.tryParse(map['data_contratacao'])
          : null,
      ativo: (map['ativo'] ?? 1) == 1,
    );
  }

  Funcionario copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? email,
    String? cargo,
    double? salario,
    DateTime? dataContratacao,
    bool? ativo,
  }) {
    return Funcionario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      cargo: cargo ?? this.cargo,
      salario: salario ?? this.salario,
      dataContratacao: dataContratacao ?? this.dataContratacao,
      ativo: ativo ?? this.ativo,
    );
  }

  String get salarioFormatado {
    if (salario == null) return 'Não informado';
    return 'R\$ ${salario!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get dataContratacaoFormatada {
    if (dataContratacao == null) return 'Não informada';
    return '${dataContratacao!.day.toString().padLeft(2, '0')}/'
        '${dataContratacao!.month.toString().padLeft(2, '0')}/'
        '${dataContratacao!.year}';
  }

  @override
  String toString() {
    return 'Funcionario{id: $id, nome: $nome, cargo: $cargo}';
  }
}
