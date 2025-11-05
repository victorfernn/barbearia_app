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
        cell.value = headers[i];
      }

      // Dados
      for (int i = 0; i < agendamentos.length; i++) {
        final agendamento = agendamentos[i];
        final row = i + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = 
            agendamento.dataFormatada;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = 
            agendamento.clienteNome ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = 
            agendamento.servicoNome ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = 
            agendamento.horaInicio;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = 
            agendamento.horaFim;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = 
            agendamento.valorTotal ?? agendamento.servicoPreco ?? 0.0;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = 
            agendamento.statusFormatado;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = 
            agendamento.observacoes ?? '';
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