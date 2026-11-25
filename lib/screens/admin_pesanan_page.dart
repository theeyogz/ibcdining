import 'dart:math' show min;

import 'package:flutter/material.dart';

// ============================================================
// CATATAN: semua nama selain AdminPesananPage diawali "_"
// (privat). Dart tidak mengizinkan nama privat terlihat di file
// lain, sehingga TIDAK MUNGKIN bentrok dengan common.dart,
// admin_screens.dart, atau file lain di project.
// ============================================================

// ------------------------------------------------------------
// 1. MODEL DATA
// ------------------------------------------------------------

enum _Status {
  sedangDibayar,
  pembayaranBerhasil,
  sedangDiproses,
  pesananSiap,
  diambil,
  dibatalkan,
}

/// Urutan alur normal pesanan (untuk timeline di modal).
const List<_Status> _alur = [
  _Status.sedangDibayar,
  _Status.pembayaranBerhasil,
  _Status.sedangDiproses,
  _Status.pesananSiap,
  _Status.diambil,
];

extension _StatusX on _Status {
  String get label {
    switch (this) {
      case _Status.sedangDibayar:
        return 'Sedang Dibayar';
      case _Status.pembayaranBerhasil:
        return 'Pembayaran Berhasil';
      case _Status.sedangDiproses:
        return 'Sedang Diproses';
      case _Status.pesananSiap:
        return 'Pesanan Siap';
      case _Status.diambil:
        return 'Diambil';
      case _Status.dibatalkan:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case _Status.sedangDibayar:
        return Colors.deepPurple;
      case _Status.pembayaranBerhasil:
        return Colors.teal;
      case _Status.sedangDiproses:
        return Colors.orange;
      case _Status.pesananSiap:
        return Colors.blue;
      case _Status.diambil:
        return Colors.green;
      case _Status.dibatalkan:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case _Status.sedangDibayar:
        return Icons.hourglass_top;
      case _Status.pembayaranBerhasil:
        return Icons.payments_outlined;
      case _Status.sedangDiproses:
        return Icons.soup_kitchen_outlined;
      case _Status.pesananSiap:
        return Icons.shopping_bag_outlined;
      case _Status.diambil:
        return Icons.check_circle_outline;
      case _Status.dibatalkan:
        return Icons.cancel_outlined;
    }
  }

  /// Status berikutnya yang boleh dipilih ADMIN.
  /// sedangDibayar & dibatalkan -> null (diatur otomatis oleh sistem).
  _Status? get next {
    switch (this) {
      case _Status.pembayaranBerhasil:
        return _Status.sedangDiproses;
      case _Status.sedangDiproses:
        return _Status.pesananSiap;
      case _Status.pesananSiap:
        return _Status.diambil;
      default:
        return null;
    }
  }

  String? get actionLabel {
    switch (this) {
      case _Status.pembayaranBerhasil:
        return 'Proses Pesanan';
      case _Status.sedangDiproses:
        return 'Tandai Siap';
      case _Status.pesananSiap:
        return 'Tandai Diambil';
      default:
        return null;
    }
  }
}

class _Item {
  final String nama;
  final int qty;
  final int hargaSatuan;
  final String? catatan;

  const _Item({
    required this.nama,
    required this.qty,
    required this.hargaSatuan,
    this.catatan,
  });

  int get subtotal => qty * hargaSatuan;
}

class _Order {
  final String noPesanan;
  final String namaPelanggan;
  final String jamAmbil;
  final String metodeBayar;
  final List<_Item> items;
  _Status status;

  _Order({
    required this.noPesanan,
    required this.namaPelanggan,
    required this.jamAmbil,
    required this.metodeBayar,
    required this.items,
    required this.status,
  });

  int get total {
    int sum = 0;
    for (final item in items) {
      sum += item.subtotal;
    }
    return sum;
  }
}

