import 'package:flutter/material.dart';
import '../common.dart';

/// 1. MODEL DATA PELANGGAN

class CustomerOrderHistory {
  final String noPesanan;
  final String tanggal;
  final int total;
  final String status;
  final List<String> items;

  const CustomerOrderHistory({
    required this.noPesanan,
    required this.tanggal,
    required this.total,
    required this.status,
    required this.items,
  });
}

class CustomerReservationHistory {
  final String noReservasi;
  final String tanggal;
  final String jam;
  final int jumlahTamu;
  final String status;
  final String cabang;

  const CustomerReservationHistory({
    required this.noReservasi,
    required this.tanggal,
    required this.jam,
    required this.jumlahTamu,
    required this.status,
    required this.cabang,
  });
}

class AdminCustomer {
  final String id;
  final String nama;
  final String email;
  final String noHp;
  final String tanggalDaftar;
  final List<CustomerOrderHistory> riwayatPesanan;
  final List<CustomerReservationHistory> riwayatReservasi;
  bool isBlocked;

  AdminCustomer({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.tanggalDaftar,
    required this.riwayatPesanan,
    required this.riwayatReservasi,
    this.isBlocked = false,
  });

  int get jumlahPesanan => riwayatPesanan.length;
  int get totalBelanja => riwayatPesanan.fold(0, (sum, item) => sum + item.total);
  int get jumlahReservasi => riwayatReservasi.length;
}

/// 2. HALAMAN UTAMA PELANGGAN (ADMIN)

class AdminPelangganPage extends StatefulWidget {
  const AdminPelangganPage({super.key});

  @override
  State<AdminPelangganPage> createState() => _AdminPelangganPageState();
}

class _AdminPelangganPageState extends State<AdminPelangganPage> {
  // Mock Data Pelanggan
  final List<AdminCustomer> _customers = [
    AdminCustomer(
      id: 'CUST-001',
      nama: 'Budi Santoso',
      email: 'budi.santoso@gmail.com',
      noHp: '081234567890',
      tanggalDaftar: '10 Jan 2024',
      riwayatPesanan: const [
        CustomerOrderHistory(
          noPesanan: 'ORD-001',
          tanggal: '15 Jan 2024',
          total: 51000,
          status: 'Selesai',
          items: ['2x Kopi Susu', '1x Roti Bakar'],
        ),
        CustomerOrderHistory(
          noPesanan: 'ORD-012',
          tanggal: '02 Feb 2024',
          total: 75000,
          status: 'Selesai',
          items: ['2x Nasi Goreng', '2x Es Teh'],
        ),
      ],
      riwayatReservasi: const [
        CustomerReservationHistory(
          noReservasi: 'RSV-001',
          tanggal: '20 Jan 2024',
          jam: '18:00',
          jumlahTamu: 4,
          status: 'Selesai',
          cabang: 'IBC Jemursari-Surabaya',
        ),
      ],
    ),
    AdminCustomer(
      id: 'CUST-002',
      nama: 'Siti Aminah',
      email: 'siti.aminah@yahoo.com',
      noHp: '085712345678',
      tanggalDaftar: '12 Jan 2024',
      riwayatPesanan: const [
        CustomerOrderHistory(
          noPesanan: 'ORD-002',
          tanggal: '18 Jan 2024',
          total: 22000,
          status: 'Selesai',
          items: ['1x Matcha Latte'],
        ),
      ],
      riwayatReservasi: const [
        CustomerReservationHistory(
          noReservasi: 'RSV-004',
          tanggal: '14 Feb 2024',
          jam: '19:30',
          jumlahTamu: 2,
          status: 'Selesai',
          cabang: 'IBC Indragiri-Surabaya',
        ),
      ],
    ),
    AdminCustomer(
      id: 'CUST-003',
      nama: 'Andi Wijaya',
      email: 'andi.wijaya@gmail.com',
      noHp: '081398765432',
      tanggalDaftar: '01 Feb 2024',
      riwayatPesanan: const [
        CustomerOrderHistory(
          noPesanan: 'ORD-003',
          tanggal: '05 Feb 2024',
          total: 62000,
          status: 'Selesai',
          items: ['2x Nasi Goreng', '2x Es Teh'],
        ),
        CustomerOrderHistory(
          noPesanan: 'ORD-018',
          tanggal: '20 Feb 2024',
          total: 45000,
          status: 'Selesai',
          items: ['1x Mie Goreng', '1x Es Teh'],
        ),
      ],
      riwayatReservasi: const [],
    ),
    AdminCustomer(
      id: 'CUST-004',
      nama: 'Dewi Lestari',
      email: 'dewi.lestari@gmail.com',
      noHp: '082145678901',
      tanggalDaftar: '10 Feb 2024',
      riwayatPesanan: const [
        CustomerOrderHistory(
          noPesanan: 'ORD-004',
          tanggal: '12 Feb 2024',
          total: 51000,
          status: 'Selesai',
          items: ['3x Croissant'],
        ),
      ],
      riwayatReservasi: const [
        CustomerReservationHistory(
          noReservasi: 'RSV-008',
          tanggal: '25 Feb 2024',
          jam: '12:00',
          jumlahTamu: 6,
          status: 'Dikonfirmasi',
          cabang: 'IBC Manyar Kartoarjo-Surabaya',
        ),
      ],
    ),
    AdminCustomer(
      id: 'CUST-005',
      nama: 'Rizky Pratama',
      email: 'rizky.pratama@outlook.com',
      noHp: '087811223344',
      tanggalDaftar: '15 Feb 2024',
      isBlocked: true,
      riwayatPesanan: const [
        CustomerOrderHistory(
          noPesanan: 'ORD-005',
          tanggal: '16 Feb 2024',
          total: 32000,
          status: 'Selesai',
          items: ['1x Americano', '2x Donat'],
        ),
      ],
      riwayatReservasi: const [],
    ),
    AdminCustomer(
      id: 'CUST-006',
      nama: 'Maya Putri',
      email: 'maya.putri@gmail.com',
      noHp: '081299887766',
      tanggalDaftar: '20 Feb 2024',
      riwayatPesanan: const [
        CustomerOrderHistory(
          noPesanan: 'ORD-006',
          tanggal: '22 Feb 2024',
          total: 20000,
          status: 'Selesai',
          items: ['1x Mie Goreng'],
        ),
      ],
      riwayatReservasi: const [
        CustomerReservationHistory(
          noReservasi: 'RSV-010',
          tanggal: '01 Mar 2024',
          jam: '19:00',
          jumlahTamu: 3,
          status: 'Dikonfirmasi',
          cabang: 'IBC Veteran-Gresek',
        ),
      ],
    ),
  ];

