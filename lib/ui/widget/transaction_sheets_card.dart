import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import '../../common/utils/formatter.dart';
import '../../domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';

/// Widget que exibe a lista de transações com o mesmo efeito Gradiente e Efeito Saltado do Resumo Financeiro
class TransactionCardSheets extends StatefulWidget {
  final List<TransactionEntity> incomeTransactions;
  final List<TransactionEntity> expenseTransactions;
  final Function(String id) onDelete;
  final Function(TransactionEntity transaction) onEdit;
  final Command1<void, Failure, TransactionEntity> undoDelete;
  final BuildContext scaffoldContext;

  const TransactionCardSheets({
    super.key,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.onDelete,
    required this.onEdit,
    required this.undoDelete,
    required this.scaffoldContext,
  });

  @override
  State<TransactionCardSheets> createState() => _TransactionCardSheetsState();
}

class _TransactionCardSheetsState extends State<TransactionCardSheets>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; 
  bool _isGridView = false;

  static const Color corComecoGradiente = Color(0xFF252E35); // Tom mais claro em cima (gera relevo)
  static const Color corFimGradiente = Color(0xFF1E252B);    // Tom original do resumo embaixo
  static const Color corItemDark = Color(0xFF181E22);        // Linhas internas sutilmente mais profundas
  static const Color verdeClaroNeon = Color(0xFF00BFA6);
  static const Color laranjaClaroNeon = Color(0xFFFF914D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); 
    _tabController.addListener(() {
      if (mounted) setState(() {}); 
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncomeTab = _tabController.index == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [corComecoGradiente, corFimGradiente],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8), // Projeta a sombra para baixo, dando altura
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.04),
            blurRadius: 1,
            offset: const Offset(0, -1), // Uma mini linha de luz na borda superior
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho refinado
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, top: 16, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suas Transações',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                  tooltip: _isGridView ? 'Mudar para Lista' : 'Mudar para Blocos',
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
              ],
            ),
          ),

          // TabBar limpa e integrada
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 1)),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    _buildTab(
                      TransactionType.income.namePlural,
                      Icons.arrow_upward_rounded,
                      0,
                      verdeClaroNeon,
                    ),
                    _buildTab(
                      TransactionType.expense.namePlural,
                      Icons.arrow_downward_rounded,
                      1,
                      laranjaClaroNeon,
                    ),
                  ],
                  indicatorColor: isIncomeTab ? verdeClaroNeon : laranjaClaroNeon,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3,
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: SizedBox(
                  height: 310,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionContent(
                        context,
                        widget.incomeTransactions,
                        verdeClaroNeon,
                        TransactionType.income.namePlural,
                      ),
                      _buildTransactionContent(
                        context,
                        widget.expenseTransactions,
                        laranjaClaroNeon,
                        TransactionType.expense.namePlural,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, int index, Color activeColor) {
    final isSelected = _tabController.index == index;
    final color = isSelected ? activeColor : Colors.white38;

    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContent(
    BuildContext context,
    List<TransactionEntity> transactions,
    Color color,
    String title,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 44,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma movimentação encontrada',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_isGridView) {
      return _buildTransactionGrid(context, transactions, color);
    } else {
      return _buildTransactionList(context, transactions, color);
    }
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionEntity> transactions,
    Color color,
  ) {
    return Scrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final undoTransaction = transaction.copyWith();

          return Dismissible(
            key: Key(transaction.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24.0),
              decoration: BoxDecoration(
                color: Colors.redAccent.shade100.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
            onDismissed: (direction) async {
              await widget.onDelete(transaction.id);
              ScaffoldMessenger.of(widget.scaffoldContext).clearSnackBars();
              ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text('${transaction.title} excluída'),
                  backgroundColor: const Color(0xFF11161B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  action: SnackBarAction(
                    label: 'DESFAZER',
                    textColor: color,
                    onPressed: () async {
                      await widget.undoDelete.execute(undoTransaction);
                      if (widget.undoDelete.resultSignal.value?.isSuccess ?? false) {
                        ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text('${transaction.title} restaurada!'),
                            backgroundColor: verdeClaroNeon,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                color: corItemDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.02), width: 1),
              ),
              child: ListTile(
                onTap: () => widget.onEdit(transaction),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _tabController.index == 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                title: Text(
                  transaction.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white),
                ),
                subtitle: Text(
                  Formatter.formatDate(transaction.date),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                trailing: Text(
                  Formatter.formatCurrency(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionGrid(
    BuildContext context,
    List<TransactionEntity> transactions,
    Color color,
  ) {
    return Scrollbar(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          return GestureDetector(
            onTap: () => widget.onEdit(transaction),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: corItemDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.2), width: 1.2),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle
                            ),
                            child: Icon(
                              _tabController.index == 0
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: color,
                              size: 14,
                            ),
                          ),
                          Text(
                            Formatter.formatDate(transaction.date),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Formatter.formatCurrency(transaction.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}