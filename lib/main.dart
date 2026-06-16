import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const hasSupabaseConfig = supabaseUrl != '' && supabaseAnonKey != '';

const ink = Color(0xFF17201D);
const mutedInk = Color(0xFF64736D);
const forest = Color(0xFF12312F);
const emerald = Color(0xFF0E7C7B);
const mint = Color(0xFFE9F5EF);
const paper = Color(0xFFF7F4EC);
const line = Color(0xFFE2DED3);
const amber = Color(0xFFE4B44C);
const coral = Color(0xFFD85C48);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (hasSupabaseConfig) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(const LojaNaMaoApp());
}

class LojaNaMaoApp extends StatelessWidget {
  const LojaNaMaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loja na Mão',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: line),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: forest,
            minimumSize: const Size(48, 48),
            side: const BorderSide(color: line),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: mutedInk),
          hintStyle: const TextStyle(color: mutedInk),
          prefixIconColor: mutedInk,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: emerald, width: 1.6),
          ),
        ),
      ),
      home: const StorefrontPage(),
    );
  }
}

class StorefrontPage extends StatefulWidget {
  const StorefrontPage({super.key});

  @override
  State<StorefrontPage> createState() => _StorefrontPageState();
}

class _StorefrontPageState extends State<StorefrontPage> {
  final repository = StoreRepository();
  final cart = CartController();
  final searchController = TextEditingController();
  late Future<StoreData> storeFuture;
  String selectedCategory = 'Todos';
  String query = '';

  @override
  void initState() {
    super.initState();
    storeFuture = repository.loadStore();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoreData>(
      future: storeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: const PortfolioTopBar(),
            body: ErrorState(
              message: 'Não foi possível carregar a vitrine.',
              onRetry: () {
                _reload();
              },
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            appBar: PortfolioTopBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final categories = ['Todos', ...data.categories];
        final filteredProducts = data.products.where((product) {
          final matchesCategory =
              selectedCategory == 'Todos' || product.category == selectedCategory;
          final text = '${product.name} ${product.description}'.toLowerCase();
          return matchesCategory && text.contains(query.toLowerCase());
        }).toList();

        return Scaffold(
          appBar: PortfolioTopBar(
            itemCount: cart.itemCount,
            onOrders: () => _openAdmin(context, data.store),
            onCart: () => _openCheckout(context, data.store),
          ),
          body: RefreshIndicator(
            onRefresh: _reload,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 32 : 16,
                    10,
                    isWide ? 32 : 16,
                    cart.items.isEmpty ? 28 : 104,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: StorefrontMainColumn(
                                      store: data.store,
                                      products: filteredProducts,
                                      categories: categories,
                                      selectedCategory: selectedCategory,
                                      searchController: searchController,
                                      query: query,
                                      onQueryChanged: (value) {
                                        setState(() => query = value);
                                      },
                                      onCategoryChanged: (value) {
                                        setState(() => selectedCategory = value);
                                      },
                                      onAdd: _addToCart,
                                      isWide: true,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 4,
                                    child: PortfolioProofPanel(
                                      cart: cart,
                                      store: data.store,
                                      onCheckout: () => _openCheckout(context, data.store),
                                      onOrders: () => _openAdmin(context, data.store),
                                    ),
                                  ),
                                ],
                              )
                            : StorefrontMainColumn(
                                store: data.store,
                                products: filteredProducts,
                                categories: categories,
                                selectedCategory: selectedCategory,
                                searchController: searchController,
                                query: query,
                                onQueryChanged: (value) {
                                  setState(() => query = value);
                                },
                                onCategoryChanged: (value) {
                                  setState(() => selectedCategory = value);
                                },
                                onAdd: _addToCart,
                                isWide: false,
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: CartSummaryBar(
            cart: cart,
            onCheckout: () => _openCheckout(context, data.store),
          ),
        );
      },
    );
  }

  Future<void> _reload() async {
    final future = repository.loadStore();
    setState(() {
      storeFuture = future;
    });
    try {
      await future;
    } catch (error) {
      // FutureBuilder renders the error state; the refresh gesture only needs to finish.
    }
  }