  String _query = '';
  String _filterStatus = 'Semua'; // Semua, Aktif, Diblokir
  int _page = 0;
  static const int _perPage = 5;

  List<AdminCustomer> get _filtered {
    return _customers.where((c) {
      final q = _query.toLowerCase();
      final cocokCari = q.isEmpty ||
          c.nama.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.noHp.contains(q) ||
          c.id.toLowerCase().contains(q);

      final cocokStatus = _filterStatus == 'Semua' ||
          (_filterStatus == 'Aktif' && !c.isBlocked) ||
          (_filterStatus == 'Diblokir' && c.isBlocked);

      return cocokCari && cocokStatus;
    }).toList();
  }

  int get _pageCount {
    final n = (_filtered.length / _perPage).ceil();
    return n == 0 ? 1 : n;
  }

  List<AdminCustomer> get _pageItems {
    final list = _filtered;
    final start = _page * _perPage;
    if (start >= list.length) return [];
    final end = (start + _perPage).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void _lihatDetail(AdminCustomer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailPelangganSheet(
        customer: customer,
        onToggleBlock: () {
          setState(() {
            customer.isBlocked = !customer.isBlocked;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                customer.isBlocked
                    ? 'Akun ${customer.nama} berhasil diblokir'
                    : 'Blokir akun ${customer.nama} dibuka',
              ),
            ),
          );
        },
        onDelete: () {
          Navigator.pop(context);
          _konfirmasiHapus(customer);
        },
      ),
    );
  }

  void _toggleBlock(AdminCustomer customer) {
    setState(() {
      customer.isBlocked = !customer.isBlocked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          customer.isBlocked
              ? 'Akun ${customer.nama} berhasil diblokir'
              : 'Blokir akun ${customer.nama} telah dibuka',
        ),
      ),
    );
  }

  void _konfirmasiHapus(AdminCustomer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun Pelanggan'),
        content: Text('Apakah Anda yakin ingin menghapus akun ${customer.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _customers.removeWhere((c) => c.id == customer.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Akun ${customer.nama} telah dihapus')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
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
              'Manajemen Pelanggan',
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'Times New Roman',
                color: kGreen,
              ),
            ),
          ),
        ),

        // ---------- Pencarian ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama, email, no. HP, atau ID pelanggan',
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
              _page = 0;
            }),
          ),
        ),

        // ---------- Filter Status ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: ['Semua', 'Aktif', 'Diblokir'].map((status) {
              final selected = _filterStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _filterStatus = status;
                    _page = 0;
                  }),
                ),
              );
            }).toList(),
          ),
        ),

        // ---------- Tabel Pelanggan ----------
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Tidak ada pelanggan ditemukan'))
              : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DataTable(
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 68,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama Pelanggan')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Tanggal Daftar')),
                        DataColumn(label: Text('Pesanan')),
                        DataColumn(label: Text('Total Belanja')),
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

  DataRow _buildRow(AdminCustomer c) {
    return DataRow(cells: [
      DataCell(Text(c.id)),
      DataCell(Text(c.nama, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(c.email)),
      DataCell(Text(c.tanggalDaftar)),
      DataCell(Text('${c.jumlahPesanan} pesanan')),
      DataCell(Text(rupiah(c.totalBelanja))),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.isBlocked
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            c.isBlocked ? 'Diblokir' : 'Aktif',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.isBlocked ? Colors.red : Colors.green,
            ),
          ),
        ),
      ),
      DataCell(
        Row(
          children: [
            TextButton(
              onPressed: () => _lihatDetail(c),
              child: const Text('Detail'),
            ),
            IconButton(
              tooltip: c.isBlocked ? 'Buka Blokir' : 'Blokir Akun',
              icon: Icon(
                c.isBlocked ? Icons.lock_open : Icons.block,
                color: c.isBlocked ? Colors.green : Colors.orange,
                size: 20,
              ),
              onPressed: () => _toggleBlock(c),
            ),
            IconButton(
              tooltip: 'Hapus Akun',
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _konfirmasiHapus(c),
            ),
          ],
        ),
      ),
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

