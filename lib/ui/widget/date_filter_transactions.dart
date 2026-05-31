import 'package:financial_tracker/common/types/date_filter_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//enum DateFilterType { all, today, week, month, custom }

/// Widget for filtering transactions by date
class DateFilterTransactions extends StatefulWidget {
  /// Callback for when date filter changes
  final Function(DateTime? startDate, DateTime? endDate) onFilterChanged;

  /// Função de callback quando o formulário é enviado
  final Function() onAllTransactionsFiltered;

  // call para atualizar o filtro de data
  final Function(DateFilterType type, DateTime? startDate, DateTime? endDate)
  onUpdateFilter;

  /// Callback for when the filter is hidden
  final VoidCallback? onTapHideFilter;

final ({DateFilterType type, DateTime? startDate, DateTime? endDate}) filtro;

  const DateFilterTransactions({
    super.key,
    required this.onFilterChanged,
    required this.filtro,
    this.onTapHideFilter,
    required this.onAllTransactionsFiltered,
    required this.onUpdateFilter,
  });

  @override
  State<DateFilterTransactions> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterTransactions> {
  late DateFilterType _filterType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _filterType = widget.filtro.type;
    _startDate = widget.filtro.startDate;
    _endDate = widget.filtro.endDate;

    // Initialize dates based on current filter
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final range = _filterType.resolveRange(now, _startDate, _endDate);

    setState(() {
      _startDate = range?.start;
      _endDate = range?.end;
    });
  }

  void _applyFilter(DateFilterType type) {
    setState(() {
      _filterType = type;
      _initializeDates();
    });

    if (type == DateFilterType.all) {
      widget.onAllTransactionsFiltered();
    } else {
      widget.onFilterChanged(_startDate, _endDate);
    }
    widget.onUpdateFilter(_filterType, _startDate, _endDate);
  }

  Future<void> _selectCustomDateRange() async {
    // final now = DateTime.now();
    // final initialDateRange = DateTimeRange(
    //   start: _startDate ?? DateTime(now.year, now.month, 1),
    //   end: _endDate ?? now,
    // );
    // print(_startDate);
    // print(_endDate);
    // print(initialDateRange);
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 1));

    final safeRange = _filterType
        .resolveRange(now, _startDate, _endDate)
        ?.cappedAt(
          maxDate,
        ); // com operador "?", cappedAt só é executado se o valor não for nulo retornado por resolveRange

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: safeRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _filterType = DateFilterType.custom;
        _startDate = pickedDateRange.start;
        // Set end date to end of day
        _endDate = DateTime(
          pickedDateRange.end.year,
          pickedDateRange.end.month,
          pickedDateRange.end.day,
          23,
          59,
          59,
        );
      });

      widget.onFilterChanged(_startDate, _endDate);
      widget.onUpdateFilter(_filterType, _startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🎨 PALETA DE CORES PERSONALIZADA (DARK PREMIUM & NEON CONTRAST)
    const Color corFundoInicio = Color(0xFF1E252B); // Grafite moderno
    const Color corFundoFim = Color(0xFF11161B);    // Quase preto mineral

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
            // Filter title
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: Colors.white70, // ESTILO: Texto secundário em branco fosco
                  ),
                  onPressed: () {
                    // Aqui você aciona a função que alterna visibilidade
                    // Essa função vem da tela principal, então passe como parâmetro
                    widget.onTapHideFilter
                        ?.call(); // ou diretamente: _toggleFilterVisibility()
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Filtro de Data de Transações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70, // ESTILO: Texto secundário em branco fosco
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Wrap envolve os widgets filhos em uma linha com quebra automática
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(DateFilterType.all, 'Tudo'),
                _buildFilterChip(DateFilterType.today, 'Hoje'),
                _buildFilterChip(DateFilterType.week, 'Esta Semana'),
                _buildFilterChip(DateFilterType.month, 'Este Mês'),
                _buildFilterChip(DateFilterType.custom, 'Personalizado'),
              ],
            ),

            // Show date range if custom filter selected
            if (_filterType == DateFilterType.custom) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectCustomDateRange,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E252B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 18,
                        color: Color(0xFF00BFA6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                        style: const TextStyle(
                          color: Color(0xFF00BFA6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF00BFA6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a filter chip for date selection
  Widget _buildFilterChip(DateFilterType type, String label) {
    final theme = Theme.of(context);
    final isSelected = _filterType == type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      child: ChoiceChip(
        elevation: 0,
        pressElevation: 0,
        showCheckmark: false,
        backgroundColor: Colors.white.withOpacity(0.04),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00BFA6).withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        checkmarkColor: theme.colorScheme.onSecondary,
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF1E252B),
        labelStyle: TextStyle(
          color:
              isSelected
                  ? const Color(0xFF00BFA6)
                  : theme.textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            if (type == DateFilterType.custom) {
              _selectCustomDateRange();
            } else {
              _applyFilter(type);
            }
          }
        },
      ),
    );
  }
}