  void _addToCart(Product product) {
    setState(() => cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao pedido'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _openCheckout(BuildContext context, Store store) async {
    if (cart.items.isEmpty) return;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckoutSheet(
        store: store,
        cart: cart,
        repository: repository,
      ),
    );

    if (result == true && mounted) {
      setState(cart.clear);
    }
  }

  Future<void> _openAdmin(BuildContext context, Store store) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminPanelPage(repository: repository, store: store),
      ),
    );
    if (mounted) {
      await _reload();
    }
  }
}

class PortfolioTopBar extends StatelessWidget implements PreferredSizeWidget {
  const PortfolioTopBar({
    this.itemCount = 0,
    this.onOrders,
    this.onCart,
    super.key,
  });

  final int itemCount;
  final VoidCallback? onOrders;
  final VoidCallback? onCart;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: forest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Loja na Mão',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  'Pedidos online para negócios locais',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: mutedInk, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Painel do lojista',
          onPressed: onOrders,
          icon: const Icon(Icons.dashboard_customize_outlined),
        ),
        IconButton(
          tooltip: 'Carrinho',
          onPressed: onCart,
          icon: Badge(
            label: Text(itemCount.toString()),
            isLabelVisible: itemCount > 0,
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class StorefrontMainColumn extends StatelessWidget {
  const StorefrontMainColumn({
    required this.store,
    required this.products,
    required this.categories,
    required this.selectedCategory,
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onAdd,
    required this.isWide,
    super.key,
  });

  final Store store;
  final List<Product> products;
  final List<String> categories;
  final String selectedCategory;
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<Product> onAdd;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreHero(store: store),
        const SizedBox(height: 12),
        const BusinessImpactStrip(),
        const SizedBox(height: 18),
        SearchAndFilters(
          categories: categories,
          selectedCategory: selectedCategory,
          controller: searchController,
          onQueryChanged: onQueryChanged,
          onCategoryChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: selectedCategory == 'Todos' ? 'Produtos em destaque' : selectedCategory,
          subtitle: '${products.length} opções prontas para pedido',
        ),
        const SizedBox(height: 10),
        if (products.isEmpty)
          EmptyProducts(query: query)
        else
          ProductGrid(
            products: products,
            isWide: isWide,
            onAdd: onAdd,
          ),
      ],
    );
  }
}

class BusinessImpactStrip extends StatelessWidget {
  const BusinessImpactStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ImpactItemData(
        icon: Icons.fact_check_outlined,
        title: 'Pedido padronizado',
        text: 'Menos conversa perdida no WhatsApp.',
      ),
      ImpactItemData(
        icon: Icons.bolt_outlined,
        title: 'Venda mais rápido',
        text: 'Cliente escolhe, soma e envia.',
      ),
      ImpactItemData(
        icon: Icons.storage_outlined,
        title: 'Pedido acompanhado',
        text: 'Tudo fica salvo para consulta.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                Expanded(child: ImpactItem(data: items[index])),
                if (index != items.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        }

        return SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 220,
                child: ImpactItem(data: items[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class ImpactItemData {
  const ImpactItemData({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;
}

class ImpactItem extends StatelessWidget {
  const ImpactItem({required this.data, super.key});

  final ImpactItemData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: mint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(data.icon, color: emerald, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: mutedInk, fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreHero extends StatelessWidget {
  const StoreHero({required this.store, super.key});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: forest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: StoreHeroCopy(store: store)),
                    const SizedBox(width: 16),
                    const Expanded(child: StoreHeroImage()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StoreHeroImage(),
                    const SizedBox(height: 14),
                    StoreHeroCopy(store: store),
                  ],
                ),
        );
      },
    );
  }
}

class StoreHeroImage extends StatelessWidget {
  const StoreHeroImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.asset(
          'assets/images/storefront-hero.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class StoreHeroCopy extends StatelessWidget {
  const StoreHeroCopy({required this.store, super.key});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_mall_outlined, color: forest),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                store.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
              ),
              StoreStatusChip(isOpen: store.isOpen),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            store.headline,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.28,
                ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(icon: Icons.schedule, text: '${store.deliveryMinutes} min'),
              InfoPill(
                icon: Icons.payments_outlined,
                text: 'Min. ${money(store.minimumOrder)}',
              ),
              const InfoPill(icon: Icons.chat_outlined, text: 'WhatsApp'),
              const InfoPill(icon: Icons.receipt_long_outlined, text: 'Pedidos salvos'),
            ],
          ),
        ],
      ),
    );
  }
}

