import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farmer_provider.dart';
import '../models/farmer_product_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FarmerProvider>();
      provider.fetchProducts();
      provider.fetchCatalog();
      provider.fetchFarms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Inventory',
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<FarmerProvider>(
        builder: (context, provider, child) {
          if (provider.loadingProducts && provider.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            );
          }

          final totalProducts = provider.products.length;
          final totalQty = provider.products.fold<double>(
            0.0, (sum, p) => sum + p.quantityAvailable
          );

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchProducts();
              await provider.fetchCatalog();
              await provider.fetchFarms();
            },
            color: AppTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Summary Card ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF1E3A8A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Inventory Overview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryStat(
                                'Listed Products',
                                '$totalProducts Items',
                                Icons.inventory_2_rounded,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            Expanded(
                              child: _buildSummaryStat(
                                'Total Volume',
                                '${totalQty.toStringAsFixed(1)} kg',
                                Icons.scale_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Keep your inventory up to date so buyers can browse and place direct orders. Prices are bounded by catalog regulations.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Empty State ───────────────────────────────────────
                if (provider.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              size: 60,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Products Listed',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You haven\'t added any produce to your inventory yet. Click the button below to register a crop and list it in the public market.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMutedLight,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditProductSheet(context, null),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Your First Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // ── Products List ─────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = provider.products[index];
                          return _buildProductCard(context, product);
                        },
                        childCount: provider.products.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditProductSheet(context, null),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, FarmerProductModel product) {
    // Resolve Image URL
    String? fullImageUrl;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      fullImageUrl = product.imageUrl!.startsWith('http') ? product.imageUrl! : '$kBaseUrl${product.imageUrl}';
    } else if (product.catalogImageUrl != null && product.catalogImageUrl!.isNotEmpty) {
      fullImageUrl = product.catalogImageUrl!.startsWith('http') ? product.catalogImageUrl! : '$kBaseUrl${product.catalogImageUrl}';
    }

    Color gradeBg = const Color(0xFFF1F5F9);
    Color gradeText = const Color(0xFF64748B);
    if (product.qualityGrade == 'HIGH') {
      gradeBg = const Color(0xFFDCFCE7);
      gradeText = const Color(0xFF15803D);
    } else if (product.qualityGrade == 'MEDIUM') {
      gradeBg = const Color(0xFFFEF9C3);
      gradeText = const Color(0xFFA16207);
    } else if (product.qualityGrade == 'LOW') {
      gradeBg = const Color(0xFFFEE2E2);
      gradeText = const Color(0xFFB91C1C);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAddEditProductSheet(context, product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF1F5F9),
                ),
                clipBehavior: Clip.antiAlias,
                child: fullImageUrl != null
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.spa_rounded,
                          color: AppTheme.primary,
                          size: 32,
                        ),
                      )
                    : const Icon(
                        Icons.spa_rounded,
                        color: AppTheme.primary,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: gradeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.qualityGrade,
                            style: TextStyle(
                              color: gradeText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Origin: ${product.farmName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMutedLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Qty',
                              style: TextStyle(fontSize: 10, color: AppTheme.textMutedLight),
                            ),
                            Text(
                              '${product.quantityAvailable} kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Price / kg',
                              style: TextStyle(fontSize: 10, color: AppTheme.textMutedLight),
                            ),
                            Text(
                              '${product.pricePerKg.toStringAsFixed(0)} DA',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddEditProductSheet(context, product),
                          icon: const Icon(Icons.edit_rounded, size: 14),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _confirmDeleteProduct(context, product),
                          icon: const Icon(Icons.delete_outline_rounded, size: 14),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, FarmerProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Product?'),
        content: Text('Are you sure you want to delete "${product.name}" from your inventory? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<FarmerProvider>();
              final success = await provider.deleteProduct(product.id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully!'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Failed to delete product'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditProductSheet(BuildContext context, FarmerProductModel? existingProduct) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return _AddEditProductForm(
              existingProduct: existingProduct,
              scrollController: controller,
            );
          },
        );
      },
    );
  }
}

class _AddEditProductForm extends StatefulWidget {
  final FarmerProductModel? existingProduct;
  final ScrollController scrollController;

  const _AddEditProductForm({
    this.existingProduct,
    required this.scrollController,
  });

  @override
  State<_AddEditProductForm> createState() => _AddEditProductFormState();
}

