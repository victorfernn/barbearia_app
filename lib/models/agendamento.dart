class Agendamento {
  final int? id;
  final int clienteId;
  final int servicoId;
  final DateTime dataAgendamento;
  final String horaInicio;
  final String horaFim;
  final String status;
  final String? observacoes;
  final double? valorTotal;
  final DateTime? createdAt;

  // Campos relacionados (joins)
  final String? clienteNome;
  final String? servicoNome;
  final double? servicoPreco;

  Agendamento({
    this.id,
    required this.clienteId,
    required this.servicoId,
    required this.dataAgendamento,
    required this.horaInicio,
    required this.horaFim,
    this.status = 'agendado',
    this.observacoes,
    this.valorTotal,
    this.createdAt,
    this.clienteNome,
    this.servicoNome,
    this.servicoPreco,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'servico_id': servicoId,
      'data_agendamento': dataAgendamento.toIso8601String().substring(0, 10),
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'status': status,
      'observacoes': observacoes,
      'valor_total': valorTotal,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static Agendamento fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id']?.toInt(),
      clienteId: map['cliente_id']?.toInt() ?? 0,
      servicoId: map['servico_id']?.toInt() ?? 0,
      dataAgendamento: DateTime.parse(
        map['data_agendamento'] ?? DateTime.now().toIso8601String(),
      ),
      horaInicio: map['hora_inicio'] ?? '',
      horaFim: map['hora_fim'] ?? '',
      status: map['status'] ?? 'agendado',
      observacoes: map['observacoes'],
      valorTotal: map['valor_total']?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      clienteNome: map['cliente_nome'],
      servicoNome: map['servico_nome'],
      servicoPreco: map['servico_preco']?.toDouble(),
    );
  }

  Agendamento copyWith({
    int? id,
    int? clienteId,
    int? servicoId,
    DateTime? dataAgendamento,
    String? horaInicio,
    String? horaFim,
    String? status,
    String? observacoes,
    double? valorTotal,
    DateTime? createdAt,
    String? clienteNome,
    String? servicoNome,
    double? servicoPreco,
  }) {
    return Agendamento(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      servicoId: servicoId ?? this.servicoId,
      dataAgendamento: dataAgendamento ?? this.dataAgendamento,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      valorTotal: valorTotal ?? this.valorTotal,
      createdAt: createdAt ?? this.createdAt,
      clienteNome: clienteNome ?? this.clienteNome,
      servicoNome: servicoNome ?? this.servicoNome,
      servicoPreco: servicoPreco ?? this.servicoPreco,
    );
  }

  String get dataFormatada {
    return '${dataAgendamento.day.toString().padLeft(2, '0')}/'
        '${dataAgendamento.month.toString().padLeft(2, '0')}/'
        '${dataAgendamento.year}';
  }

  String get statusFormatado {
    switch (status.toLowerCase()) {
      case 'agendado':
        return 'Agendado';
      case 'confirmado':
        return 'Confirmado';
      case 'em_andamento':
        return 'Em Andamento';
      case 'concluido':
        return 'Concluído';
      case 'cancelado':
        return 'Cancelado';
      case 'nao_compareceu':
        return 'Não Compareceu';
      default:
        return status;
    }
  }

  String get valorFormatado {
    final valor = valorTotal ?? servicoPreco ?? 0.0;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  String toString() {
    return 'Agendamento{id: $id, clienteId: $clienteId, dataAgendamento: $dataAgendamento, status: $status}';
  }
}
