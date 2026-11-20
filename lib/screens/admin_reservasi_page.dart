import 'package:flutter/material.dart';
import '../common.dart';

// ==========================================
// 1. MODEL DATA RESERVASI REGULAR
// ==========================================

enum AreaMeja { indoorNonSmoking, indoorSmoking, outdoor }

extension AreaMejaX on AreaMeja {
  String get label {
    switch (this) {
      case AreaMeja.indoorNonSmoking:
        return 'Indoor (Non-Smoking)';
      case AreaMeja.indoorSmoking:
        return 'Indoor (Smoking)';
      case AreaMeja.outdoor:
        return 'Outdoor';
    }
  }

  IconData get icon {
    switch (this) {
      case AreaMeja.indoorNonSmoking:
        return Icons.ac_unit;
      case AreaMeja.indoorSmoking:
        return Icons.smoking_rooms;
      case AreaMeja.outdoor:
        return Icons.deck;
    }
  }
}

enum StatusRegular { menunggu, ditempati }

extension StatusRegularX on StatusRegular {
  String get label {
    switch (this) {
      case StatusRegular.menunggu:
        return 'Menunggu';
      case StatusRegular.ditempati:
        return 'Ditempati';
    }
  }

  Color get color {
    switch (this) {
      case StatusRegular.menunggu:
        return Colors.orange;
      case StatusRegular.ditempati:
        return Colors.blue;
    }
  }
}

class AdminReservasiRegular {
  final String id;
  final String namaPelanggan;
  final String noHp;
  final String tanggal;
  final String jam;
  final int jumlahTamu;
  final AreaMeja areaMeja;
  final String nomorMeja;
  StatusRegular status;

  AdminReservasiRegular({
    required this.id,
    required this.namaPelanggan,
    required this.noHp,
    required this.tanggal,
    required this.jam,
    required this.jumlahTamu,
    required this.areaMeja,
    required this.nomorMeja,
    this.status = StatusRegular.menunggu,
  });
}

// ==========================================
// 2. MODEL DATA RESERVASI EVENT
// ==========================================

enum StatusBayarEvent {
  menungguDP, // 0% DP
  dp50, // DP 50% Berhasil
  lunas100, // Lunas 100%
}

extension StatusBayarEventX on StatusBayarEvent {
  String get label {
    switch (this) {
      case StatusBayarEvent.menungguDP:
        return 'Menunggu DP (0%)';
      case StatusBayarEvent.dp50:
        return 'DP 50% Berhasil';
      case StatusBayarEvent.lunas100:
        return 'Lunas (100%)';
    }
  }

  Color get color {
    switch (this) {
      case StatusBayarEvent.menungguDP:
        return Colors.orange;
      case StatusBayarEvent.dp50:
        return Colors.blue;
      case StatusBayarEvent.lunas100:
        return Colors.green;
    }
  }
}

class AdminReservasiEvent {
  final String id;
  final String namaPemesan;
  final String noHp;
  final String tanggal;
  final String jam;
  final String jenisAcara; // e.g. Ulang Tahun, Gathering, Wedding
  final String ruangan; // e.g. VIP Hall A, Ballroom
  final String paket; // e.g. Buffet Platinum, Corporate Gold
  final int porsi;
  final int totalBill;
  StatusBayarEvent statusBayar;

  AdminReservasiEvent({
    required this.id,
    required this.namaPemesan,
    required this.noHp,
    required this.tanggal,
    required this.jam,
    required this.jenisAcara,
    required this.ruangan,
    required this.paket,
    required this.porsi,
    required this.totalBill,
    this.statusBayar = StatusBayarEvent.menungguDP,
  });

  int get dpAmount => (totalBill * 0.5).round();
  int get sisaBayar =>
      statusBayar == StatusBayarEvent.lunas100 ? 0 : (statusBayar == StatusBayarEvent.dp50 ? dpAmount : totalBill);
}

// ==========================================
// 3. HALAMAN UTAMA RESERVASI ADMIN
// ==========================================