class StoreStatusChip extends StatelessWidget {
  const StoreStatusChip({required this.isOpen, super.key});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? 'Aberto agora' : 'Fechado',
        style: TextStyle(
          color: isOpen ? const Color(0xFF166534) : const Color(0xFF9F1239),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ProductAvailabilityChip extends StatelessWidget {
  const ProductAvailabilityChip({required this.isAvailable, super.key});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAvailable ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        isAvailable ? 'Ativo' : 'Oculto',
        style: TextStyle(
          color: isAvailable ? const Color(0xFF166534) : const Color(0xFF475569),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class SearchAndFilters extends StatelessWidget {
  const SearchAndFilters({
    required this.categories,
    required this.selectedCategory,
    required this.controller,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    super.key,
  });

  final List<String> categories;
  final String selectedCategory;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar combos, kits ou promoções',
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) => onCategoryChanged(category),
                selectedColor: mint,
                side: BorderSide(
                  color: selectedCategory == category ? emerald : line,
                ),
                labelStyle: TextStyle(
                  color: selectedCategory == category ? forest : ink,
                  fontWeight:
                      selectedCategory == category ? FontWeight.w800 : FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ink,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: mutedInk),
              ),
            ],
          ),
        ),
        const Icon(Icons.tune, color: mutedInk, size: 19),
      ],
    );
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.products,
    required this.isWide,
    required this.onAdd,
    super.key,
  });

  final List<Product> products;
  final bool isWide;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (final product in products) ...[
            ProductCard(product: product, onAdd: () => onAdd(product)),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final product in products)
              SizedBox(
                width: width,
                child: ProductCard(product: product, onAdd: () => onAdd(product)),
              ),
          ],
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onAdd, super.key});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductThumb(category: product.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category,
                        style: const TextStyle(
                          color: emerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: mutedInk,
                              height: 1.22,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    money(product.price),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: forest,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductThumb extends StatelessWidget {
  const ProductThumb({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      'Mais pedidos' => Icons.local_fire_department_outlined,
      'Presentes' => Icons.redeem_outlined,
      'Premium' => Icons.diamond_outlined,
      'Promoções' => Icons.sell_outlined,
      _ => Icons.local_mall_outlined,
    };

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4E8DE)),
      ),
      child: Icon(icon, color: emerald, size: 30),
    );
  }
}

