import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/localization/app_localizations.dart';

/// Page for adding or editing an expense
class AddEditExpensePage extends StatefulWidget {
  final Expense? expense;

  const AddEditExpensePage({super.key, this.expense});

  @override
  State<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends State<AddEditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String? _selectedCategoryId;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountController.text = widget.expense!.amount.toString();
      _noteController.text = widget.expense!.note ?? '';
      _selectedDate = widget.expense!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.expense!.dateTime);
      _selectedCategoryId = widget.expense!.categoryId;
      _selectedPaymentMethod =
          PaymentMethod.fromValue(widget.expense!.paymentMethod);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is! SettingsLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final locale = settingsState.settings.languageCode;
        final currency = settingsState.currency;

        return BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing
                        ? context.tr('expense_updated')
                        : context.tr('expense_added'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is ExpenseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                isEditing ? context.tr('edit_expense') : context.tr('add_expense'),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Amount field
                  _buildAmountField(context, currency, locale),
                  const SizedBox(height: 20),

                  // Category selector
                  _buildCategorySelector(context, locale),
                  const SizedBox(height: 20),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker(context, locale)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTimePicker(context, locale)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Payment method
                  _buildPaymentMethodSelector(context, locale),
                  const SizedBox(height: 20),

                  // Note field
                  _buildNoteField(context, locale),
                  const SizedBox(height: 32),

                  // Save button
                  _buildSaveButton(context, locale),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountField(BuildContext context, currency, String locale) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      decoration: InputDecoration(
        labelText: context.tr('amount'),
        hintText: context.tr('enter_amount'),
        prefixText: '${currency.symbol} ',
        prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.tr('invalid_amount');
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return context.tr('invalid_amount');
        }
        return null;
      },
      autofocus: !isEditing,
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildCategorySelector(BuildContext context, String locale) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) {
          return const LinearProgressIndicator();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('category'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.categories.map((category) {
                final isSelected = _selectedCategoryId == category.id;
                return _buildCategoryChip(context, category, isSelected, locale);
              }).toList(),
            ),
            if (_selectedCategoryId == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.tr('select_category_error'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    Category category,
    bool isSelected,
    String locale,
  ) {
    final color = Color(category.color);

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategoryId = selected ? category.id : null;
        });
      },
      avatar: Icon(
        _getCategoryIcon(category.icon),
        size: 18,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(category.getName(locale)),
      selectedColor: color,
      backgroundColor: color.withAlpha(26),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String locale) {
    final dateFormat = DateFormat('dd MMM yyyy', locale);

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.tr('date'),
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(dateFormat.format(_selectedDate)),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTimePicker(BuildContext context, String locale) {
    return InkWell(
      onTap: () => _selectTime(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.tr('time'),
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(_selectedTime.format(context)),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPaymentMethodSelector(BuildContext context, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('payment_method'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PaymentMethod>(
          segments: PaymentMethod.values
              .map(
                (method) => ButtonSegment(
                  value: method,
                  label: Text(method.getLabel(locale)),
                  icon: Icon(_getPaymentIcon(method)),
                ),
              )
              .toList(),
          selected: {_selectedPaymentMethod},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedPaymentMethod = selection.first;
            });
          },
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildNoteField(BuildContext context, String locale) {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: context.tr('note_optional'),
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.note),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSaveButton(BuildContext context, String locale) {
    return FilledButton.icon(
      onPressed: _saveExpense,
      icon: const Icon(Icons.check),
      label: Text(context.tr('save')),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('select_category_error')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      dateTime: dateTime,
      paymentMethod: _selectedPaymentMethod.value,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
      updatedAt: isEditing ? DateTime.now() : null,
    );

    if (isEditing) {
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(expense));
    } else {
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    }
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'medical_services':
        return Icons.medical_services;
      case 'checkroom':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'movie':
        return Icons.movie;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.mobileBanking:
        return Icons.phone_android;
      case PaymentMethod.card:
        return Icons.credit_card;
    }
  }
}