class AdminReservasiPage extends StatefulWidget {
  final String? branch;
  const AdminReservasiPage({super.key, this.branch});

  @override
  State<AdminReservasiPage> createState() => _AdminReservasiPageState();
}

class _AdminReservasiPageState extends State<AdminReservasiPage> {
  // Data Sample Regular
  final List<AdminReservasiRegular> _regularReservations = [
    AdminReservasiRegular(
      id: 'RSV-REG-001',
      namaPelanggan: 'Budi Santoso',
      noHp: '081234567890',
      tanggal: '24 Mei 2024',
      jam: '18:30',
      jumlahTamu: 4,
      areaMeja: AreaMeja.indoorNonSmoking,
      nomorMeja: 'Meja A-04',
      status: StatusRegular.menunggu,
    ),
    AdminReservasiRegular(
      id: 'RSV-REG-002',
      namaPelanggan: 'Siti Aminah',
      noHp: '085712345678',
      tanggal: '24 Mei 2024',
      jam: '19:00',
      jumlahTamu: 2,
      areaMeja: AreaMeja.outdoor,
      nomorMeja: 'Meja OUT-02',
      status: StatusRegular.menunggu,
    ),
    AdminReservasiRegular(
      id: 'RSV-REG-003',
      namaPelanggan: 'Andi Wijaya',
      noHp: '081398765432',
      tanggal: '24 Mei 2024',
      jam: '19:15',
      jumlahTamu: 6,
      areaMeja: AreaMeja.indoorSmoking,
      nomorMeja: 'Meja SMK-01',
      status: StatusRegular.ditempati,
    ),
    AdminReservasiRegular(
      id: 'RSV-REG-004',
      namaPelanggan: 'Dewi Lestari',
      noHp: '082145678901',
      tanggal: '25 Mei 2024',
      jam: '12:30',
      jumlahTamu: 5,
      areaMeja: AreaMeja.indoorNonSmoking,
      nomorMeja: 'Meja A-08',
      status: StatusRegular.menunggu,
    ),
  ];

  // Data Sample Event
  final List<AdminReservasiEvent> _eventReservations = [
    AdminReservasiEvent(
      id: 'RSV-EVT-001',
      namaPemesan: 'PT Jaya Abadi (Bpk. Haryono)',
      noHp: '081122334455',
      tanggal: '28 Mei 2024',
      jam: '18:00 - 21:00',
      jenisAcara: 'Corporate Gathering',
      ruangan: 'VIP Hall Room A',
      paket: 'Paket Buffet Gold',
      porsi: 50,
      totalBill: 7500000,
      statusBayar: StatusBayarEvent.dp50,
    ),
    AdminReservasiEvent(
      id: 'RSV-EVT-002',
      namaPemesan: 'Clarissa & Family',
      noHp: '081987654321',
      tanggal: '01 Jun 2024',
      jam: '11:00 - 15:00',
      jenisAcara: 'Ulang Tahun (Sweet 17)',
      ruangan: 'Main Ballroom',
      paket: 'Paket Party Deluxe',
      porsi: 100,
      totalBill: 15000000,
      statusBayar: StatusBayarEvent.menungguDP,
    ),
    AdminReservasiEvent(
      id: 'RSV-EVT-003',
      namaPemesan: 'Komunitas Kuliner Surabaya',
      noHp: '087766554433',
      tanggal: '05 Jun 2024',
      jam: '16:00 - 20:00',
      jenisAcara: 'Arisan & Gala Dinner',
      ruangan: 'Outdoor Garden Area',
      paket: 'Paket Buffet Silver',
      porsi: 40,
      totalBill: 5000000,
      statusBayar: StatusBayarEvent.lunas100,
    ),
  ];

  // Filters
  String _searchQuery = '';
  AreaMeja? _filterArea;
  StatusRegular? _filterStatusRegular;
  StatusBayarEvent? _filterStatusEvent;

  // Pagination
  int _pageRegular = 0;
  int _pageEvent = 0;
  static const int _perPage = 5;

