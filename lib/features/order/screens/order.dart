import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../product/model/ProductModel.dart';
import '../../visit/Doctor/controllers/doctor_visit_product_controller.dart';
import '../database/order_database.dart';
import '../models/order_models.dart';
import '../repositories/order_repository.dart';
import '../services/order_sync_service.dart';
import '../widgets/order_widgets.dart';
import 'order_create.dart';
import 'order_detail.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen(
      {super.key,
      this.embedded = false,
      this.repository,
      this.products,
      this.syncService});

  final bool embedded;
  final OrderRepository? repository;
  final List<Product>? products;
  final OrderSyncService? syncService;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with WidgetsBindingObserver {
  final _search = TextEditingController();
  DoctorVisitProductController? _catalogue;
  OrderDatabase? _database;
  OrderRepository? _repository;
  OrderSyncService? _sync;
  List<LocalOrder> _orders = [];
  bool _loading = true, _refreshing = false;
  String? _loadError;
  String _filter = 'All orders';
  bool _oldestFirst = false;

  DateTime get _cutoff {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - 9);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _initialize() async {
    try {
      if (widget.repository != null) {
        _repository = widget.repository;
      } else {
        final db = await OrderDatabase.open();
        if (!mounted) {
          await db.close();
          return;
        }
        _database = db;
        _repository = OrderRepository(database: db);
      }
      _sync = widget.syncService ??
          OrderSyncService(
              repository: _repository!,
              remote: HttpOrderRemoteDataSource(),
              onChanged: _reload);
      if (widget.syncService == null) _sync!.startListening();
      if (widget.products == null) {
        _catalogue = DoctorVisitProductController();
        await _catalogue!.loadProducts();
      }
      await _reload();
      if (mounted) unawaited(_refresh());
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
          _loadError = 'Order storage could not be opened. Please try again.';
        });
    }
  }

  Future<void> _reload() async {
    if (!mounted || _repository == null) return;
    final orders = await _repository!.recentOrders(cutoff: _cutoff);
    if (mounted)
      setState(() {
        _orders = orders;
        _loading = false;
        _loadError = null;
      });
  }

  Future<List<Product>> _refreshProducts() async {
    await _catalogue?.refreshProducts();
    return widget.products ?? _catalogue?.productList.toList() ?? [];
  }

  Future<void> _refresh({bool notify = false}) async {
    if (_refreshing || _sync == null || !mounted) return;
    setState(() => _refreshing = true);
    try {
      final results = await Future.wait<dynamic>(
          [_sync!.syncPending(), _refreshProducts()]);
      await _reload();
      if (notify && mounted)
        _message((results.first as OrderSyncResult).message);
    } catch (_) {
      if (notify && mounted)
        _message('Refresh was interrupted. Your orders remain on this device.');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  List<LocalOrder> get _visible {
    final query = _search.text.trim().toLowerCase();
    final filtered = _orders.where((o) {
      if (_filter == 'Needs retry' && o.syncState != OrderSyncState.failed)
        return false;
      if (_filter == 'Awaiting upload' && o.syncState != OrderSyncState.pending)
        return false;
      if (_filter == 'Urgent' && o.priority != 'Urgent') return false;
      return query.isEmpty ||
          [
            o.doctorName,
            o.clinicName ?? '',
            o.reference,
            o.purchaseOrderReference ?? '',
            o.area ?? '',
            ...o.items.map((i) => i.productName)
          ].any((s) => s.toLowerCase().contains(query));
    }).toList();
    filtered.sort((a, b) => _oldestFirst
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<void> _create() async {
    if (_repository == null) return;
    final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => OrderCreateScreen(
                repository: _repository!,
                products:
                    widget.products ?? _catalogue?.productList.toList() ?? [],
                refreshProducts: _refreshProducts)));
    if (result == true && mounted) {
      await _reload();
      if (mounted) {
        _message('Order and attachment saved on this device.');
        unawaited(_refresh());
      }
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  Future<void> _closeResources() async {
    if (widget.syncService == null) await _sync?.dispose();
    await _database?.close();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _search.dispose();
    _catalogue?.dispose();
    unawaited(_closeResources());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: orderTheme(context),
      child: Builder(builder: (context) {
        final orders = _visible;
        return Scaffold(
          appBar: widget.embedded
              ? null
              : AppBar(
                  title: const Text('Order Management'),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: _repository == null ? null : _create,
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('New order',
                  style: TextStyle(fontWeight: FontWeight.w700))),
          body: SafeArea(
              child: RefreshIndicator(
                  onRefresh: () => _refresh(notify: true),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final padding = constraints.maxWidth > 1160
                        ? (constraints.maxWidth - 1120) / 2
                        : 20.0;
                    return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(padding, 20, padding, 0),
                              sliver: SliverToBoxAdapter(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                    _header(),
                                    const SizedBox(height: 20),
                                    Row(children: [
                                      const Expanded(
                                          child: Text('Your order desk',
                                              style: TextStyle(
                                                  fontSize: 19,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      IconButton(
                                          tooltip:
                                              'Refresh orders and products',
                                          onPressed: _refreshing
                                              ? null
                                              : () => _refresh(notify: true),
                                          icon: _refreshing
                                              ? const SizedBox.square(
                                                  dimension: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2))
                                              : const Icon(Icons.sync))
                                    ]),
                                    const Text(
                                        'Last 10 days · uploaded orders are removed locally',
                                        style: TextStyle(
                                            color: TColors.textSecondary,
                                            fontSize: 12)),
                                    const SizedBox(height: 14),
                                    TextField(
                                        controller: _search,
                                        onChanged: (_) => setState(() {}),
                                        decoration: InputDecoration(
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            hintText:
                                                'Search customer, product or reference',
                                            suffixIcon: _search.text.isEmpty
                                                ? null
                                                : IconButton(
                                                    tooltip: 'Clear search',
                                                    onPressed: () =>
                                                        setState(_search.clear),
                                                    icon: const Icon(
                                                        Icons.close)))),
                                    const SizedBox(height: 12),
                                    Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          ...[
                                            'All orders',
                                            'Awaiting upload',
                                            'Needs retry',
                                            'Urgent'
                                          ].map((label) => ChoiceChip(
                                              label: Text(label,
                                                  style: const TextStyle(
                                                      fontSize: 11)),
                                              selected: _filter == label,
                                              onSelected: (_) => setState(
                                                  () => _filter = label))),
                                          TextButton.icon(
                                              onPressed: () => setState(() =>
                                                  _oldestFirst = !_oldestFirst),
                                              icon: const Icon(Icons.swap_vert,
                                                  size: 16),
                                              label: Text(
                                                  _oldestFirst
                                                      ? 'Oldest first'
                                                      : 'Newest first',
                                                  style: const TextStyle(
                                                      fontSize: 11))),
                                        ]),
                                    const SizedBox(height: 14),
                                  ]))),
                          if (_loading)
                            const SliverToBoxAdapter(
                                child: Padding(
                                    padding: EdgeInsets.all(48),
                                    child: Center(
                                        child: CircularProgressIndicator())))
                          else if (_loadError != null)
                            SliverToBoxAdapter(
                                child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(children: [
                                      Text(_loadError!),
                                      TextButton(
                                          onPressed: _initialize,
                                          child: const Text('Try again'))
                                    ])))
                          else if (orders.isEmpty)
                            SliverToBoxAdapter(
                                child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        28, 35, 28, 130),
                                    child: Column(children: [
                                      Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: const BoxDecoration(
                                              color: TColors.primary_shade50,
                                              shape: BoxShape.circle),
                                          child: const Icon(
                                              Icons.inventory_2_outlined,
                                              color: TColors.primary,
                                              size: 44)),
                                      const SizedBox(height: 18),
                                      Text(
                                          _orders.isEmpty
                                              ? 'Ready for your next order'
                                              : 'No matching orders',
                                          style: const TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 10),
                                      Text(
                                          _orders.isEmpty
                                              ? 'Create an order from your product catalogue. Add quantities and attach the customer’s order proof.'
                                              : 'Try a different search or clear the filters.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: TColors.textSecondary,
                                              height: 1.6)),
                                      if (_orders.isNotEmpty)
                                        TextButton(
                                            onPressed: () => setState(() {
                                                  _search.clear();
                                                  _filter = 'All orders';
                                                }),
                                            child: const Text('Clear filters')),
                                    ])))
                          else
                            SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                    padding, 0, padding, 110),
                                sliver: SliverList.separated(
                                    itemCount: orders.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      final order = orders[index];
                                      return TweenAnimationBuilder<double>(
                                          key: ValueKey(order.localId),
                                          tween: Tween(begin: 0, end: 1),
                                          duration: MediaQuery.disableAnimationsOf(context)
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 300),
                                          builder: (context, value, child) => Opacity(
                                              opacity: value,
                                              child: Transform.translate(
                                                  offset: Offset(
                                                      0, 10 * (1 - value)),
                                                  child: child)),
                                          child: OrderListCard(
                                              order: order,
                                              onView: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => OrderDetailScreen(
                                                          order: order))),
                                              onRetry: _refreshing || _sync?.isRunning == true
                                                  ? null
                                                  : () => _refresh(notify: true)));
                                    })),
                        ]);
                  }))),
        );
      }));

  Widget _header() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
              colors: [TColors.primary_shade700, TColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.local_pharmacy_outlined, size: 20, color: Colors.white70),
          SizedBox(width: 8),
          Text('FIELD ORDERS',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6))
        ]),
        const SizedBox(height: 12),
        const Text('Every order,\nready to move.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                height: 1.2,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const Text('Capture products and quantities, even without internet.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
        const SizedBox(height: 22),
        Wrap(spacing: 30, runSpacing: 16, children: [
          _metric('${_orders.length}', 'On this device'),
          _metric('${_orders.where((o) => o.priority == 'Urgent').length}',
              'Urgent'),
          _metric(
              '${_orders.where((o) => o.syncState == OrderSyncState.failed).length}',
              'Need retry'),
        ]),
      ]));

  Widget _metric(String value, String label) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70))
      ]);
}

