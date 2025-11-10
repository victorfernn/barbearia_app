import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:logger/logger.dart';
import '../models/agendamento.dart';
import '../models/cliente.dart';


class ReportService {
  static final Logger _logger = Logger();
  static Future<String> _getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Gerar relatório de agendamentos em PDF
  static Future<String?> generateAgendamentosPDF(
    List<Agendamento> agendamentos,
    String periodo,
  ) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy');
      final now = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'BARBEARIA PREMIUM',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Relatório de Agendamentos - $periodo',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      'Gerado em: ${dateFormat.format(now)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Resumo
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Total de Agendamentos: ${agendamentos.length}'),
                    pw.Text('Receita Total: R\$ ${_calculateTotalRevenue(agendamentos).toStringAsFixed(2)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Tabela de agendamentos
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FixedColumnWidth(80),
                  5: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Cabeçalho da tabela
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Data', isHeader: true),
                      _buildTableCell('Cliente', isHeader: true),
                      _buildTableCell('Serviço', isHeader: true),
                      _buildTableCell('Horário', isHeader: true),
                      _buildTableCell('Valor', isHeader: true),
                      _buildTableCell('Status', isHeader: true),
                    ],
                  ),
                  // Dados
                  ...agendamentos.map((agendamento) => pw.TableRow(
                    children: [
                      _buildTableCell(agendamento.dataFormatada),
                      _buildTableCell(agendamento.clienteNome ?? ''),
                      _buildTableCell(agendamento.servicoNome ?? ''),
                      _buildTableCell('${agendamento.horaInicio}-${agendamento.horaFim}'),
                      _buildTableCell(agendamento.valorFormatado),
                      _buildTableCell(agendamento.statusFormatado),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );

      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_agendamentos_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar PDF: $e');
      return null;
    }
  }

