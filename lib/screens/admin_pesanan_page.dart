import 'package:flutter/material.dart';

/// 1. MODEL DATA

enum AdminOrderStatus { diproses, siapDiambil, diambil }

extension AdminOrderStatusX on AdminOrderStatus {
  String get label {
    switch (this) {
      case AdminOrderStatus.diproses:
        return 'Diproses';
      case AdminOrderStatus.siapDiambil:
        return 'Siap Diambil';
      case AdminOrderStatus.diambil:
        return 'Diambil';
    }
  }

  Color get color {
    switch (this) {
      case AdminOrderStatus.diproses:
        return Colors.orange;
      case AdminOrderStatus.siapDiambil:
        return Colors.blue;
      case AdminOrderStatus.diambil:
        return Colors.green;
    }
  }

  /// Status berikutnya dalam alur pesanan (null jika sudah final).
  AdminOrderStatus? get next {
    switch (this) {
      case AdminOrderStatus.diproses:
        return AdminOrderStatus.siapDiambil;
      case AdminOrderStatus.siapDiambil:
        return AdminOrderStatus.diambil;
      case AdminOrderStatus.diambil:
        return null;
    }
  }

  /// Teks tombol aksi admin.
  String? get actionLabel {
    switch (this) {
      case AdminOrderStatus.diproses:
        return 'Tandai Siap';
      case AdminOrderStatus.siapDiambil:
        return 'Tandai Diambil';
      case AdminOrderStatus.diambil:
        return null;
    }
  }
}

class AdminOrderItem {
  final String nama;
  final int qty;
  final int hargaSatuan;
  final String? catatan;

  const AdminOrderItem({
    required this.nama,
    required this.qty,
    required this.hargaSatuan,
    this.catatan,
  });

  int get subtotal => qty * hargaSatuan;
}

class AdminOrder {
  final String noPesanan;
  final String namaPelanggan;
  final String jamAmbil;
  final String metodeBayar;
  final List<AdminOrderItem> items;
  AdminOrderStatus status;

  AdminOrder({
    required this.noPesanan,
    required this.namaPelanggan,
    required this.jamAmbil,
    required this.metodeBayar,
    required this.items,
    this.status = AdminOrderStatus.diproses,
  });

  int get total => items.fold(0, (sum, item) => sum + item.subtotal);
}

/// Format angka -> "Rp 15.000"
String _rupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

/// 2. HALAMAN ADMIN - PESANAN (PICKUP)

class AdminPesananPage extends StatefulWidget {
  const AdminPesananPage({super.key});

  @override
  State<AdminPesananPage> createState() => _AdminPesananPageState();
}

class _AdminPesananPageState extends State<AdminPesananPage> {
  // Data contoh. Ganti dengan data dari Firebase/API milikmu.
  final List<AdminOrder> _orders = [
    AdminOrder(
      noPesanan: 'ORD-001',
      namaPelanggan: 'Budi Santoso',
      jamAmbil: '10:30',
      metodeBayar: 'QRIS',
      items: const [
        AdminOrderItem(
            nama: 'Kopi Susu',
            qty: 2,
            hargaSatuan: 18000,
            catatan: 'Less sugar'),
        AdminOrderItem(nama: 'Roti Bakar', qty: 1, hargaSatuan: 15000),
      ],
    ),
    AdminOrder(
      noPesanan: 'ORD-002',
      namaPelanggan: 'Siti Aminah',
      jamAmbil: '10:45',
      metodeBayar: 'Tunai',
      status: AdminOrderStatus.siapDiambil,
      items: const [
        AdminOrderItem(
            nama: 'Matcha Latte',
            qty: 1,
            hargaSatuan: 22000,
            catatan: 'Es banyak'),
      ],
    ),
    AdminOrder(
      noPesanan: 'ORD-003',
      namaPelanggan: 'Andi Wijaya',
      jamAmbil: '11:00',
      metodeBayar: 'Transfer',
      status: AdminOrderStatus.diambil,
      items: const [
        AdminOrderItem(nama: 'Nasi Goreng', qty: 2, hargaSatuan: 25000),
        AdminOrderItem(nama: 'Es Teh', qty: 2, hargaSatuan: 6000),
      ],
    ),
    AdminOrder(
      noPesanan: 'ORD-004',
      namaPelanggan: 'Dewi Lestari',
      jamAmbil: '11:15',
      metodeBayar: 'QRIS',
      items: const [
        AdminOrderItem(nama: 'Croissant', qty: 3, hargaSatuan: 17000),
      ],
    ),
    AdminOrder(
      noPesanan: 'ORD-005',
      namaPelanggan: 'Rizky Pratama',
      jamAmbil: '11:30',
      metodeBayar: 'Tunai',
      items: const [
        AdminOrderItem(nama: 'Americano', qty: 1, hargaSatuan: 16000),
        AdminOrderItem(
            nama: 'Donat',
            qty: 2,
            hargaSatuan: 8000,
            catatan: 'Dipisah kemasan'),
      ],
    ),
    AdminOrder(
      noPesanan: 'ORD-006',
      namaPelanggan: 'Maya Putri',
      jamAmbil: '11:45',
      metodeBayar: 'QRIS',
      status: AdminOrderStatus.siapDiambil,
      items: const [
        AdminOrderItem(nama: 'Mie Goreng', qty: 1, hargaSatuan: 20000),
      ],
    ),
    AdminOrder(
      noPesanan: 'ORD-007',
      namaPelanggan: 'Fajar Nugroho',
      jamAmbil: '12:00',
      metodeBayar: 'Transfer',
      items: const [
        AdminOrderItem(nama: 'Latte', qty: 2, hargaSatuan: 20000),
      ],
    ),
  ];