/// Format angka menjadi "Rp 15.000"
String _formatRupiah(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

// ------------------------------------------------------------
// 2. HALAMAN ADMIN - PESANAN (PICKUP)
// ------------------------------------------------------------

class AdminPesananPage extends StatefulWidget {
  const AdminPesananPage({super.key});

  @override
  State<AdminPesananPage> createState() => _AdminPesananPageState();
}

class _AdminPesananPageState extends State<AdminPesananPage> {
  // Data contoh. Ganti dengan data dari Firebase/API milikmu.
  final List<_Order> _orders = [
    _Order(
      noPesanan: 'ORD-001',
      namaPelanggan: 'Budi Santoso',
      jamAmbil: '10:30',
      metodeBayar: 'QRIS',
      status: _Status.sedangDibayar,
      items: const [
        _Item(nama: 'Kopi Susu', qty: 2, hargaSatuan: 18000, catatan: 'Less sugar'),
        _Item(nama: 'Roti Bakar', qty: 1, hargaSatuan: 15000),
      ],
    ),
    _Order(
      noPesanan: 'ORD-002',
      namaPelanggan: 'Siti Aminah',
      jamAmbil: '10:45',
      metodeBayar: 'Transfer Bank',
      status: _Status.pembayaranBerhasil,
      items: const [
        _Item(nama: 'Matcha Latte', qty: 1, hargaSatuan: 22000, catatan: 'Es banyak'),
      ],
    ),
    _Order(
      noPesanan: 'ORD-003',
      namaPelanggan: 'Andi Wijaya',
      jamAmbil: '11:00',
      metodeBayar: 'Kartu Kredit',
      status: _Status.diambil,
      items: const [
        _Item(nama: 'Nasi Goreng', qty: 2, hargaSatuan: 25000),
        _Item(nama: 'Es Teh', qty: 2, hargaSatuan: 6000),
      ],
    ),
    _Order(
      noPesanan: 'ORD-004',
      namaPelanggan: 'Dewi Lestari',
      jamAmbil: '11:15',
      metodeBayar: 'QRIS',
      status: _Status.sedangDiproses,
      items: const [
        _Item(nama: 'Croissant', qty: 3, hargaSatuan: 17000),
      ],
    ),
    _Order(
      noPesanan: 'ORD-005',
      namaPelanggan: 'Rizky Pratama',
      jamAmbil: '11:30',
      metodeBayar: 'QRIS',
      status: _Status.sedangDiproses,
      items: const [
        _Item(nama: 'Americano', qty: 1, hargaSatuan: 16000),
        _Item(nama: 'Donat', qty: 2, hargaSatuan: 8000, catatan: 'Dipisah kemasan'),
      ],
    ),
    _Order(
      noPesanan: 'ORD-006',
      namaPelanggan: 'Maya Putri',
      jamAmbil: '11:45',
      metodeBayar: 'Transfer Bank',
      status: _Status.pesananSiap,
      items: const [
        _Item(nama: 'Mie Goreng', qty: 1, hargaSatuan: 20000),
      ],
    ),
    _Order(
      noPesanan: 'ORD-007',
      namaPelanggan: 'Fajar Nugroho',
      jamAmbil: '12:00',
      metodeBayar: 'Kartu Kredit',
      status: _Status.sedangDibayar,
      items: const [
        _Item(nama: 'Latte', qty: 2, hargaSatuan: 20000),
      ],
    ),
    _Order(
      noPesanan: 'ORD-008',
      namaPelanggan: 'Lina Marlina',
      jamAmbil: '12:15',
      metodeBayar: 'QRIS',
      status: _Status.dibatalkan,
      items: const [
        _Item(nama: 'Sandwich', qty: 1, hargaSatuan: 24000),
      ],
    ),
  ];

  _Status? _statusFilter; // null = semua
  String _query = '';
  int _page = 0;
  static const int _perPage = 5;

  List<_Order> get _filtered {
    final q = _query.toLowerCase();
    return _orders.where((o) {
      final cocokStatus = _statusFilter == null || o.status == _statusFilter;
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

  List<_Order> get _pageItems {
    final list = _filtered;
    final start = _page * _perPage;
    if (start >= list.length) return [];
    final end = min(start + _perPage, list.length);
    return list.sublist(start, end);
  }

  int _hitung(_Status? status) {
    if (status == null) return _orders.length;
    int n = 0;
    for (final o in _orders) {
      if (o.status == status) n++;
    }
    return n;
  }

  void _ubahStatus(_Order order) {
    final next = order.status.next;
    if (next == null) return;
    setState(() {
      order.status = next;
      if (_page >= _pageCount) _page = _pageCount - 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${order.noPesanan} → ${next.label}')),
    );
    // TODO: kirim perubahan status ke backend (Firestore/API) di sini
    // supaya tampilan pelanggan ikut berubah.
  }

  void _lihatDetail(_Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailSheet(
        order: order,
        onUbahStatus: () => _ubahStatus(order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _pageItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan (Pickup)')),
      body: Column(
        children: [
          // ---------- Pencarian ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama pelanggan / no. pesanan',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() {
                _query = v;
                _page = 0;
              }),
            ),
          ),

          // ---------- Filter status ----------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _filterChip('Semua', null),
                for (final s in _Status.values) _filterChip(s.label, s),
              ],
            ),
          ),

          // ---------- Tabel ----------
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Tidak ada pesanan ditemukan'))
                : SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
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
          SafeArea(top: false, child: _buildPagination()),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _Status? status) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text('$label (${_hitung(status)})'),
        selected: selected,
        onSelected: (_) => setState(() {
          _statusFilter = status;
          _page = 0;
        }),
      ),
    );
  }

  DataRow _buildRow(_Order o) {
    return DataRow(cells: [
      DataCell(Text(o.noPesanan)),
      DataCell(Text(o.namaPelanggan)),
      DataCell(Text(o.jamAmbil)),
      DataCell(Text(_formatRupiah(o.total))),
      DataCell(Text(o.metodeBayar)),
      DataCell(_StatusBadge(status: o.status)),
      DataCell(Row(
        children: [
          TextButton(
            onPressed: () => _lihatDetail(o),
            child: const Text('Lihat'),
          ),
          const SizedBox(width: 4),
          _AksiStatus(order: o, onUbah: () => _ubahStatus(o)),
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

// ------------------------------------------------------------
// 3. WIDGET PENDUKUNG
// ------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final _Status status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withAlpha(38), // ~15% transparan
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Isi kolom "Aksi": tombol (admin), teks tunggu (sistem), atau ikon final.
class _AksiStatus extends StatelessWidget {
  final _Order order;
  final VoidCallback onUbah;
  const _AksiStatus({required this.order, required this.onUbah});

  @override
  Widget build(BuildContext context) {
    final label = order.status.actionLabel;
    if (label != null) {
      return ElevatedButton(onPressed: onUbah, child: Text(label));
    }
    if (order.status == _Status.diambil) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (order.status == _Status.sedangDibayar) {
      return const Text(
        'Menunggu pelanggan',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }
    return const Text(
      'Batal otomatis',
      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
    );
  }
}

/// Garis waktu alur pesanan (di dalam modal detail).
class _Timeline extends StatelessWidget {
  final _Status status;
  const _Timeline({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == _Status.dibatalkan) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(26), // ~10% transparan
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Pesanan dibatalkan otomatis karena batas waktu pembayaran habis.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    final current = _alur.indexOf(status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _alur.length; i++)
          Expanded(
            child: Column(
              children: [
                Icon(
                  i < current
                      ? Icons.check_circle
                      : (i == current
                      ? Icons.radio_button_checked
                      : Icons.circle_outlined),
                  color: i < current
                      ? Colors.green
                      : (i == current ? _alur[i].color : Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _alur[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                    i == current ? FontWeight.bold : FontWeight.normal,
                    color: i > current ? Colors.grey : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Modal detail pesanan (dibuka dari tombol "Lihat").
class _DetailSheet extends StatelessWidget {
  final _Order order;
  final VoidCallback onUbahStatus;
  const _DetailSheet({required this.order, required this.onUbahStatus});

  @override
  Widget build(BuildContext context) {
    final actionLabel = order.status.actionLabel;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
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
                '${order.namaPelanggan} • Ambil ${order.jamAmbil} • ${order.metodeBayar}',
              ),
              const SizedBox(height: 16),
              _Timeline(status: order.status),
              const Divider(height: 24),

              // Daftar item: qty × harga satuan, catatan, subtotal
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final item = order.items[i];
                    final catatan = item.catatan;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${item.qty} × ${_formatRupiah(item.hargaSatuan)}',
                              ),
                              if (catatan != null && catatan.isNotEmpty)
                                Text(
                                  'Catatan: $catatan',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(_formatRupiah(item.subtotal)),
                      ],
                    );
                  },
                ),
              ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatRupiah(order.total),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              if (actionLabel != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onUbahStatus();
                    },
                    child: Text(actionLabel),
                  ),
                ),
              ],
              const SafeArea(top: false, child: SizedBox(height: 4)),
            ],
          ),
        );
      },
    );
  }
}