class _AddEditProductFormState extends State<_AddEditProductForm> {
  final _formKey = GlobalKey<FormState>();
  
  ProductCatalogModel? _selectedCatalog;
  int? _selectedFarmId;
  String _selectedQuality = 'HIGH';

  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FarmerProvider>();

    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      // Find matching catalog and farm
      try {
        _selectedCatalog = provider.catalog.firstWhere((c) => c.id == p.catalogId);
      } catch (_) {
        _selectedCatalog = null;
      }
      _selectedFarmId = p.farmId;
      _selectedQuality = p.qualityGrade;
      _priceController.text = p.pricePerKg.toStringAsFixed(0);
      _quantityController.text = p.quantityAvailable.toString();
    } else {
      if (provider.farms.isNotEmpty) {
        _selectedFarmId = provider.farms[0].id;
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmerProvider>();
    final isEditing = widget.existingProduct != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Handle Bar
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Text(
              isEditing ? 'Edit Product Entry' : 'List New Product',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Set origin, pricing, and volume specs below.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMutedLight),
            ),
            const SizedBox(height: 24),

            // Product Catalog Dropdown
            const Text(
              'Product Type (Regulated Catalog)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            isEditing
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      widget.existingProduct!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  )
                : DropdownButtonFormField<ProductCatalogModel>(
                    initialValue: _selectedCatalog,
                    hint: const Text('Select a crop type...'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    items: provider.catalog.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCatalog = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select a crop type' : null,
                  ),
            const SizedBox(height: 20),

            // Origin Farm
            const Text(
              'Origin Farm',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            provider.farms.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: const Text(
                      'No farms available. Please add a farm first before listing products.',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : DropdownButtonFormField<int>(
                    initialValue: _selectedFarmId,
                    hint: const Text('Select farm...'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    items: provider.farms.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text('${f.name} (${f.wilaya})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedFarmId = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select origin farm' : null,
                  ),
            const SizedBox(height: 20),

            // Price Limits Banner
            if (_selectedCatalog != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Regulated Price Limits for ${_selectedCatalog!.name}:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Minimum Allowed: ${_selectedCatalog!.minPrice?.toStringAsFixed(0) ?? "None"} DA/kg\n'
                      'Maximum Allowed: ${_selectedCatalog!.maxPrice?.toStringAsFixed(0) ?? "None"} DA/kg',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Price and Quantity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price (DA/kg)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final numVal = double.tryParse(val);
                          if (numVal == null || numVal <= 0) return 'Invalid price';
                          if (_selectedCatalog != null) {
                            if (_selectedCatalog!.minPrice != null && numVal < _selectedCatalog!.minPrice!) {
                              return 'Min ${_selectedCatalog!.minPrice!.toStringAsFixed(0)} DA';
                            }
                            if (_selectedCatalog!.maxPrice != null && numVal > _selectedCatalog!.maxPrice!) {
                              return 'Max ${_selectedCatalog!.maxPrice!.toStringAsFixed(0)} DA';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity (${_selectedCatalog?.unit ?? "kg"})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final numVal = double.tryParse(val);
                          if (numVal == null || numVal <= 0) return 'Invalid amount';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quality Grade
            const Text(
              'Quality Grade',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedQuality,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'HIGH', child: Text('High (Premium Grade)')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium (Standard Grade)')),
                DropdownMenuItem(value: 'LOW', child: Text('Low (Basic Grade)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedQuality = val;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Update Product specifications' : 'Publish Product to Public Market',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textMutedLight),
              child: const Text('Discard Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFarmId == null || _selectedCatalog == null) return;

    setState(() {
      _isSaving = true;
    });

    final provider = context.read<FarmerProvider>();
    final double price = double.parse(_priceController.text);
    final double qty = double.parse(_quantityController.text);

    bool success = false;
    if (widget.existingProduct != null) {
      success = await provider.updateProduct(
        productId: widget.existingProduct!.id,
        farmId: _selectedFarmId!,
        pricePerKg: price,
        quantityAvailable: qty,
        qualityGrade: _selectedQuality,
      );
    } else {
      success = await provider.addProduct(
        catalogId: _selectedCatalog!.id,
        farmId: _selectedFarmId!,
        pricePerKg: price,
        quantityAvailable: qty,
        qualityGrade: _selectedQuality,
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingProduct != null
                  ? 'Product specifications updated successfully!'
                  : 'Product listed on the public market!',
            ),
            backgroundColor: AppTheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'An error occurred while listing product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
