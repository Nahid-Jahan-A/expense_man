import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../../../../core/localization/app_localizations.dart';

/// Page for managing expense categories
class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is CategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        // Only rebuild for CategoryLoaded and CategoryLoading states
        return current is CategoryLoaded || current is CategoryLoading;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('manage_categories')),
          ),
          body: state is CategoryLoaded
              ? _buildCategoryList(context, state)
              : const Center(child: CircularProgressIndicator()),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditDialog(context, null),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(BuildContext context, CategoryLoaded state) {
    final defaultCategories = state.defaultCategories;
    final customCategories = state.customCategories;

    if (state.categories.isEmpty) {
      return Center(
        child: Text(context.tr('no_categories')),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Default categories section
        if (defaultCategories.isNotEmpty) ...[
          _buildSectionHeader(context, context.tr('default_categories')),
          const SizedBox(height: 8),
          ...defaultCategories.asMap().entries.map((entry) {
            return _buildCategoryTile(context, entry.value, entry.key, isDefault: true);
          }),
          const SizedBox(height: 24),
        ],

        // Custom categories section
        _buildSectionHeader(context, context.tr('custom_categories')),
        const SizedBox(height: 8),
        if (customCategories.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('no_custom_categories'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...customCategories.asMap().entries.map((entry) {
            return _buildCategoryTile(context, entry.value, entry.key);
          }),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category, int index, {bool isDefault = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = Color(category.color);
    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconData(category.icon),
            color: categoryColor,
          ),
        ),
        title: Text(category.getName(locale)),
        subtitle: isDefault
            ? Text(
                locale == 'bn' ? 'ডিফল্ট বিভাগ' : 'Default category',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: isDefault
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showAddEditDialog(context, category),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: () => _showDeleteDialog(context, category, locale),
                  ),
                ],
              ),
        onTap: isDefault ? null : () => _showAddEditDialog(context, category),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0);
  }

  void _showAddEditDialog(BuildContext context, Category? category) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddEditCategoryDialog(
        category: category,
        onSave: (newCategory) {
          if (category == null) {
            context.read<CategoryBloc>().add(AddCategoryEvent(newCategory));
          } else {
            context.read<CategoryBloc>().add(UpdateCategoryEvent(newCategory));
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category, String locale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(locale == 'bn' ? 'বিভাগ মুছুন?' : 'Delete Category?'),
        content: Text(
          locale == 'bn'
              ? 'আপনি কি নিশ্চিত যে "${category.getName(locale)}" বিভাগটি মুছতে চান?'
              : 'Are you sure you want to delete "${category.getName(locale)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(locale == 'bn' ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategoryEvent(category.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(locale == 'bn' ? 'মুছুন' : 'Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
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
      case 'fitness_center':
        return Icons.fitness_center;
      case 'school':
        return Icons.school;
      case 'pets':
        return Icons.pets;
      case 'flight':
        return Icons.flight;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'phone_android':
        return Icons.phone_android;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'child_care':
        return Icons.child_care;
      case 'build':
        return Icons.build;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}

/// Dialog for adding or editing a category
class _AddEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const _AddEditCategoryDialog({
    this.category,
    required this.onSave,
  });

  @override
  State<_AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<_AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _nameBnController = TextEditingController();

  String _selectedIcon = 'category';
  Color _selectedColor = Colors.blue;

  final List<_IconOption> _availableIcons = [
    _IconOption('category', Icons.category),
    _IconOption('shopping_cart', Icons.shopping_cart),
    _IconOption('restaurant', Icons.restaurant),
    _IconOption('directions_car', Icons.directions_car),
    _IconOption('home', Icons.home),
    _IconOption('medical_services', Icons.medical_services),
    _IconOption('movie', Icons.movie),
    _IconOption('checkroom', Icons.checkroom),
    _IconOption('receipt_long', Icons.receipt_long),
    _IconOption('fitness_center', Icons.fitness_center),
    _IconOption('school', Icons.school),
    _IconOption('pets', Icons.pets),
    _IconOption('flight', Icons.flight),
    _IconOption('local_cafe', Icons.local_cafe),
    _IconOption('phone_android', Icons.phone_android),
    _IconOption('sports_esports', Icons.sports_esports),
    _IconOption('child_care', Icons.child_care),
    _IconOption('build', Icons.build),
    _IconOption('card_giftcard', Icons.card_giftcard),
    _IconOption('work', Icons.work),
    _IconOption('more_horiz', Icons.more_horiz),
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameEnController.text = widget.category!.nameEn;
      _nameBnController.text = widget.category!.nameBn;
      _selectedIcon = widget.category!.icon;
      _selectedColor = Color(widget.category!.color);
    }
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameBnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEditing = widget.category != null;

    return AlertDialog(
      title: Text(isEditing
          ? (locale == 'bn' ? 'বিভাগ সম্পাদনা' : 'Edit Category')
          : (locale == 'bn' ? 'নতুন বিভাগ' : 'New Category')),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English name
                TextFormField(
                  controller: _nameEnController,
                  decoration: InputDecoration(
                    labelText: locale == 'bn' ? 'নাম (ইংরেজি)' : 'Name (English)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return locale == 'bn' ? 'নাম লিখুন' : 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bengali name
                TextFormField(
                  controller: _nameBnController,
                  decoration: InputDecoration(
                    labelText: locale == 'bn' ? 'নাম (বাংলা)' : 'Name (Bengali)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return locale == 'bn' ? 'নাম লিখুন' : 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Icon selection
                Text(
                  locale == 'bn' ? 'আইকন নির্বাচন করুন' : 'Select Icon',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final iconOption = _availableIcons[index];
                      final isSelected = _selectedIcon == iconOption.name;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = iconOption.name;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withAlpha(51)
                                : null,
                            border: isSelected
                                ? Border.all(color: _selectedColor, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            iconOption.icon,
                            color: isSelected ? _selectedColor : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Color selection
                Text(
                  locale == 'bn' ? 'রঙ নির্বাচন করুন' : 'Select Color',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColor == color;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(locale == 'bn' ? 'বাতিল' : 'Cancel'),
        ),
        FilledButton(
          onPressed: _saveCategory,
          child: Text(locale == 'bn' ? 'সংরক্ষণ' : 'Save'),
        ),
      ],
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = Category(
        id: widget.category?.id ?? const Uuid().v4(),
        nameEn: _nameEnController.text.trim(),
        nameBn: _nameBnController.text.trim(),
        color: _selectedColor.toARGB32(),
        icon: _selectedIcon,
        isDefault: false,
        order: widget.category?.order ?? 999,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: widget.category != null ? DateTime.now() : null,
      );

      widget.onSave(category);
      Navigator.pop(context);
    }
  }
}

class _IconOption {
  final String name;
  final IconData icon;

  _IconOption(this.name, this.icon);
}
