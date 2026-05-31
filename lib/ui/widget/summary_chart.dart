import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../common/utils/formatter.dart';

/// Widget to display financial data in chart form
class SummaryChart extends StatelessWidget {
  /// Total income amount
  final double totalIncome;

  /// Total expense amount
  final double totalExpense;

  /// Map containing transactions separated by type
  //final Map<String, List<TransactionEntity>> transactions;

  const SummaryChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    //required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    const Color corFundoInicio = Color(0xFF1E252B); // Grafite moderno
    const Color corFundoFim = Color(0xFF11161B);    // Preto mineral
    const Color verdeClaroNeon = Color(0xFF00BFA6); // Verde moderno para Receita
    const Color laranjaClaroNeon = Color(0xFFFF914D); // Laranja moderno para Despesa

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.all(16), // Mesma margem externa do SummaryCard
      child: Container(
        padding: const EdgeInsets.all(20), // Mesmo espaçamento interno do SummaryCard
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [corFundoInicio, corFundoFim],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Column(
          children: [
            // Chart title
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.pie_chart_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Receitas vs. Despesas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                  ),
                ],
              ),
            ),

            // Choose between pie chart and bar chart based on data availability
            if (totalIncome == 0 && totalExpense == 0)
              _buildEmptyState(context)
            else
              Container(
                height: 124,
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    // Pie chart section
                    Expanded(
                      flex: 3,
                      child: _buildPieChart(context, verdeClaroNeon, laranjaClaroNeon),
                    ),
                    const SizedBox(width: 16),
                    // Legend section
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(
                            context,
                            'Receitas',
                            verdeClaroNeon,
                            totalIncome,
                          ),
                          const SizedBox(height: 12),
                          _buildLegendItem(
                            context,
                            'Despesas',
                            laranjaClaroNeon,
                            totalExpense,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build pie chart visualization
  Widget _buildPieChart(BuildContext context, Color incomeColor, Color expenseColor) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 12, // Ajustado proporcionalmente
        sections: [
          // Income section
          PieChartSectionData(
            value: totalIncome,
            title: '',
            radius: 40, // Mantém o aspecto encorpado se ajustando à nova altura
            color: incomeColor,
            showTitle: false,
          ),
          // Expense section
          PieChartSectionData(
            value: totalExpense,
            title: '',
            radius: 40,
            color: expenseColor,
            showTitle: false,
          ),
        ],
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: false),
      ),
    );
  }

  /// Build legend item for the chart
  Widget _buildLegendItem(
    BuildContext context,
    String title,
    Color color,
    double amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 18),
            Text(
              Formatter.formatCurrency(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build empty state when no data is available
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 124,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_chart_outlined_rounded, size: 36, color: Colors.white30),
          const SizedBox(height: 8),
          const Text(
            'Sem transações cadastradas',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Adicione transações para visualizar o gráfico',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}