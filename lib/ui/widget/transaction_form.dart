import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Um widget reutilizável de formulário para adicionar transações de receita ou despesa
class TransactionForm extends StatefulWidget {
  /// Comando que deve ser observado o estado de execução
  /// e o resultado da execução
  final Command1<void, Failure, TransactionEntity> submitCommand;

  /// Função de callback quando o formulário é enviado
  //final Function(TransactionEntity newTransaction) onSubmit;

  /// Tipo de transação (receita ou despesa)
  final TransactionType type;

  final TransactionEntity? transaction;

  /// Cor do tema para o formulário
  final Color color;

  const TransactionForm({
    super.key,
    //required this.onSubmit,
    required this.type,
    required this.color,
    required this.submitCommand,
    this.transaction
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Exibe o seletor de datas e atualiza a data selecionada
  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  /// Envia o formulário se a validação for bem-sucedida
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final enteredTitle = _titleController.text;
      final enteredAmount = double.parse(_amountController.text);

      final newTransaction = TransactionEntity(
        id:  widget.transaction?.id ?? '',
        title: enteredTitle,
        amount: enteredAmount,
        date: _selectedDate,
        type: widget.type,
      );

      //widget.onSubmit(newTransaction);
      await widget.submitCommand.execute(newTransaction);

      if (widget.submitCommand.resultSignal.value?.isFailure ?? false) {
        // Se o comando falhar, exibe uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao salvar ${widget.type.nameSingular}: ${widget.submitCommand.resultSignal.value?.failureValueOrNull ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
        return;
      }

      // Limpa os campos do formulário
      _titleController.clear();
      _amountController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });

      // Mostra uma mensagem de sucesso
      final msg = widget.transaction != null ? 'Atualizada' : 'Adicionada';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.type.nameSingular} $msg com Sucesso!'),
          backgroundColor: widget.color,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de entrada para a descrição (título)
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.color),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.description, color: widget.color),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe uma descrição';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo de entrada para o valor
            TextFormField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Valor',
                labelStyle: const TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.color),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.attach_money, color: widget.color),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe um valor';
                }
                if (double.tryParse(value) == null) {
                  return 'Digite um número válido';
                }
                if (double.parse(value) <= 0) {
                  return 'O valor deve ser maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Seção para exibir e escolher a data
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _presentDatePicker,
                    icon: Icon(Icons.calendar_today, size: 16, color: widget.color),
                    label: Text(
                      'Selecionar Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botão de envio do formulário
            Watch((context) {
              final isRunning = widget.submitCommand.runningSignal.value;

              return SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      isRunning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              //muda o texto se for edicao
                              widget.transaction != null
                                  ? 'Salvar Alterações'
                                  : 'Adicionar ${widget.type.nameSingular}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}