  List<AdminReservasiRegular> get _filteredRegular {
    return _regularReservations.where((r) {
      final q = _searchQuery.toLowerCase();
      final cocokCari = q.isEmpty ||
          r.namaPelanggan.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q) ||
          r.noHp.contains(q) ||
          r.nomorMeja.toLowerCase().contains(q);

      final cocokArea = _filterArea == null || r.areaMeja == _filterArea;
      final cocokStatus =
          _filterStatusRegular == null || r.status == _filterStatusRegular;

      return cocokCari && cocokArea && cocokStatus;
    }).toList();
  }

  List<AdminReservasiEvent> get _filteredEvent {
    return _eventReservations.where((e) {
      final q = _searchQuery.toLowerCase();
      final cocokCari = q.isEmpty ||
          e.namaPemesan.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          e.jenisAcara.toLowerCase().contains(q) ||
          e.ruangan.toLowerCase().contains(q);

      final cocokStatus =
          _filterStatusEvent == null || e.statusBayar == _filterStatusEvent;

      return cocokCari && cocokStatus;
    }).toList();
  }

  void _konfirmasiDitempati(AdminReservasiRegular r) {
    setState(() {
      r.status = StatusRegular.ditempati;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Konfirmasi Berhasil: Meja ${r.nomorMeja} sudah ditempati oleh ${r.namaPelanggan}.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _konfirmasiSelesai(AdminReservasiRegular r) {
    setState(() {
      _regularReservations.removeWhere((item) => item.id == r.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Meja ${r.nomorMeja} telah dikosongkan. Meja kembali bersih & slot tersedia untuk pelanggan berikutnya!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _updateStatusPembayaran100(AdminReservasiEvent e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Persetujuan Pelunasan (100%)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konfirmasi pelunasan sisa pembayaran untuk acara:'),
            const SizedBox(height: 8),
            Text('• Acara: ${e.jenisAcara}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('• Pemesan: ${e.namaPemesan}'),
            Text('• Total Bill: ${rupiah(e.totalBill)}'),
            Text('• Sudah Dibayar (DP 50%): ${rupiah(e.dpAmount)}'),
            const SizedBox(height: 8),
            Text(
              'Sisa Pembayaran: ${rupiah(e.dpAmount)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kGreen, fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                e.statusBayar = StatusBayarEvent.lunas100;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Persetujuan Admin Berhasil! Status pembayaran ${e.id} diupdate ke Lunas (100%).'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Setuju & Update Lunas (100%)'),
          ),
        ],
      ),
    );
  }

  void _bebaskanRuanganEvent(AdminReservasiEvent e) {
    setState(() {
      _eventReservations.removeWhere((item) => item.id == e.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Acara ${e.jenisAcara} telah selesai. Ruangan ${e.ruangan} & ${e.porsi} porsi telah dibebaskan!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _batalkanEvent(AdminReservasiEvent e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Reservasi Event'),
        content: Text(
            'Apakah Anda yakin ingin membatalkan reservasi event ${e.id} (${e.jenisAcara})? Ruangan ${e.ruangan} akan kembali bebas & tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _eventReservations.removeWhere((item) => item.id == e.id);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Reservasi event ${e.id} dibatalkan. Ruangan ${e.ruangan} kembali bebas & tersedia!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Ya, Batalkan Event'),
          ),
        ],
      ),
    );
  }

  void _lihatDetailEvent(AdminReservasiEvent e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailEventSheet(
        event: e,
        onUpdateLunas: () {
          Navigator.pop(context);
          _updateStatusPembayaran100(e);
        },
        onBatalkan: () {
          Navigator.pop(context);
          _batalkanEvent(e);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ---------- Judul & Tab Bar ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Manajemen Reservasi',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Times New Roman',
                        color: kGreen,
                      ),
                    ),
                    if (widget.branch != null)
                      Chip(
                        avatar: const Icon(Icons.location_on, size: 16, color: kGreen),
                        label: Text(
                          widget.branch!,
                          style: const TextStyle(fontSize: 12, color: kGreen),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: kBorder),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const TabBar(
                  labelColor: kGreen,
                  indicatorColor: kGreen,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(icon: Icon(Icons.table_restaurant), text: 'Reservasi Regular'),
                    Tab(icon: Icon(Icons.celebration), text: 'Reservasi Event'),
                  ],
                ),
              ],
            ),
          ),

          // ---------- Pencarian ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari pemesan, no. reservasi, jenis acara, atau meja...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() {
                _searchQuery = v;
                _pageRegular = 0;
                _pageEvent = 0;
              }),
            ),
          ),

          // ---------- Tab Contents ----------
          Expanded(
            child: TabBarView(
              children: [
                _buildRegularTab(),
                _buildEventTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCapacityBannerRegular() {
    final totalTamuTerisi = _regularReservations
        .where((r) => r.status == StatusRegular.menunggu || r.status == StatusRegular.ditempati)
        .fold<int>(0, (sum, r) => sum + r.jumlahTamu);
    const totalKapasitasKursi = 60;
    final sisaSlotOrang = (totalKapasitasKursi - totalTamuTerisi).clamp(0, totalKapasitasKursi);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECE8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_alt_outlined, color: kGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: kGreen),
                children: [
                  const TextSpan(text: 'Sisa Slot Orang Hari Ini: '),
                  TextSpan(
                    text: '$sisaSlotOrang Slot ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                  ),
                  TextSpan(
                    text: '(Terisi $totalTamuTerisi dari $totalKapasitasKursi Orang)',
                    style: const TextStyle(fontSize: 12, color: kMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCapacityBannerEvent() {
    final activeRooms = _eventReservations.map((e) => e.ruangan).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECE8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.meeting_room_outlined, color: kGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: kGreen),
                children: [
                  const TextSpan(text: 'Ruangan yang sedang digunakan: '),
                  TextSpan(
                    text: activeRooms.isEmpty
                        ? 'Tidak Ada (Semua Ruangan Bebas / Tersedia)'
                        : activeRooms.join(', '),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: activeRooms.isEmpty ? Colors.green : Colors.purple,
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

  // ==========================================
  // TAB 1: RESERVASI REGULAR
  // ==========================================

  Widget _buildRegularTab() {
    final list = _filteredRegular;
    final start = _pageRegular * _perPage;
    final pageItems = start >= list.length
        ? <AdminReservasiRegular>[]
        : list.sublist(start, (start + _perPage).clamp(0, list.length));
    final pageCount = (list.length / _perPage).ceil() == 0 ? 1 : (list.length / _perPage).ceil();

    return Column(
      children: [
        _buildSlotCapacityBannerRegular(),
        // Filter Area & Status
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Text('Area: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              FilterChip(
                label: const Text('Semua'),
                selected: _filterArea == null,
                onSelected: (_) => setState(() => _filterArea = null),
              ),
              const SizedBox(width: 4),
              for (final area in AreaMeja.values)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: FilterChip(
                    label: Text(area.label),
                    selected: _filterArea == area,
                    onSelected: (_) => setState(() => _filterArea = area),
                  ),
                ),
              const SizedBox(width: 12),
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              FilterChip(
                label: const Text('Semua'),
                selected: _filterStatusRegular == null,
                onSelected: (_) => setState(() => _filterStatusRegular = null),
              ),
              const SizedBox(width: 4),
              for (final st in StatusRegular.values)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: FilterChip(
                    label: Text(st.label),
                    selected: _filterStatusRegular == st,
                    onSelected: (_) => setState(() => _filterStatusRegular = st),
                  ),
                ),
            ],
          ),
        ),

        // DataTable Regular
        Expanded(
          child: pageItems.isEmpty
              ? const Center(child: Text('Tidak ada reservasi regular ditemukan'))
              : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DataTable(
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 75,
                      columns: const [
                        DataColumn(label: Text('ID / Meja')),
                        DataColumn(label: Text('Pelanggan')),
                        DataColumn(label: Text('Tanggal & Jam')),
                        DataColumn(label: Text('Area Meja')),
                        DataColumn(label: Text('Tamu')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Aksi Resepsionis')),
                      ],
                      rows: pageItems.map(_buildRegularRow).toList(),
                    ),
                  ),
                ),
        ),

        // Pagination
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _pageRegular > 0 ? () => setState(() => _pageRegular--) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Halaman ${_pageRegular + 1} dari $pageCount'),
              IconButton(
                onPressed: _pageRegular < pageCount - 1
                    ? () => setState(() => _pageRegular++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildRegularRow(AdminReservasiRegular r) {
    return DataRow(cells: [
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.id, style: const TextStyle(fontSize: 11, color: kMuted)),
          Text(r.nomorMeja, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      )),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.namaPelanggan, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(r.noHp, style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
      )),
      DataCell(Text('${r.tanggal}\nJam ${r.jam}')),
      DataCell(Row(
        children: [
          Icon(r.areaMeja.icon, size: 16, color: kGreen),
          const SizedBox(width: 4),
          Text(r.areaMeja.label),
        ],
      )),
      DataCell(Text('${r.jumlahTamu} Tamu')),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: r.status.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            r.status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: r.status.color,
            ),
          ),
        ),
      ),
      DataCell(
        r.status == StatusRegular.menunggu
            ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Konfirmasi Ditempati'),
                onPressed: () => _konfirmasiDitempati(r),
              )
            : ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.exit_to_app, size: 16),
                label: const Text('Selesai / Kosongkan'),
                onPressed: () => _konfirmasiSelesai(r),
              ),
      ),
    ]);
  }

  // ==========================================
  // TAB 2: RESERVASI EVENT
  // ==========================================

  Widget _buildEventTab() {
    final list = _filteredEvent;
    final start = _pageEvent * _perPage;
    final pageItems = start >= list.length
        ? <AdminReservasiEvent>[]
        : list.sublist(start, (start + _perPage).clamp(0, list.length));
    final pageCount = (list.length / _perPage).ceil() == 0 ? 1 : (list.length / _perPage).ceil();

    return Column(
      children: [
        _buildSlotCapacityBannerEvent(),
        // Filter Status Bayar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Text('Status Pembayaran: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              FilterChip(
                label: const Text('Semua'),
                selected: _filterStatusEvent == null,
                onSelected: (_) => setState(() => _filterStatusEvent = null),
              ),
              const SizedBox(width: 4),
              for (final st in StatusBayarEvent.values)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: FilterChip(
                    label: Text(st.label),
                    selected: _filterStatusEvent == st,
                    onSelected: (_) => setState(() => _filterStatusEvent = st),
                  ),
                ),
            ],
          ),
        ),

        // DataTable Event
        Expanded(
          child: pageItems.isEmpty
              ? const Center(child: Text('Tidak ada reservasi event ditemukan'))
              : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DataTable(
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 75,
                      columns: const [
                        DataColumn(label: Text('ID / Pemesan')),
                        DataColumn(label: Text('Jenis Acara & Ruangan')),
                        DataColumn(label: Text('Paket & Porsi')),
                        DataColumn(label: Text('Total Bill')),
                        DataColumn(label: Text('Status Pembayaran')),
                        DataColumn(label: Text('Aksi Resepsionis')),
                        DataColumn(label: Text('Detail')),
                      ],
                      rows: pageItems.map(_buildEventRow).toList(),
                    ),
                  ),
                ),
        ),

        // Pagination
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _pageEvent > 0 ? () => setState(() => _pageEvent--) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Halaman ${_pageEvent + 1} dari $pageCount'),
              IconButton(
                onPressed: _pageEvent < pageCount - 1
                    ? () => setState(() => _pageEvent++)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildEventRow(AdminReservasiEvent e) {
    return DataRow(cells: [
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.id, style: const TextStyle(fontSize: 11, color: kMuted)),
          Text(e.namaPemesan, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(e.noHp, style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
      )),
      DataCell(Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.jenisAcara, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${e.ruangan} • ${e.tanggal}'),
        ],
      )),
      DataCell(Text('${e.paket}\n${e.porsi} Porsi')),
      DataCell(Text(rupiah(e.totalBill), style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: e.statusBayar.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            e.statusBayar.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: e.statusBayar.color,
            ),
          ),
        ),
      ),
      DataCell(
        _buildEventActionButton(e),
      ),
      DataCell(
        IconButton(
          icon: const Icon(Icons.info_outline, color: kGreen),
          tooltip: 'Lihat Detail Event',
          onPressed: () => _lihatDetailEvent(e),
        ),
      ),
    ]);
  }

  Widget _buildEventActionButton(AdminReservasiEvent e) {
    switch (e.statusBayar) {
      case StatusBayarEvent.menungguDP:
        return Row(
          children: [
            const Text(
              'Menunggu DP (0%)',
              style: TextStyle(color: kMuted, fontStyle: FontStyle.italic, fontSize: 12),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
              tooltip: 'Batalkan Event',
              onPressed: () => _batalkanEvent(e),
            ),
          ],
        );

      case StatusBayarEvent.dp50:
        return Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.verified, size: 16),
              label: const Text('Update Ke Lunas 100%'),
              onPressed: () => _updateStatusPembayaran100(e),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
              tooltip: 'Batalkan Event',
              onPressed: () => _batalkanEvent(e),
            ),
          ],
        );

      case StatusBayarEvent.lunas100:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          icon: const Icon(Icons.check_circle_outline, size: 16),
          label: const Text('Selesai'),
          onPressed: () => _bebaskanRuanganEvent(e),
        );
    }
  }
}

