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

    // 🎨 CONFIGURAÇÃO DE CORES DO SEU RESUMO FINANCEIRO
    const Color corComecoGradiente = Color(0xFF252E35); // Tom mais claro em cima (iluminação/relevo)
    const Color corFimGradiente = Color(0xFF1E252B);    // Tom grafite escuro embaixo

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0, // Tiramos a sombra nativa cinza do Material para usar a sombra realista abaixo
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // ✨ AQUI ESTÁ O SEGREDO: O exato gradiente do resumo financeiro
          gradient: const LinearGradient(
            colors: [
              corComecoGradiente,
              corFimGradiente,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          // ✨ EFEITO SALTADO: Sombra projetada que faz o card parecer flutuar na tela
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.03),
              blurRadius: 1,
              offset: const Offset(0, -1), // Linha de luz sutil no topo
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do filtro adaptado para branco para contrastar com o novo fundo
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: Colors.white70, // Branco fosco elegante
                  ),
                  onPressed: () {
                    widget.onTapHideFilter?.call();
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Filtro de Data de Transações',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto agora é branco puro
                    fontSize: 16,
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
                    color: const Color(0xFF181E22), // Recesso interno sutil
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 18,
                        color: Color(0xFF00BFA6), // Verde Neon para destacar
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white54,
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
        checkmarkColor: theme.colorScheme.onSecondary,
        label: Text(label),
        selected: isSelected,
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.9),
        labelStyle: TextStyle(
          color:
              isSelected
                  ? theme.colorScheme.onSecondary
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