class EmptyProducts extends StatelessWidget {
  const EmptyProducts({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.search_off_outlined, color: mutedInk, size: 34),
            const SizedBox(height: 10),
            Text(
              'Nenhum produto encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              query.isEmpty
                  ? 'Tente outra categoria da vitrine.'
                  : 'Não encontramos resultado para "$query".',
              textAlign: TextAlign.center,
              style: const TextStyle(color: mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class PortfolioProofPanel extends StatelessWidget {
  const PortfolioProofPanel({
    required this.cart,
    required this.store,
    required this.onCheckout,
    required this.onOrders,
    super.key,
  });

  final CartController cart;
  final Store store;
  final VoidCallback onCheckout;
  final VoidCallback onOrders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'O que este app entrega',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                const ProofItem(
                  icon: Icons.phone_iphone,
                  title: 'Vitrine no celular',
                  text: 'Produtos organizados para o cliente comprar rápido.',
                ),
                const ProofItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedido registrado',
                  text: 'O lojista acompanha tudo em um painel simples.',
                ),
                const ProofItem(
                  icon: Icons.chat_outlined,
                  title: 'Atendimento no WhatsApp',
                  text: 'Mensagem pronta para responder com agilidade.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido atual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                MetricRow(label: 'Itens', value: cart.itemCount.toString()),
                MetricRow(label: 'Total', value: money(cart.total)),
                MetricRow(label: 'Entrega estimada', value: '${store.deliveryMinutes} min'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: cart.items.isEmpty ? null : onCheckout,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Finalizar pedido'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOrders,
                    icon: const Icon(Icons.dashboard_customize_outlined),
                    label: const Text('Abrir painel do lojista'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProofItem extends StatelessWidget {
  const ProofItem({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: emerald, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(color: mutedInk, height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricRow extends StatelessWidget {
  const MetricRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: mutedInk))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({required this.cart, required this.onCheckout, super.key});

  final CartController cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    if (cart.items.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: line)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: FilledButton.icon(
            onPressed: onCheckout,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(
              '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'itens'} - ${money(cart.total)}',
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({
    required this.store,
    required this.cart,
    required this.repository,
    super.key,
  });

  final Store store;
  final CartController cart;
  final StoreRepository repository;

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  bool isSending = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: const BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  'Finalizar pedido',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O pedido fica registrado e também vai formatado para o WhatsApp.',
                  style: TextStyle(color: mutedInk),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ...widget.cart.items.values.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      Text(
                                        '${item.quantity} x ${money(item.product.price)}',
                                        style: const TextStyle(color: mutedInk, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  money(item.subtotal),
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total do pedido',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Text(
                              money(widget.cart.total),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: forest,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do cliente',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço de entrega',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isSending ? null : _submit,
                    icon: isSending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(isSending ? 'Registrando pedido...' : 'Registrar e enviar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, WhatsApp e endereço.')),
      );
      return;
    }

    setState(() => isSending = true);
    final draft = OrderDraft(
      storeId: widget.store.id,
      customerName: nameController.text.trim(),
      customerPhone: phoneController.text.trim(),
      address: addressController.text.trim(),
      notes: notesController.text.trim(),
      items: widget.cart.items.values.toList(),
      total: widget.cart.total,
    );

    try {
      await widget.repository.createOrder(draft);
      await launchUrl(Uri.parse(_whatsappUrl(widget.store.whatsapp, draft)));

      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível registrar o pedido: $error'),
        ),
      );
    }
  }
}

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({
    required this.repository,
    required this.store,
    super.key,
  });

  final StoreRepository repository;
  final Store store;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel do lojista'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Pedidos'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Produtos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrdersPanel(repository: repository, storeId: store.id),
            ProductsAdminTab(repository: repository, store: store),
          ],
        ),
      ),
    );
  }
}

class OrdersPanel extends StatefulWidget {
  const OrdersPanel({required this.repository, required this.storeId, super.key});

  final StoreRepository repository;
  final String storeId;

  @override
  State<OrdersPanel> createState() => _OrdersPanelState();
}

class _OrdersPanelState extends State<OrdersPanel> {
  late Future<List<OrderSummary>> ordersFuture;

  @override
  void initState() {
    super.initState();
    ordersFuture = widget.repository.loadOrders(widget.storeId);
  }

