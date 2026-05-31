import 'package:financial_tracker/common/utils/formatter.dart';
import 'package:flutter/material.dart';

/// Widget to display financial summary information
class SummaryCard extends StatelessWidget {
  /// Total income amount
  final double totalIncome;

  /// Total expense amount
  final double totalExpense;

  /// Current balance amount
  final double balance;

  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🎨 PALETA DE CORES PERSONALIZADA (DARK PREMIUM & NEON CONTRAST)
    const Color corFundoInicio = Color(0xFF1E252B); // Grafite moderno
    const Color corFundoFim = Color(0xFF11161B);    // Quase preto mineral
    const Color verdeClaroNeon = Color(0xFF00BFA6); // Verde moderno para Receita
    const Color laranjaClaroNeon = Color(0xFFFF914D); // Laranja moderno para Despesa

    return Card(
      elevation: 0, // ESTILO: Removida a sombra pesada para um design mais minimalista
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // ESTILO: Bordas mais curvas e premium
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20), // ESTILO: Um pouco mais de respiro interno
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [corFundoInicio, corFundoFim],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // ESTILO: Uma linha sutil de contorno para dar acabamento de "cartão de crédito premium"
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Text(
              'Resumo Financeiro',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70, // ESTILO: Texto secundário em branco fosco
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Three key financial indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Income
                _buildSummaryItem(
                  context,
                  'Receita',
                  Formatter.formatCurrency(totalIncome),
                  Icons.arrow_upward_rounded,
                  verdeClaroNeon,
                ),
                // Expense
                _buildSummaryItem(
                  context,
                  'Despesa',
                  Formatter.formatCurrency(totalExpense),
                  Icons.arrow_downward_rounded,
                  laranjaClaroNeon,
                ),
                // Balance
                _buildSummaryItem(
                  context,
                  'Balanço',
                  Formatter.formatCurrency(balance),
                  Icons.account_balance_wallet_rounded,
                  balance >= 0 ? Colors.white : Colors.white60, // ESTILO: Branco limpo se positivo
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build individual summary items
  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Icon with background
        Container(
          padding: const EdgeInsets.all(12), // ESTILO: Círculo ligeiramente maior para o ícone
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), // ESTILO: Fundo colorido translúcido moderno (estilo Glassmorphism)
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        // Title
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[400], // ESTILO: Cor estável para leitura das labels no fundo escuro
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Amount
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color == Colors.white || color == Colors.white60 ? Colors.white : color, // ESTILO: Destaca o valor com a cor do indicador
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}