  // Gerar relatório de agendamentos em Excel
  static Future<String?> generateAgendamentosExcel(
    List<Agendamento> agendamentos,
    String periodo,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Agendamentos'];

      // Cabeçalhos
      final headers = [
        'Data',
        'Cliente',
        'Serviço',
        'Horário Início',
        'Horário Fim',
        'Valor',
        'Status',
        'Observações'
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
      }

      // Dados
      for (int i = 0; i < agendamentos.length; i++) {
        final agendamento = agendamentos[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = 
            TextCellValue(agendamento.dataFormatada);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = 
            TextCellValue(agendamento.clienteNome ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = 
            TextCellValue(agendamento.servicoNome ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = 
            TextCellValue(agendamento.horaInicio);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = 
            TextCellValue(agendamento.horaFim);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = 
            DoubleCellValue(agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = 
            TextCellValue(agendamento.statusFormatado);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = 
            TextCellValue(agendamento.observacoes ?? '');
      }

      // Não há método setColumnAutoFit na versão atual do excel package

      // Salvar arquivo
      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_agendamentos_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar Excel: $e');
      return null;
    }
  }

  // Gerar relatório de clientes em PDF
  static Future<String?> generateClientesPDF(List<Cliente> clientes) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy');
      final now = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'BARBEARIA PREMIUM',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Relatório de Clientes',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      'Gerado em: ${dateFormat.format(now)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Resumo
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('Total de Clientes: ${clientes.length}'),
              ),
              pw.SizedBox(height: 20),

              // Tabela de clientes
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(3),
                },
                children: [
                  // Cabeçalho da tabela
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Nome', isHeader: true),
                      _buildTableCell('Telefone', isHeader: true),
                      _buildTableCell('Email', isHeader: true),
                      _buildTableCell('Endereço', isHeader: true),
                    ],
                  ),
                  // Dados
                  ...clientes.map((cliente) => pw.TableRow(
                    children: [
                      _buildTableCell(cliente.nome),
                      _buildTableCell(cliente.telefone),
                      _buildTableCell(cliente.email ?? ''),
                      _buildTableCell(cliente.endereco ?? ''),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );

      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_clientes_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar PDF de clientes: $e');
      return null;
    }
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static double _calculateTotalRevenue(List<Agendamento> agendamentos) {
    return agendamentos.fold(0.0, (total, agendamento) {
      if (agendamento.status == 'concluido') {
        return total + (agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0);
      }
      return total;
    });
  }

  // Gerar relatório de clientes em Excel
  static Future<String?> generateClientesExcel(List<Cliente> clientes) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Clientes'];

      // Cabeçalhos
      final headers = ['Nome', 'Telefone', 'Email', 'Endereço', 'Data Nascimento', 'Data Cadastro'];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
      }

      // Dados
      for (int i = 0; i < clientes.length; i++) {
        final cliente = clientes[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = 
            TextCellValue(cliente.nome);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = 
            TextCellValue(cliente.telefone);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = 
            TextCellValue(cliente.email ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = 
            TextCellValue(cliente.endereco ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = 
            TextCellValue(cliente.dataNascimento != null ? DateFormat('dd/MM/yyyy').format(cliente.dataNascimento!) : '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = 
            TextCellValue(cliente.createdAt != null ? DateFormat('dd/MM/yyyy').format(cliente.createdAt!) : '');
      }

      // Salvar arquivo
      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_clientes_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar Excel de clientes: $e');
      return null;
    }
  }

  // Gerar relatório de receita em PDF
  static Future<String?> generateReceitaPDF(
    List<Agendamento> agendamentos,
    String periodo,
  ) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy');
      final now = DateTime.now();

      // Calcular estatísticas
      final agendamentosConcluidos = agendamentos.where((a) => a.status == 'concluido').toList();
      final totalReceita = _calculateTotalRevenue(agendamentos);
      
      // Agrupar receita por mês
      final receitaPorMes = <String, double>{};
      for (var agendamento in agendamentosConcluidos) {
        final mes = DateFormat('MM/yyyy').format(agendamento.dataAgendamento);
        receitaPorMes[mes] = (receitaPorMes[mes] ?? 0) + (agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'BARBEARIA PREMIUM',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Relatório de Receita - $periodo',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      'Gerado em: ${dateFormat.format(now)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Resumo Financeiro
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RESUMO FINANCEIRO',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total de Agendamentos Concluídos:'),
                        pw.Text('${agendamentosConcluidos.length}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Receita Total:'),
                        pw.Text(
                          'R\$ ${totalReceita.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Ticket Médio:'),
                        pw.Text(
                          'R\$ ${agendamentosConcluidos.isEmpty ? "0.00" : (totalReceita / agendamentosConcluidos.length).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Receita por Mês
              if (receitaPorMes.isNotEmpty) ...[
                pw.Text(
                  'RECEITA POR MÊS',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('Mês/Ano', isHeader: true),
                        _buildTableCell('Receita', isHeader: true),
                      ],
                    ),
                    ...receitaPorMes.entries.map((entry) => pw.TableRow(
                      children: [
                        _buildTableCell(entry.key),
                        _buildTableCell('R\$ ${entry.value.toStringAsFixed(2)}'),
                      ],
                    )),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],

              // Detalhamento
              pw.Text(
                'DETALHAMENTO DE RECEITAS',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FixedColumnWidth(80),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Data', isHeader: true),
                      _buildTableCell('Cliente', isHeader: true),
                      _buildTableCell('Serviço', isHeader: true),
                      _buildTableCell('Valor', isHeader: true),
                    ],
                  ),
                  ...agendamentosConcluidos.map((agendamento) => pw.TableRow(
                    children: [
                      _buildTableCell(agendamento.dataFormatada),
                      _buildTableCell(agendamento.clienteNome ?? ''),
                      _buildTableCell(agendamento.servicoNome ?? ''),
                      _buildTableCell(agendamento.valorFormatado),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );

      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_receita_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar PDF de receita: $e');
      return null;
    }
  }

  // Gerar relatório de receita em Excel
  static Future<String?> generateReceitaExcel(
    List<Agendamento> agendamentos,
    String periodo,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Receita'];

      // Filtrar apenas concluídos
      final agendamentosConcluidos = agendamentos.where((a) => a.status == 'concluido').toList();

      // Cabeçalhos
      final headers = ['Data', 'Cliente', 'Serviço', 'Valor', 'Forma Pagamento'];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
      }

      // Dados
      for (int i = 0; i < agendamentosConcluidos.length; i++) {
        final agendamento = agendamentosConcluidos[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = 
            TextCellValue(agendamento.dataFormatada);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = 
            TextCellValue(agendamento.clienteNome ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = 
            TextCellValue(agendamento.servicoNome ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = 
            DoubleCellValue(agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = 
            TextCellValue('Dinheiro'); // Pode ser expandido quando houver esse campo
      }

      // Adicionar linha de total
      final totalRow = agendamentosConcluidos.length + 2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: totalRow)).value = 
          TextCellValue('TOTAL:');
      final totalReceita = _calculateTotalRevenue(agendamentos);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRow)).value = 
          DoubleCellValue(totalReceita);

      // Salvar arquivo
      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_receita_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar Excel de receita: $e');
      return null;
    }
  }

  // Gerar relatório de serviços em PDF
  static Future<String?> generateServicosPDF(
    List<Agendamento> agendamentos,
    String periodo,
  ) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd/MM/yyyy');
      final now = DateTime.now();

      // Agrupar por serviço
      final servicosMap = <String, Map<String, dynamic>>{};
      for (var agendamento in agendamentos) {
        final servicoNome = agendamento.servicoNome ?? 'Não informado';
        if (!servicosMap.containsKey(servicoNome)) {
          servicosMap[servicoNome] = {
            'quantidade': 0,
            'receita': 0.0,
            'concluidos': 0,
          };
        }
        servicosMap[servicoNome]!['quantidade'] = (servicosMap[servicoNome]!['quantidade'] as int) + 1;
        if (agendamento.status == 'concluido') {
          servicosMap[servicoNome]!['receita'] = (servicosMap[servicoNome]!['receita'] as double) + 
              (agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0);
          servicosMap[servicoNome]!['concluidos'] = (servicosMap[servicoNome]!['concluidos'] as int) + 1;
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'BARBEARIA PREMIUM',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Relatório de Serviços - $periodo',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      'Gerado em: ${dateFormat.format(now)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Resumo
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(4),
                  color: PdfColors.grey100,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Total de Serviços Diferentes: ${servicosMap.length}'),
                    pw.Text('Total de Atendimentos: ${agendamentos.length}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Tabela de serviços
              pw.Text(
                'DESEMPENHO POR SERVIÇO',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FixedColumnWidth(80),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(100),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('Serviço', isHeader: true),
                      _buildTableCell('Agendados', isHeader: true),
                      _buildTableCell('Concluídos', isHeader: true),
                      _buildTableCell('Receita', isHeader: true),
                    ],
                  ),
                  ...servicosMap.entries.map((entry) => pw.TableRow(
                    children: [
                      _buildTableCell(entry.key),
                      _buildTableCell(entry.value['quantidade'].toString()),
                      _buildTableCell(entry.value['concluidos'].toString()),
                      _buildTableCell('R\$ ${(entry.value['receita'] as double).toStringAsFixed(2)}'),
                    ],
                  )),
                ],
              ),
            ];
          },
        ),
      );

      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_servicos_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar PDF de serviços: $e');
      return null;
    }
  }

  // Gerar relatório de serviços em Excel
  static Future<String?> generateServicosExcel(
    List<Agendamento> agendamentos,
    String periodo,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Serviços'];

      // Agrupar por serviço
      final servicosMap = <String, Map<String, dynamic>>{};
      for (var agendamento in agendamentos) {
        final servicoNome = agendamento.servicoNome ?? 'Não informado';
        if (!servicosMap.containsKey(servicoNome)) {
          servicosMap[servicoNome] = {
            'quantidade': 0,
            'receita': 0.0,
            'concluidos': 0,
          };
        }
        servicosMap[servicoNome]!['quantidade'] = (servicosMap[servicoNome]!['quantidade'] as int) + 1;
        if (agendamento.status == 'concluido') {
          servicosMap[servicoNome]!['receita'] = (servicosMap[servicoNome]!['receita'] as double) + 
              (agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0);
          servicosMap[servicoNome]!['concluidos'] = (servicosMap[servicoNome]!['concluidos'] as int) + 1;
        }
      }

      // Cabeçalhos
      final headers = ['Serviço', 'Total Agendamentos', 'Concluídos', 'Receita', 'Ticket Médio'];

      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
      }

      // Dados
      int row = 1;
      for (var entry in servicosMap.entries) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = 
            TextCellValue(entry.key);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = 
            IntCellValue(entry.value['quantidade'] as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = 
            IntCellValue(entry.value['concluidos'] as int);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = 
            DoubleCellValue(entry.value['receita'] as double);
        final ticketMedio = (entry.value['concluidos'] as int) > 0 
            ? (entry.value['receita'] as double) / (entry.value['concluidos'] as int)
            : 0.0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = 
            DoubleCellValue(ticketMedio);
        row++;
      }

      // Salvar arquivo
      final String dir = await _getDocumentsDirectory();
      final String fileName = 'relatorio_servicos_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '$dir/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      _logger.e('Erro ao gerar Excel de serviços: $e');
      return null;
    }
  }

  static Future<void> shareFile(String filePath, String fileName) async {
    try {
      
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(filePath),
      ],
          // ignore: deprecated_member_use
          text: 'Relatório da Barbearia Premium - $fileName');
    } catch (e) {
      _logger.e('Erro ao compartilhar arquivo: $e');
    }
  }
}