  // State untuk filter, pencarian, dan pagination
  AdminOrderStatus? _statusFilter; // null = semua
  String _query = '';
  int _page = 0;
  static const int _perPage = 5;

  /// Daftar pesanan setelah disaring status + kata kunci.
  List<AdminOrder> get _filtered {
    return _orders.where((o) {
      final cocokStatus = _statusFilter == null || o.status == _statusFilter;
      final q = _query.toLowerCase();
      final cocokCari = q.isEmpty ||
          o.namaPelanggan.toLowerCase().contains(q) ||
          o.noPesanan.toLowerCase().contains(q);
      return cocokStatus && cocokCari;
    }).toList();
  }

  int get _pageCount {
    final n = (_filtered.length / _perPage).ceil();
    return n == 0 ? 1 : n;
  }

  /// Potongan data untuk halaman aktif saja.
  List<AdminOrder> get _pageItems {
    final list = _filtered;
    final start = _page * _perPage;
    if (start >= list.length) return [];
    final end = (start + _perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void _ubahStatus(AdminOrder order) {
    final next = order.status.next;
    if (next == null) return;
    setState(() => order.status = next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${order.noPesanan} → ${next.label}')),
    );
    // TODO: kirim perubahan ke backend (Firestore/API) di sini
    // supaya tampilan user ikut berubah.
  }

  void _lihatDetail(AdminOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailPesananSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _pageItems;

    return Column(
      children: [
        // ---------- Judul ----------
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pesanan (Pickup)',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Times New Roman',
                color: Color(0xFF19352B),
              ),
            ),
          ),
        ),

        // ---------- Pencarian ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama pelanggan / no. pesanan',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() {
              _query = v;
              _page = 0; // kembali ke halaman pertama
            }),
          ),
        ),

        // ---------- Filter status ----------
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _filterChip('Semua', null),
              for (final s in AdminOrderStatus.values) _filterChip(s.label, s),
            ],
          ),
        ),

        // ---------- Tabel pesanan ----------
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Tidak ada pesanan ditemukan'))
              : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DataTable(
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 68,
                      columns: const [
                        DataColumn(label: Text('No. Pesanan')),
                        DataColumn(label: Text('Pelanggan')),
                        DataColumn(label: Text('Jam Ambil')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Bayar')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: items.map(_buildRow).toList(),
                    ),
                  ),
                ),
        ),

        // ---------- Pagination ----------
        _buildPagination(),
      ],
    );
  }

  Widget _filterChip(String label, AdminOrderStatus? status) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() {
          _statusFilter = status;
          _page = 0;
        }),
      ),
    );
  }

  DataRow _buildRow(AdminOrder o) {
    final nextLabel = o.status.actionLabel;
    return DataRow(cells: [
      DataCell(Text(o.noPesanan)),
      DataCell(Text(o.namaPelanggan)),
      DataCell(Text(o.jamAmbil)),
      DataCell(Text(_rupiah(o.total))),
      DataCell(Text(o.metodeBayar)),
      DataCell(_StatusBadge(status: o.status)),
      DataCell(Row(
        children: [
          TextButton(
            onPressed: () => _lihatDetail(o),
            child: const Text('Lihat'),
          ),
          const SizedBox(width: 4),
          // Tombol ubah status: pengganti "Simulasi admin" di sisi user
          nextLabel == null
              ? const Icon(Icons.check_circle, color: Colors.green)
              : ElevatedButton(
                  onPressed: () => _ubahStatus(o),
                  child: Text(nextLabel),
                ),
        ],
      )),
    ]);
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _page > 0 ? () => setState(() => _page--) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Halaman ${_page + 1} dari $_pageCount'),
          IconButton(
            onPressed:
                _page < _pageCount - 1 ? () => setState(() => _page++) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

/// 3. WIDGET PENDUKUNG

class _StatusBadge extends StatelessWidget {
  final AdminOrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Modal detail pesanan (dibuka dari tombol "Lihat")
class _DetailPesananSheet extends StatelessWidget {
  final AdminOrder order;
  const _DetailPesananSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.noPesanan,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                  '${order.namaPelanggan} • Ambil ${order.jamAmbil} • ${order.metodeBayar}'),
              const Divider(height: 24),

              // Daftar item: qty × harga satuan, catatan, subtotal
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: order.items.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (_, i) {
                    final item = order.items[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${item.qty} × ${_rupiah(item.hargaSatuan)}'),
                              if (item.catatan != null &&
                                  item.catatan!.isNotEmpty)
                                Text(
                                  'Catatan: ${item.catatan}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(_rupiah(item.subtotal)),
                      ],
                    );
                  },
                ),
              ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_rupiah(order.total),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