class OrderListCard extends StatelessWidget {
  const OrderListCard(
      {super.key, required this.order, required this.onView, this.onRetry});

  final LocalOrder order;
  final VoidCallback onView;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
          onTap: onView,
          borderRadius: BorderRadius.circular(18),
          child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  border: Border.all(color: TColors.borderSecondary),
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(order.reference,
                              style: const TextStyle(
                                  color: TColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                          OrderTag(order.statusLabel,
                              color: order.syncState == OrderSyncState.failed
                                  ? TColors.error
                                  : TColors.info,
                              icon: order.syncState == OrderSyncState.syncing
                                  ? Icons.sync
                                  : Icons.cloud_upload_outlined),
                          if (order.priority == 'Urgent')
                            const OrderTag('Urgent', color: TColors.warning)
                        ]),
                    const SizedBox(height: 14),
                    Text(order.doctorName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                        [
                          order.customerType,
                          if (order.clinicName?.isNotEmpty == true)
                            order.clinicName!,
                          orderDateLabel(order.orderDate)
                        ].join(' · '),
                        style: const TextStyle(
                            fontSize: 12, color: TColors.textSecondary)),
                    const SizedBox(height: 16),
                    Text(
                        order.items
                                .take(2)
                                .map((i) => i.productName)
                                .join(' · ') +
                            (order.items.length > 2
                                ? ' +${order.items.length - 2} more'
                                : ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      OrderTag('${order.items.length} products',
                          icon: Icons.medication_outlined,
                          color: TColors.textSecondary),
                      OrderTag(order.totals.quantityLabel,
                          color: TColors.textSecondary),
                      OrderTag(
                          order.attachmentIsPdf
                              ? 'PDF attached'
                              : 'Image attached',
                          icon: Icons.attach_file,
                          color: TColors.success)
                    ]),
                    if (order.lastError != null &&
                        order.syncState == OrderSyncState.failed)
                      Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(order.lastError!,
                              style: const TextStyle(
                                  fontSize: 12, color: TColors.error),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis)),
                    const Divider(height: 28),
                    Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 20,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(orderMoney(order.totals.totalPaise),
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: TColors.primary_shade700)),
                                Text(
                                    order.totals.fullyPriced
                                        ? 'Estimated value'
                                        : 'Estimate · rates incomplete',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: TColors.textSecondary))
                              ]),
                          Wrap(spacing: 8, children: [
                            if (order.syncState == OrderSyncState.failed)
                              TextButton.icon(
                                  onPressed: onRetry,
                                  icon: const Icon(Icons.sync, size: 16),
                                  label: const Text('Retry uploads')),
                            OutlinedButton.icon(
                                onPressed: onView,
                                icon: const Icon(Icons.arrow_outward_rounded,
                                    size: 16),
                                label: const Text('View order'))
                          ]),
                        ]),
                  ]))));
}
