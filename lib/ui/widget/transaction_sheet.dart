import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';

import 'transaction_form.dart';

/// Bottom sheet para adicionar transações de receita ou despesa
class TransactionSheet extends StatelessWidget {
  /// Tipo da transação (receita ou despesa)
  final TransactionType type;

  /// Comando que deve ser observado o estado de execução
  /// e o resultado da execução
  final Command1<void, Failure, TransactionEntity> submitCommand;

  final TransactionEntity? transaction;

  /// Função callback quando a transação é submetida
  // final Function(TransactionEntity newTransaction) onSubmit;

  const TransactionSheet({
    super.key,
    required this.type,
    // required this.onSubmit,
    required this.submitCommand,
    this.transaction,
  });

  /// Método auxiliar para exibir o bottom sheet como um modal
  static Future<void> show({
    required BuildContext context,
    required TransactionType type,
    // required Function(TransactionEntity newTransaction) onSubmit,
    required Command1<void, Failure, TransactionEntity> submitCommand,
    TransactionEntity? transaction,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite expandir até o topo
      backgroundColor: Colors.transparent,
      builder:
          (context) => TransactionSheet(
            type: type,
            // onSubmit: onSubmit,
            submitCommand: submitCommand,
            transaction: transaction,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = type == TransactionType.income;
    final color = isIncome ? const Color(0xFF00BFA6) : const Color(0xFFFF914D);
    final formTitle = type.nameSingular; // Retorna 'Receita' ou 'Despesa'

    // Altura disponível para o bottom sheet (75% da altura da tela)
    final availableHeight = MediaQuery.of(context).size.height * 0.75;

    const Color corFundoInicio = Color(0xFF1E252B); // Grafite moderno
    const Color corFundoFim = Color(0xFF11161B);    // Quase preto mineral

    return Container(
      height: availableHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        gradient: const LinearGradient(
          colors: [corFundoInicio, corFundoFim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho e "alça" do sheet
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Alça para indicar que o sheet pode ser arrastado
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Título do cabeçalho
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncome ? Icons.trending_up : Icons.trending_down,
                          color: color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${transaction != null ? 'Editar' : 'Adicionar'} $formTitle',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Formulário para inserir a transação
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  // Aplica um padding inferior para evitar que o teclado cubra os campos
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: TransactionForm(
                  type: type,
                  color: color,
                  submitCommand: submitCommand,
                  transaction: transaction,
                  // onSubmit: (newTransaction) {
                  //   onSubmit(newTransaction);
                  //   Navigator.pop(context); // Fecha o bottom sheet
                  // },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}