  Future<void> _reload() async {
    final future = widget.repository.loadOrders(widget.storeId);
    setState(() => ordersFuture = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderSummary>>(
        future: ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorState(
              message: 'Não foi possível carregar os pedidos.',
              onRetry: _reload,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;
          final total = orders.fold<double>(0, (sum, order) => sum + order.total);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedidos recentes',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Visão simples para o lojista acompanhar os pedidos recebidos.',
                        style: TextStyle(color: mutedInk),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AdminMetricCard(
                              label: 'Pedidos',
                              value: orders.length.toString(),
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AdminMetricCard(
                              label: 'Recebido',
                              value: money(total),
                              icon: Icons.payments_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (orders.isEmpty)
                        const EmptyOrders()
                      else
                        ...orders.map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OrderCard(order: order),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
  }
}

class ProductsAdminTab extends StatefulWidget {
  const ProductsAdminTab({required this.repository, required this.store, super.key});

  final StoreRepository repository;
  final Store store;

  @override
  State<ProductsAdminTab> createState() => _ProductsAdminTabState();
}

class _ProductsAdminTabState extends State<ProductsAdminTab> {
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture = widget.repository.loadProducts(widget.store.id);
  }

  Future<void> _reload() async {
    final future = widget.repository.loadProducts(widget.store.id);
    setState(() => productsFuture = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: productsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorState(
            message: 'Não foi possível carregar os produtos.',
            onRetry: _reload,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        final activeProducts = products.where((product) => product.isAvailable).length;
        final hiddenProducts = products.length - activeProducts;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catálogo da loja',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Cadastre, edite ou desative produtos sem mexer no código.',
                                style: TextStyle(color: mutedInk),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _openProductForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Produto'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AdminMetricCard(
                            label: 'Produtos',
                            value: products.length.toString(),
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminMetricCard(
                            label: 'Na vitrine',
                            value: activeProducts.toString(),
                            icon: Icons.visibility_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminMetricCard(
                            label: 'Ocultos',
                            value: hiddenProducts.toString(),
                            icon: Icons.visibility_off_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (products.isEmpty)
                      const EmptyProductsAdmin()
                    else
                      ...products.map(
                        (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProductAdminCard(
                            product: product,
                            onEdit: () => _openProductForm(product: product),
                            onToggle: () => _toggleProduct(product),
                            onDelete: () => _deleteProduct(product),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProductForm({Product? product}) async {
    final draft = await showModalBottomSheet<ProductDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(product: product),
    );

    if (draft == null) return;

    await _runProductAction(
      () async {
        await widget.repository.saveProduct(
          storeId: widget.store.id,
          draft: draft,
          productId: product?.id,
        );
        await _reload();
      },
      successMessage: product == null ? 'Produto cadastrado.' : 'Produto atualizado.',
    );
  }

  Future<void> _toggleProduct(Product product) async {
    await _runProductAction(
      () async {
        await widget.repository.saveProduct(
          storeId: widget.store.id,
          productId: product.id,
          draft: ProductDraft(
            name: product.name,
            description: product.description,
            category: product.category,
            price: product.price,
            isAvailable: !product.isAvailable,
          ),
        );
        await _reload();
      },
      successMessage:
          product.isAvailable ? 'Produto ocultado da vitrine.' : 'Produto voltou para a vitrine.',
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(
          'Isso remove "${product.name}" do catálogo. Se ele já apareceu em pedidos, prefira ocultar para preservar o histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    await _runProductAction(
      () async {
        await widget.repository.deleteProduct(product.id);
        await _reload();
      },
      successMessage: 'Produto excluído.',
    );
  }

  Future<void> _runProductAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível concluir. Verifique os dados e tente novamente.'),
        ),
      );
    }
  }
}

class AdminMetricCard extends StatelessWidget {
  const AdminMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: emerald),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: mutedInk)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductAdminCard extends StatelessWidget {
  const ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductThumb(category: product.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      ProductAvailabilityChip(isAvailable: product.isAvailable),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(product.category, style: const TextStyle(color: emerald)),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: mutedInk),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(product.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: forest,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  tooltip: 'Editar',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: product.isAvailable ? 'Desativar' : 'Ativar',
                  onPressed: onToggle,
                  icon: Icon(
                    product.isAvailable
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: coral),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyProductsAdmin extends StatelessWidget {
  const EmptyProductsAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, color: mutedInk, size: 34),
            const SizedBox(height: 10),
            Text(
              'Nenhum produto cadastrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cadastre o primeiro produto para montar a vitrine.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({this.product, super.key});

  final Product? product;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController categoryController;
  late final TextEditingController priceController;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    nameController = TextEditingController(text: product?.name ?? '');
    descriptionController = TextEditingController(text: product?.description ?? '');
    categoryController = TextEditingController(text: product?.category ?? '');
    priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(2).replaceAll('.', ','),
    );
    isAvailable = product?.isAvailable ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: const BoxDecoration(
            color: paper,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  widget.product == null ? 'Novo produto' : 'Editar produto',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do produto',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Produto visível na vitrine'),
                  value: isAvailable,
                  onChanged: (value) => setState(() => isAvailable = value),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar produto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final category = categoryController.text.trim();
    final priceText = priceController.text.trim().replaceAll(',', '.');
    final price = double.tryParse(priceText);

    if (name.isEmpty || description.isEmpty || category.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, descrição, categoria e preço.')),
      );
      return;
    }

    Navigator.of(context).pop(
      ProductDraft(
        name: name,
        description: description,
        category: category,
        price: price,
        isAvailable: isAvailable,
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, super.key});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: mint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long_outlined, color: emerald),
        ),
        title: Text(
          order.customerName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${order.statusLabel} - ${order.createdAtLabel}'),
        trailing: Text(
          money(order.total),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class EmptyOrders extends StatelessWidget {
  const EmptyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, color: mutedInk, size: 34),
            const SizedBox(height: 10),
            Text(
              'Nenhum pedido ainda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Finalize um pedido na vitrine para ver o registro aparecer aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: coral, size: 42),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreRepository {
  StoreData? _localData;

  StoreData get _demoData => _localData ??= StoreData.demo();

  Future<StoreData> loadStore() async {
    if (!hasSupabaseConfig) {
      final data = _demoData;
      return StoreData(
        store: data.store,
        products: data.products.where((product) => product.isAvailable).toList(),
      );
    }

    final client = Supabase.instance.client;
    final storeMap = await client
        .from('stores')
        .select()
        .eq('slug', 'loja-demo')
        .single();
    final productsMap = await client
        .from('products')
        .select()
        .eq('store_id', storeMap['id'])
        .eq('is_available', true)
        .order('created_at');

    return StoreData(
      store: Store.fromMap(storeMap),
      products: productsMap.map((map) => Product.fromMap(map)).toList(),
    );
  }

  Future<List<Product>> loadProducts(String storeId) async {
    if (!hasSupabaseConfig) return _demoData.products;

    final response = await Supabase.instance.client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .order('created_at');

    return response.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> saveProduct({
    required String storeId,
    required ProductDraft draft,
    String? productId,
  }) async {
    if (!hasSupabaseConfig) {
      final data = _demoData;
      final products = [...data.products];
      final product = Product(
        id: productId ?? 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: draft.name,
        description: draft.description,
        category: draft.category,
        price: draft.price,
        isAvailable: draft.isAvailable,
      );

      if (productId == null) {
        products.add(product);
      } else {
        final index = products.indexWhere((item) => item.id == productId);
        if (index >= 0) products[index] = product;
      }
      _localData = StoreData(store: data.store, products: products);
      return;
    }

    final payload = draft.toMap()..['store_id'] = storeId;
    if (productId == null) {
      await Supabase.instance.client.from('products').insert(payload);
      return;
    }

    await Supabase.instance.client.from('products').update(payload).eq('id', productId);
  }

  Future<void> deleteProduct(String productId) async {
    if (!hasSupabaseConfig) {
      final data = _demoData;
      _localData = StoreData(
        store: data.store,
        products: data.products.where((product) => product.id != productId).toList(),
      );
      return;
    }

    await Supabase.instance.client.from('products').delete().eq('id', productId);
  }

  Future<void> createOrder(OrderDraft draft) async {
    if (!hasSupabaseConfig) return;

    final client = Supabase.instance.client;
    final order = await client
        .from('orders')
        .insert(draft.toOrderMap())
        .select('id')
        .single();

    final orderId = order['id'] as String;
    await client.from('order_items').insert(
          draft.items.map((item) => item.toMap(orderId)).toList(),
        );
  }

  Future<List<OrderSummary>> loadOrders(String storeId) async {
    if (!hasSupabaseConfig) return OrderSummary.demo();

    final response = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('store_id', storeId)
        .order('created_at', ascending: false)
        .limit(20);

    return response.map((map) => OrderSummary.fromMap(map)).toList();
  }
}

class StoreData {
  StoreData({required this.store, required this.products});

  final Store store;
  final List<Product> products;

  List<String> get categories => {
        for (final product in products) product.category,
      }.toList();

  factory StoreData.demo() {
    return StoreData(
      store: const Store(
        id: 'demo-store',
        name: 'Doce Encanto',
        whatsapp: '5599999999999',
        headline:
            'Doces artesanais, kits presenteáveis e pedidos organizados para vender mais pelo WhatsApp.',
        deliveryMinutes: 45,
        minimumOrder: 25,
        isOpen: true,
      ),
      products: const [
        Product(
          id: '1',
          name: 'Caixa Brigadeiros Gourmet',
          description: 'Nove brigadeiros artesanais em embalagem pronta para presente.',
          category: 'Mais pedidos',
          price: 49.90,
        ),
        Product(
          id: '2',
          name: 'Kit Presente Especial',
          description: 'Seleção de doces finos com fita, tag e cartão para mensagem.',
          category: 'Presentes',
          price: 89.90,
        ),
        Product(
          id: '3',
          name: 'Torta Chocolate Belga',
          description: 'Torta premium para celebrações, com cobertura cremosa e crocante.',
          category: 'Premium',
          price: 139.90,
        ),
        Product(
          id: '4',
          name: 'Combo Café da Tarde',
          description: 'Mini tortas e docinhos para reuniões pequenas ou entrega rápida.',
          category: 'Promoções',
          price: 64.90,
        ),
      ],
    );
  }
}

class Store {
  const Store({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.headline,
    required this.deliveryMinutes,
    required this.minimumOrder,
    required this.isOpen,
  });

  final String id;
  final String name;
  final String whatsapp;
  final String headline;
  final int deliveryMinutes;
  final double minimumOrder;
  final bool isOpen;

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as String,
      name: map['name'] as String,
      whatsapp: map['whatsapp'] as String,
      headline: map['headline'] as String,
      deliveryMinutes: map['delivery_minutes'] as int,
      minimumOrder: (map['minimum_order'] as num).toDouble(),
      isOpen: map['is_open'] as bool,
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final bool isAvailable;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      isAvailable: map['is_available'] as bool? ?? true,
    );
  }
}

class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.isAvailable,
  });

  final String name;
  final String description;
  final String category;
  final double price;
  final bool isAvailable;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'is_available': isAvailable,
    };
  }
}

class CartController {
  final Map<String, CartItem> items = {};

  int get itemCount => items.values.fold(0, (sum, item) => sum + item.quantity);

  double get total => items.values.fold(0, (sum, item) => sum + item.subtotal);

  void add(Product product) {
    final current = items[product.id];
    items[product.id] = CartItem(
      product: product,
      quantity: (current?.quantity ?? 0) + 1,
    );
  }

  void clear() => items.clear();
}

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toMap(String orderId) {
    return {
      'order_id': orderId,
      'product_id': product.id,
      'quantity': quantity,
      'unit_price': product.price,
    };
  }
}

class OrderDraft {
  const OrderDraft({
    required this.storeId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.notes,
    required this.items,
    required this.total,
  });

