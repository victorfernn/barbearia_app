class Cliente {
  final int? id;
  final String nome;
  final String telefone;
  final String? email;
  final String? endereco;
  final DateTime? dataNascimento;
  final String? observacoes;
  final DateTime? createdAt;

  Cliente({
    this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.endereco,
    this.dataNascimento,
    this.observacoes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'observacoes': observacoes,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static Cliente fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id']?.toInt(),
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'],
      endereco: map['endereco'],
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.tryParse(map['data_nascimento'])
          : null,
      observacoes: map['observacoes'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
    );
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? email,
    String? endereco,
    DateTime? dataNascimento,
    String? observacoes,
    DateTime? createdAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, telefone: $telefone}';
  }
}