/// Modal Detail Reservasi Event
class _DetailEventSheet extends StatelessWidget {
  final AdminReservasiEvent event;
  final VoidCallback onUpdateLunas;
  final VoidCallback onBatalkan;

  const _DetailEventSheet({
    required this.event,
    required this.onUpdateLunas,
    required this.onBatalkan,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.id,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.statusBayar.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.statusBayar.label,
                      style: TextStyle(
                        color: event.statusBayar.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _infoTile('Nama Pemesan / Instansi', event.namaPemesan),
                    _infoTile('No. Telepon / WhatsApp', event.noHp),
                    _infoTile('Jenis Acara', event.jenisAcara),
                    _infoTile('Ruangan Acara', event.ruangan),
                    _infoTile('Waktu Acara', '${event.tanggal} (${event.jam})'),
                    _infoTile('Paket Catering', event.paket),
                    _infoTile('Jumlah Porsi', '${event.porsi} Porsi'),
                    const Divider(height: 24),
                    const Text('Rincian Pembayaran Event:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _rowPrice('Total Bill Acara', rupiah(event.totalBill), isBold: true),
                    _rowPrice('DP 50% Required', rupiah(event.dpAmount)),
                    _rowPrice(
                        'Status DP 50%',
                        event.statusBayar != StatusBayarEvent.menungguDP
                            ? 'LUNAS (Sudah Diterima)'
                            : 'BELUM DIBAYAR',
                        color: event.statusBayar != StatusBayarEvent.menungguDP
                            ? Colors.green
                            : Colors.orange),
                    _rowPrice('Sisa Pelunasan (50%)', rupiah(event.sisaBayar),
                        isBold: true, color: kGreen),
                  ],
                ),
              ),
              const Divider(),
              if (event.statusBayar == StatusBayarEvent.dp50)
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Batalkan'),
                      onPressed: onBatalkan,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.verified),
                        label: const Text('Update Ke Lunas (100%)'),
                        onPressed: onUpdateLunas,
                      ),
                    ),
                  ],
                )
              else if (event.statusBayar == StatusBayarEvent.lunas100)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Selesai'),
                    onPressed: () {
                      Navigator.pop(context);
                      onUpdateLunas();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: kMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _rowPrice(String label, String price, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(price,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
