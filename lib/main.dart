import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const hasSupabaseConfig = supabaseUrl != '' && supabaseAnonKey != '';

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
      title: 'Loja na Mao',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7C7B),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7F2),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE1E4DD)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD7DBD1)),
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
        if (!snapshot.hasData) {
          return const Scaffold(
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
          appBar: AppBar(
            title: Text(data.store.name),
            actions: [
              IconButton(
                tooltip: 'Pedidos',
                onPressed: () => _openOrders(context, data.store.id),
                icon: const Icon(Icons.receipt_long_outlined),
              ),
              IconButton(
                tooltip: 'Carrinho',
                onPressed: () => _openCheckout(context, data.store),
                icon: Badge(
                  label: Text(cart.itemCount.toString()),
                  isLabelVisible: cart.itemCount > 0,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                storeFuture = repository.loadStore();
              });
              await storeFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                const PortfolioDemoBanner(),
                const SizedBox(height: 12),
                StoreHero(store: data.store),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar produto, combo ou oferta',
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 12),
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
                        onSelected: (_) {
                          setState(() => selectedCategory = category);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ...filteredProducts.map(
                  (product) => ProductCard(
                    product: product,
                    onAdd: () {
                      setState(() => cart.add(product));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} adicionado'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  Future<void> _openCheckout(BuildContext context, Store store) async {
    if (cart.items.isEmpty) return;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
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

  void _openOrders(BuildContext context, String storeId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrdersPage(repository: repository, storeId: storeId),
      ),
    );
  }
}

class PortfolioDemoBanner extends StatelessWidget {
  const PortfolioDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8D6A1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium_outlined, color: Color(0xFF8A6400)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo de portfolio Flutter + Supabase',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF3F2E00),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fluxo demonstrativo para pequenos comercios: catalogo, carrinho, pedido no WhatsApp e backend.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5C470A),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoreHero extends StatelessWidget {
  const StoreHero({required this.store, super.key});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12312F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9C46A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storefront, color: Color(0xFF12312F)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      store.isOpen ? 'Aberto agora' : 'Fechado',
                      style: const TextStyle(color: Color(0xFF9BE7C7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            store.headline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  height: 1.25,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(icon: Icons.schedule, text: '${store.deliveryMinutes} min'),
              InfoPill(icon: Icons.payments_outlined, text: 'Min. ${money(store.minimumOrder)}'),
              const InfoPill(icon: Icons.chat_outlined, text: 'Pedido no WhatsApp'),
            ],
          ),
        ],
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
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_mall_outlined, color: Color(0xFF0E7C7B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    money(product.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF0E7C7B),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Adicionar',
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: onCheckout,
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text('${cart.itemCount} itens - ${money(cart.total)}'),
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finalizar pedido',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            ...widget.cart.items.values.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text('${item.quantity} x ${money(item.product.price)}'),
                trailing: Text(money(item.subtotal)),
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${money(widget.cart.total)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'WhatsApp'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Endereco de entrega'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Observacoes'),
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
                label: const Text('Registrar e enviar no WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, WhatsApp e endereco.')),
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

    await widget.repository.createOrder(draft);
    await launchUrl(Uri.parse(_whatsappUrl(widget.store.whatsapp, draft)));

    if (mounted) Navigator.of(context).pop(true);
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({required this.repository, required this.storeId, super.key});

  final StoreRepository repository;
  final String storeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos recentes')),
      body: FutureBuilder<List<OrderSummary>>(
        future: repository.loadOrders(storeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('Nenhum pedido registrado ainda.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text(order.customerName),
                  subtitle: Text('${order.statusLabel} - ${order.createdAtLabel}'),
                  trailing: Text(
                    money(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StoreRepository {
  Future<StoreData> loadStore() async {
    if (!hasSupabaseConfig) return StoreData.demo();

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
        name: 'Loja na Mao Demo',
        whatsapp: '5599999999999',
        headline: 'Catalogo rapido, pedidos organizados e venda pelo WhatsApp.',
        deliveryMinutes: 45,
        minimumOrder: 25,
        isOpen: true,
      ),
      products: const [
        Product(
          id: '1',
          name: 'Combo Executivo',
          description: 'Produto campeao para almoco rapido com entrega local.',
          category: 'Mais vendidos',
          price: 34.90,
        ),
        Product(
          id: '2',
          name: 'Kit Presente',
          description: 'Opcao pronta para datas comemorativas e pedidos de ultima hora.',
          category: 'Kits',
          price: 79.90,
        ),
        Product(
          id: '3',
          name: 'Produto Premium',
          description: 'Item de maior margem para destacar a vitrine da loja.',
          category: 'Premium',
          price: 129.90,
        ),
        Product(
          id: '4',
          name: 'Oferta da Semana',
          description: 'Produto promocional para aumentar conversao.',
          category: 'Promocoes',
          price: 24.90,
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
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
    );
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
      'done' => 'Concluido',
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
    'Ola! Quero fazer este pedido:\n\n'
    '$items\n\n'
    'Total: ${money(draft.total)}\n'
    'Nome: ${draft.customerName}\n'
    'Telefone: ${draft.customerPhone}\n'
    'Endereco: ${draft.address}\n'
    'Obs: ${draft.notes.isEmpty ? '-' : draft.notes}',
  );
  return 'https://wa.me/$phone?text=$message';
}