  final String storeId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String notes;
  final List<CartItem> items;
  final double total;

  Map<String, dynamic> toOrderMap() {
    return {
      'store_id': storeId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'notes': notes,
      'total': total,
    };
  }
}

class OrderSummary {
  const OrderSummary({
    required this.customerName,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final String customerName;
  final double total;
  final String status;
  final DateTime createdAt;

  String get statusLabel {
    return switch (status) {
      'new' => 'Novo',
      'confirmed' => 'Confirmado',
      'delivering' => 'Em entrega',
      'done' => 'Concluído',
      'cancelled' => 'Cancelado',
      _ => status,
    };
  }

  String get createdAtLabel => DateFormat('dd/MM HH:mm').format(createdAt);

  factory OrderSummary.fromMap(Map<String, dynamic> map) {
    return OrderSummary(
      customerName: map['customer_name'] as String,
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static List<OrderSummary> demo() {
    return [
      OrderSummary(
        customerName: 'Cliente exemplo',
        total: 114.80,
        status: 'new',
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
    ];
  }
}

String money(double value) {
  return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
}

String _whatsappUrl(String phone, OrderDraft draft) {
  final items = draft.items
      .map((item) => '- ${item.quantity}x ${item.product.name}: ${money(item.subtotal)}')
      .join('\n');
  final message = Uri.encodeComponent(
    'Olá! Quero fazer este pedido:\n\n'
    '$items\n\n'
    'Total: ${money(draft.total)}\n'
    'Nome: ${draft.customerName}\n'
    'Telefone: ${draft.customerPhone}\n'
    'Endereço: ${draft.address}\n'
    'Obs: ${draft.notes.isEmpty ? '-' : draft.notes}',
  );
  return 'https://wa.me/$phone?text=$message';
}
