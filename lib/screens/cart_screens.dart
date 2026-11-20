import 'package:flutter/material.dart';

import '../common.dart';

// ==========================================
// KERANJANG, PEMBAYARAN & STATUS PESANAN (PICKUP)
// ==========================================

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Color(0xFFE7ECE8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF344A3D)),
      ),
    );
  }
}

// ---------- HALAMAN KERANJANG ----------

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cartController,
          builder: (context, _) {
            final items = cartController.items;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: PageHeader(
                    title: 'Keranjang',
                    subtitle: '${cartController.totalItems} menu dipilih',
                    onBack: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 56, color: Color(0xFFBBC3BD)),
                        SizedBox(height: 12),
                        Text(
                          'Keranjang masih kosong',
                          style: TextStyle(fontSize: 14, color: kMuted),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _CartTile(item: items[i]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  decoration: bottomBarDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      infoRow('Subtotal (${items.length} menu)',
                          rupiah(cartController.totalPrice)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kGreen,
                              ),
                            ),
                            Text(
                              rupiah(cartController.totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: kGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: items.isEmpty
                              ? null
                              : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutView(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFD8DED9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bayar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;

  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fastfood_outlined,
                color: Colors.grey.shade400, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.menu.price,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (item.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Catatan: ${item.note}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: kMuted,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _StepButton(
                          icon: item.quantity > 1
                              ? Icons.remove
                              : Icons.delete_outline,
                          onTap: () => cartController.changeQuantity(item, -1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _StepButton(
                          icon: Icons.add,
                          onTap: () => cartController.changeQuantity(item, 1),
                        ),
                      ],
                    ),
                    Text(
                      rupiah(item.subtotal),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- HALAMAN PEMBAYARAN ----------

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  static const Map<String, String> _methods = {
    'QRIS': 'Scan kode QR dari e-wallet atau m-banking',
    'Transfer Bank': 'Transfer ke virtual account bank pilihan',
    'Kartu Kredit': 'Visa atau Mastercard',
  };

  // ASUMSI: waktu ambil minimal 15 menit dari sekarang. Ubah sesuai kebijakan IBC.
  static const int _minLeadMinutes = 15;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TimeOfDay? _pickupTime;
  String _payment = 'QRIS';

  @override
  void initState() {
    super.initState();
    _nameController.text = cartController.customerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isTimeValid(TimeOfDay t) {
    final now = DateTime.now();
    final pickup = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return !pickup.isBefore(now.add(const Duration(minutes: _minLeadMinutes)));
  }

  Future<void> _pickTime() async {
    final soon = DateTime.now().add(const Duration(minutes: _minLeadMinutes));
    final picked = await showTimePicker(
      context: context,
      initialTime:
      _pickupTime ?? TimeOfDay(hour: soon.hour, minute: soon.minute),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    if (!_isTimeValid(picked)) {
      _toast('Waktu pengambilan minimal $_minLeadMinutes menit dari sekarang');
      return;
    }
    setState(() => _pickupTime = picked);
  }

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();

    if (cartController.items.isEmpty) {
      _toast('Keranjang masih kosong');
      return;
    }
    final formOk = _formKey.currentState?.validate() ?? false;
    if (cartController.branch == null) {
      _toast('Pilih cabang pengambilan terlebih dahulu');
      return;
    }
    if (_pickupTime == null) {
      _toast('Pilih waktu pengambilan terlebih dahulu');
      return;
    }
    if (!formOk) return;
    if (!_isTimeValid(_pickupTime!)) {
      setState(() => _pickupTime = null);
      _toast('Waktu pengambilan sudah terlewat, pilih ulang');
      return;
    }

    // Simulasi proses pembayaran. Nanti diganti pemanggilan API pembayaran.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.of(context).pop(); // tutup dialog loading

    final order = cartController.placeOrder(
      customerName: _nameController.text.trim().isEmpty
          ? cartController.customerName
          : _nameController.text.trim(),
      pickupTime: _pickupTime!,
      paymentMethod: _payment,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderStatusView(order: order)),
          (route) => route.isFirst,
    );
  }

  Widget _box({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: kMuted,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final items = cartController.items;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: PageHeader(
                title: 'Pembayaran',
                subtitle: 'Lengkapi data pengambilan pesanan',
                onBack: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  SectionCard(
                    title: 'Data Pengambilan',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Nama pengambil'),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: kGreen),
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').trim().isEmpty) {
                                return 'Nama wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Cabang pengambilan'),
                          ListenableBuilder(
                            listenable: cartController,
                            builder: (context, _) {
                              final branch = cartController.branch;
                              return _box(
                                onTap: () => showBranchPicker(context),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 18, color: kMuted),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        branch ?? 'Pilih cabang',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: branch == null
                                              ? kMuted
                                              : const Color(0xFF26352C),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down,
                                        size: 20, color: kMuted),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _label('Waktu pickup'),
                          _box(
                            onTap: _pickTime,
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 18, color: kMuted),
                                const SizedBox(width: 8),
                                Text(
                                  _pickupTime == null
                                      ? 'Pilih jam pengambilan'
                                      : fmtTime(_pickupTime!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _pickupTime == null
                                        ? kMuted
                                        : const Color(0xFF26352C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pengambilan hari ini, minimal $_minLeadMinutes '
                                'menit dari sekarang.',
                            style: TextStyle(fontSize: 10, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionCard(
                    title: 'Tipe Pembayaran',
                    child: Column(
                      children: _methods.entries.map((e) {
                        final selected = _payment == e.key;
                        return GestureDetector(
                          onTap: () => setState(() => _payment = e.key),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFE7ECE8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? kGreen : kBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF26352C),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        e.value,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: kMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: selected ? kGreen : kMuted,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionCard(
                    title: 'Ringkasan Pesanan',
                    child: Column(
                      children: items
                          .map(
                            (i) => infoRow(
                          '${i.menu.name} ×${i.quantity}',
                          rupiah(i.subtotal),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: bottomBarDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kGreen,
                            ),
                          ),
                          Text(
                            '${cartController.totalItems} menu dipilih',
                            style:
                            const TextStyle(fontSize: 11, color: kMuted),
                          ),
                        ],
                      ),
                      Text(
                        rupiah(cartController.totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Bayar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

// ---------- HALAMAN STATUS PESANAN ----------

class OrderStatusView extends StatelessWidget {
  final PickupOrder order;

  const OrderStatusView({super.key, required this.order});

  void _backToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _stepper(OrderStatus status) {
    const labels = ['Diproses', 'Siap diambil', 'Selesai'];
    return Row(
      children: List.generate(3, (i) {
        final done = i <= status.index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: done ? kGreen : kBorder,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    i == status.index ? FontWeight.w700 : FontWeight.normal,
                    color: done ? kGreen : kMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showReceipt(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Struk Pesanan',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 22,
                      color: kGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: kBorder),
                infoRow('Referensi', order.reference),
                infoRow('Tanggal', fmtDateTime(order.createdAt)),
                infoRow('Cabang', order.branch),
                infoRow('Waktu pickup', fmtTime(order.pickupTime)),
                const Divider(color: kBorder),
                ...order.items.map(orderItemRow),
                const Divider(color: kBorder),
                infoRow('Total', rupiah(order.total)),
                infoRow('Pembayaran', order.paymentMethod),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cartController,
          builder: (context, _) {
            final status = order.status;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: PageHeader(
                    title: 'Status',
                    onBack: () => _backToHome(context),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      _stepper(status),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          status.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Times New Roman',
                            color: kGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          status.hint,
                          textAlign: TextAlign.center,
                          style:
                          const TextStyle(fontSize: 12, color: kMuted),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SectionCard(
                        title: 'Detail',
                        child: Column(
                          children: [
                            infoRow('Referensi', order.reference),
                            infoRow('Nama pengambil', order.customerName),
                            infoRow('Layanan', 'Pick-up'),
                            infoRow('Cabang', order.branch),
                            infoRow('Waktu pickup', fmtTime(order.pickupTime)),
                            infoRow('Status', status.label),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SectionCard(
                        title: 'Pesanan (${order.totalItems} menu)',
                        child: Column(
                          children: [
                            ...order.items.map(orderItemRow),
                            const Divider(color: kBorder),
                            infoRow('Total', rupiah(order.total)),
                          ],
                        ),
                      ),
                      if (status != OrderStatus.diambil)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextButton.icon(
                            // DEMO: pada sistem asli status diubah staf/admin.
                            onPressed: () =>
                                cartController.advanceStatus(order),
                            icon: const Icon(Icons.science_outlined, size: 16),
                            label: const Text(
                              'Simulasi admin: perbarui status',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  decoration: bottomBarDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => _showReceipt(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kGreen,
                            side: const BorderSide(color: kBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Struk'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _backToHome(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