/// Modal Detail Pelanggan (Read-only)
class _DetailPelangganSheet extends StatelessWidget {
  final AdminCustomer customer;
  final VoidCallback onToggleBlock;
  final VoidCallback onDelete;

  const _DetailPelangganSheet({
    required this.customer,
    required this.onToggleBlock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Profil
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: kGreen,
                      child: Text(
                        customer.nama.isNotEmpty
                            ? customer.nama[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.nama,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: kGreen,
                                ),
                          ),
                          Text('${customer.email} • ${customer.noHp}',
                              style: const TextStyle(color: kMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: customer.isBlocked
                            ? Colors.red.withValues(alpha: 0.15)
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        customer.isBlocked ? 'Diblokir' : 'Aktif',
                        style: TextStyle(
                          color: customer.isBlocked ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary Stats
                Row(
                  children: [
                    _statCard('Total Belanja', rupiah(customer.totalBelanja)),
                    const SizedBox(width: 8),
                    _statCard('Pesanan', '${customer.jumlahPesanan}x'),
                    const SizedBox(width: 8),
                    _statCard('Reservasi', '${customer.jumlahReservasi}x'),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Header
                const TabBar(
                  labelColor: kGreen,
                  indicatorColor: kGreen,
                  tabs: [
                    Tab(text: 'Riwayat Pesanan'),
                    Tab(text: 'Riwayat Reservasi'),
                  ],
                ),
                const SizedBox(height: 8),

                // Tab Content (Read-Only)
                Expanded(
                  child: TabBarView(
                    children: [
                      // List Pesanan
                      customer.riwayatPesanan.isEmpty
                          ? const Center(
                              child: Text('Belum ada riwayat pesanan'))
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: customer.riwayatPesanan.length,
                              separatorBuilder: (_, _) => const Divider(),
                              itemBuilder: (_, i) {
                                final order = customer.riwayatPesanan[i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(order.noPesanan,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(rupiah(order.total),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: kGreen)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Tanggal: ${order.tanggal} • Status: ${order.status}'),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Item: ${order.items.join(', ')}',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                      // List Reservasi
                      customer.riwayatReservasi.isEmpty
                          ? const Center(
                              child: Text('Belum ada riwayat reservasi'))
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: customer.riwayatReservasi.length,
                              separatorBuilder: (_, _) => const Divider(),
                              itemBuilder: (_, i) {
                                final rsv = customer.riwayatReservasi[i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(rsv.noReservasi,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text('${rsv.jumlahTamu} Tamu',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: kGreen)),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${rsv.cabang}\n${rsv.tanggal} • Jam ${rsv.jam} • Status: ${rsv.status}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),

                const Divider(),
                // Tombol Aksi Opsional (Blokir / Hapus)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            customer.isBlocked ? Colors.green : Colors.orange,
                        side: BorderSide(
                          color:
                              customer.isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      icon: Icon(
                        customer.isBlocked ? Icons.lock_open : Icons.block,
                        size: 18,
                      ),
                      label: Text(
                        customer.isBlocked ? 'Buka Blokir' : 'Blokir Akun',
                      ),
                      onPressed: onToggleBlock,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Hapus Akun'),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: kMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: kGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
