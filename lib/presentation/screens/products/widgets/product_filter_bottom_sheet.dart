import 'package:flutter/material.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/tag_model.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final List<TagModel> tags;
  final int? initialCategoryId;
  final int? initialTagId;
  final num? initialMinPrice;
  final num? initialMaxPrice;
  final void Function({
    int? categoryId,
    int? tagId,
    num? minPrice,
    num? maxPrice,
  }) onApply;
  final VoidCallback onReset;

  const ProductFilterBottomSheet({
    super.key,
    required this.categories,
    required this.tags,
    this.initialCategoryId,
    this.initialTagId,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  int? _selectedCategory;
  int? _selectedTag;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryId;
    _selectedTag = widget.initialTagId;
    if (widget.initialMinPrice != null) {
      _minPriceController.text = widget.initialMinPrice!.toInt().toString();
    }
    if (widget.initialMaxPrice != null) {
      _maxPriceController.text = widget.initialMaxPrice!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Шүүлтүүр',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  const SizedBox(height: 12),
                  const Text(
                    'Ангилал',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Бүгд'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = null);
                        },
                      ),
                      ...widget.categories.map((c) {
                        final isSelected = _selectedCategory == c.id;
                        return ChoiceChip(
                          label: Text(c.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? c.id : null;
                            });
                          },
                        );
                      }),
                    ],
                  ),

                  // Tags
                  const SizedBox(height: 20),
                  const Text(
                    'Таг',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Бүгд'),
                        selected: _selectedTag == null,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedTag = null);
                        },
                      ),
                      ...widget.tags.map((t) {
                        final isSelected = _selectedTag == t.id;
                        return ChoiceChip(
                          label: Text(t.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTag = selected ? t.id : null;
                            });
                          },
                        );
                      }),
                    ],
                  ),

                  // Price Range
                  const SizedBox(height: 20),
                  const Text(
                    'Үнийн хязгаар (₮)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Доод үнэ',
                            prefixText: '₮ ',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('-'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Дээд үнэ',
                            prefixText: '₮ ',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Цэвэрлэх'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final minP = num.tryParse(_minPriceController.text.trim());
                    final maxP = num.tryParse(_maxPriceController.text.trim());
                    widget.onApply(
                      categoryId: _selectedCategory,
                      tagId: _selectedTag,
                      minPrice: minP,
                      maxPrice: maxP,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Шүүх'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
