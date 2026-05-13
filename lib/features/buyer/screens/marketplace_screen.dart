import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/buyer_provider.dart';
import '../models/buyer_models.dart';

import '../../../../core/constants/app_constants.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BuyerProvider>();
      if (provider.products.isEmpty) {
        provider.fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Consumer<BuyerProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: provider.fetchProducts,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildSearch(),
                  if (provider.loadingProducts)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                    )
                  else if (provider.error != null)
                    SliverFillRemaining(child: _buildError(provider.error!))
                  else if (provider.products.isEmpty)
                    SliverFillRemaining(child: _buildEmpty())
                  else
                    _buildProductsGrid(provider.products),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo.PNG', height: 24),
                const SizedBox(width: 8),
                const Text(
                  'INSTITUTIONAL MARKETPLACE',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Certified Ag-Supply',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sourced directly from verified national farms.',
              style: TextStyle(color: AppTheme.textMutedLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search products or categories...',
              hintStyle: TextStyle(color: AppTheme.textMutedLight, fontSize: 14),
              border: InputBorder.none,
              icon: Icon(Icons.search_rounded, color: AppTheme.textMutedLight, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<BuyerProductModel> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ProductCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textDark)),
            TextButton(onPressed: () => context.read<BuyerProvider>().fetchProducts(), child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: AppTheme.textMutedLight, size: 56),
          SizedBox(height: 16),
          Text('No products available at the moment.', style: TextStyle(color: AppTheme.textMutedLight)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final BuyerProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Placeholder
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: product.imageUrl != null
                    ? Builder(
                        builder: (context) {
                          final imageUrl = product.imageUrl!.startsWith('http')
                              ? product.imageUrl!
                              : '$kBaseUrl${product.imageUrl}';
                          debugPrint('Loading Marketplace Image: $imageUrl');
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image $imageUrl: $error');
                              return Center(
                                child: Icon(Icons.broken_image_rounded, color: AppTheme.primary.withOpacity(0.2), size: 40),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppTheme.primary.withOpacity(0.2),
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Center(
                        child: Icon(Icons.agriculture_rounded, color: AppTheme.primary.withOpacity(0.2), size: 40),
                      ),
              ),
            ),
          ),
          // Info
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(color: AppTheme.textDark, fontSize: 15, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.farmerName} · ${product.farmerWilaya}',
                    style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} DA',
                        style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '/${product.unit}',
                        style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _showBuySheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('PURCHASE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBuySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BuyBottomSheet(product: product),
    );
  }
}

class _BuyBottomSheet extends StatefulWidget {
  final BuyerProductModel product;
  const _BuyBottomSheet({required this.product});

  @override
  State<_BuyBottomSheet> createState() => _BuyBottomSheetState();
}

class _BuyBottomSheetState extends State<_BuyBottomSheet> {
  double quantity = 1.0;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Confirm Procurement', style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.w800)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppTheme.bgLight, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.shopping_basket_rounded, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name, style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${widget.product.farmerName} · ${widget.product.farmerWilaya}', style: const TextStyle(color: AppTheme.textMutedLight, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('SPECIFY QUANTITY', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            children: [
              _qtyBtn(Icons.remove, () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1)),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Text('${quantity.toStringAsFixed(1)} ${widget.product.unit}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                ),
              ),
              _qtyBtn(Icons.add, () => setState(() => quantity++)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PAYABLE', style: TextStyle(color: AppTheme.textMutedLight, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${(widget.product.price * quantity).toStringAsFixed(0)} DA', style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : _handleOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: loading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('GENERATE PURCHASE ORDER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppTheme.bgLight, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppTheme.textDark),
      ),
    );
  }

  Future<void> _handleOrder() async {
    setState(() => loading = true);
    final ok = await context.read<BuyerProvider>().createOrder(widget.product.id, quantity);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Order generated successfully!' : 'Failed to generate order.'),
      backgroundColor: ok ? AppTheme.primary : Colors.red,
    ));
  }
}
