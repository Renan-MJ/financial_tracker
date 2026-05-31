import '../../common/config/dependencies.dart';
import '../../common/types/date_filter_type.dart';
import '../../domain/entity/transaction_entity.dart';
import 'package:financial_tracker/ui/controller/home_page_controller.dart';
import 'package:financial_tracker/ui/widget/date_filter_transactions.dart';
import 'package:financial_tracker/ui/widget/summary_carousel.dart';
import 'package:financial_tracker/ui/widget/transaction_sheet.dart';
import 'package:financial_tracker/ui/widget/transaction_sheets_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../common/utils/formatter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomePageController viewModelController;
  bool _isFilterVisible = false;

  // Cor idêntica ao início do gradiente do SummaryCard/SummaryChart
  static const Color corTopoEscuro = Color(0xFF1E252B);

  @override
  void initState() {
    viewModelController = injector.get<HomePageController>();
    viewModelController.load.execute();
    super.initState();
  }

  void _toggleFilterVisibility() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  void _exportarRelatorioFinanceiro(BuildContext context) {
    final incomesList = viewModelController.incomes.value;
    final expensesList = viewModelController.expenses.value;
    final totalInc = viewModelController.totalIncome.value;
    final totalExp = viewModelController.totalExpense.value;
    final balanco = totalInc - totalExp;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('=== FINANCIAL TRACKER - EXTRATO COPIADO ===');
    buffer.writeln('Gerado em: 31/05/2026'); // DATA ATUAL DO SISTEMA
    buffer.writeln('-------------------------------------------');
    buffer.writeln('RECEITAS TOTAIS: ${Formatter.formatCurrency(totalInc)}');
    buffer.writeln('DESPESAS TOTAIS: ${Formatter.formatCurrency(totalExp)}');
    buffer.writeln('BALANÇO ATUAL:   ${Formatter.formatCurrency(balanco)}');
    buffer.writeln('-------------------------------------------');

    buffer.writeln('\n--- DETALHES DAS RECEITAS ---');
    if (incomesList.isEmpty) {
      buffer.writeln('Nenhuma receita no período.');
    } else {
      for (var t in incomesList) {
        buffer.writeln('- ${t.title}: ${Formatter.formatCurrency(t.amount)} (${Formatter.formatDate(t.date)})');
      }
    }

    buffer.writeln('\n--- DETALHES DAS DESPESAS ---');
    if (expensesList.isEmpty) {
      buffer.writeln('Nenhuma despesa no período.');
    } else {
      for (var t in expensesList) {
        buffer.writeln('- ${t.title}: ${Formatter.formatCurrency(t.amount)} (${Formatter.formatDate(t.date)})');
      }
    }
    buffer.writeln('===========================================');

    final textoRelatorio = buffer.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF192026), // Fundo escuro premium condizente com o topo
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text('Extrato do Período', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF11161B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                textoRelatorio,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('FECHAR', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('COPIAR TEXTO'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: textoRelatorio));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Extrato copiado para a Área de Transferência!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1E252B),
      appBar: AppBar(
        title: const Text(
          'Controle Financeiro',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.1),
        ),
        backgroundColor: corTopoEscuro,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          Watch((context) {
            final isVisible = viewModelController.isFilterVisible.value;
            return IconButton(
              icon: Icon(isVisible ? Icons.filter_list_off_rounded : Icons.filter_list_rounded),
              tooltip: isVisible ? 'Ocultar filtros' : 'Mostrar filtros',
              onPressed: viewModelController.toggleFilterVisibility,
            );
          }),
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => _exportarRelatorioFinanceiro(context),
            tooltip: 'Exportar relatório de transações',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              color: corTopoEscuro,
              padding: const EdgeInsets.only(bottom: 16),
              child: Watch((context) {
                final income = viewModelController.totalIncome.value;
                final expense = viewModelController.totalExpense.value;
                return SummaryCarousel(
                  totalIncome: income,
                  totalExpense: expense,
                );
              }),
            ),

            // Filtro animado
            Watch((context) {
              final isVisible = viewModelController.isFilterVisible.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: const Color(0xFF1E252B),
                height: isVisible ? null : 0,
                child: isVisible
                    ? DateFilterTransactions(
                        filtro: (
                          type: viewModelController.filterType,
                          startDate: viewModelController.startDate,
                          endDate: viewModelController.endDate,
                        ),
                        onFilterChanged: (startDate, endDate) {
                          viewModelController.searchTransactionsByDate
                              .execute(startDate!, endDate!);
                        },
                        onUpdateFilter: (type, startDate, endDate) {
                          viewModelController.setFiltersParams(
                            type,
                            startDate,
                            endDate,
                          );
                        },
                        onAllTransactionsFiltered: () {
                          viewModelController.load.execute();
                        },
                        onTapHideFilter: _toggleFilterVisibility,
                      )
                    : const SizedBox.shrink(),
              );
            }),

            // Área de botões de Ação rápidos
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
              child: Row(
                children: [
                  // Add Income button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      TransactionType.income,
                      Icons.add_circle_outline_rounded,
                      const Color(0xFF00BFA6), // Verde claro neon combinando com o topo
                      () => _showIncomeSheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Expense button
                  Expanded(
                    child: _buildActionButton(
                      context,
                      TransactionType.expense,
                      Icons.remove_circle_outline_rounded,
                      const Color(0xFFFF914D), // Laranja claro neon combinando com o topo
                      () => _showExpenseSheet(context),
                    ),
                  ),
                ],
              ),
            ),

            // Card das Transações (Receitas e Despesas)
            Watch((context) {
              final incomes = viewModelController.incomes.value;
              final expenses = viewModelController.expenses.value;
              return TransactionCardSheets(
                incomeTransactions: incomes,
                expenseTransactions: expenses,
                onDelete: (id) {
                  viewModelController.deleteTransaction.execute(id);
                },
                onEdit: (transaction) {
                  if (transaction.type == TransactionType.income) {
                    _showIncomeSheet(context, transaction: transaction);
                  } else {
                    _showExpenseSheet(context, transaction: transaction);
                  }
                },
                undoDelete: viewModelController.undoDelectedTransaction,
                scaffoldContext: context,
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Constrói botões para receitas e despesas personalizados
  Widget _buildActionButton(
    BuildContext context,
    TransactionType transactionType,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(
        transactionType.namePlural,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0, // Visual mais flat e moderno
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Show income transaction sheet
  void _showIncomeSheet(BuildContext context, {TransactionEntity? transaction}) {
    TransactionSheet.show(
      context: context,
      type: TransactionType.income,
      submitCommand: transaction != null
          ? viewModelController.editTransaction
          : viewModelController.saveTransaction,
      transaction: transaction,
    );
  }

  /// Show expense transaction sheet
  void _showExpenseSheet(BuildContext context, {TransactionEntity? transaction}) {
    TransactionSheet.show(
      context: context,
      type: TransactionType.expense,
      submitCommand: transaction != null
          ? viewModelController.editTransaction
          : viewModelController.saveTransaction,
      transaction: transaction,
    );
  }
}