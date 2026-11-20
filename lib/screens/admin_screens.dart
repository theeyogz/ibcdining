import 'dart:math' show Random;
import 'admin_pesanan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admin_artikel_screen.dart';
import 'admin_pelanggan_page.dart';
import 'admin_reservasi_page.dart';

import '../common.dart';

// ==========================================
// AKUN ADMIN (SEMENTARA)
// Nanti diganti pengecekan role ke database (tabel Users, kolom role).
// ==========================================

enum AdminRole { pusat, cabang }

class AdminAccount {
  final String email; // tulis dengan huruf kecil
  final String password;
  final AdminRole role;
  final String? branch; // hanya diisi untuk admin cabang

  const AdminAccount({
    required this.email,
    required this.password,
    required this.role,
    this.branch,
  });

  bool get isPusat => role == AdminRole.pusat;
}

// Nama cabang harus sama persis dengan yang ada di ibcBranches (common.dart).
const List<AdminAccount> adminAccounts = [
  AdminAccount(
    email: 'adminibcdining@gmail.com',
    password: 'admin123',
    role: AdminRole.pusat,
  ),
  AdminAccount(
    email: 'admin.jemursari@gmail.com',
    password: 'cabang123',
    role: AdminRole.cabang,
    branch: 'IBC Jemursari-Surabaya',
  ),
  AdminAccount(
    email: 'admin.cipete@gmail.com',
    password: 'cabang123',
    role: AdminRole.cabang,
    branch: 'IBC Cipete-Jakarta',
  ),
];

AdminAccount? findAdminAccount(String email, String password) {
  final e = email.trim().toLowerCase();
  for (final a in adminAccounts) {
    if (a.email == e && a.password == password) return a;
  }
  return null;
}

// ==========================================
// DATA MENU ADMIN (SEMENTARA, DI MEMORI)
// Awalnya diisi dari dummyMenu. Belum tersambung ke katalog user.
// ==========================================

class AdminMenuItem {
  final int id;
  final String branch;
  String name;
  String category;
  int price;
  String description;
  bool available;

  AdminMenuItem({
    required this.id,
    required this.branch,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.available,
  });
}

class AdminMenuStore extends ChangeNotifier {
  final List<AdminMenuItem> _items = [];
  int _nextId = 1;

  // Setiap cabang awalnya punya salinan menu yang sama dari dummyMenu.
  AdminMenuStore() {
    for (final branch in ibcBranches) {
      for (final m in dummyMenu) {
        _items.add(AdminMenuItem(
          id: _nextId++,
          branch: branch,
          name: m.name,
          category: m.category,
          price: m.rawPrice,
          description: m.description,
          available: true,
        ));
      }
    }
  }

  List<AdminMenuItem> itemsOf(String branch) =>
      _items.where((e) => e.branch == branch).toList();

  void add({
    required String branch,
    required String name,
    required String category,
    required int price,
    required String description,
    required bool available,
  }) {
    _items.add(AdminMenuItem(
      id: _nextId++,
      branch: branch,
      name: name,
      category: category,
      price: price,
      description: description,
      available: available,
    ));
    notifyListeners();
  }

  void update(
      AdminMenuItem item, {
        required String name,
        required String category,
        required int price,
        required String description,
        required bool available,
      }) {
    item.name = name;
    item.category = category;
    item.price = price;
    item.description = description;
    item.available = available;
    notifyListeners();
  }

  void remove(AdminMenuItem item) {
    _items.remove(item);
    notifyListeners();
  }
}

final AdminMenuStore adminMenuStore = AdminMenuStore();

// ==========================================
// KERANGKA ADMIN: SIDEBAR + HEADER
// ==========================================

class AdminShell extends StatefulWidget {
  final AdminAccount account;
  final VoidCallback onLogout;

  const AdminShell({super.key, required this.account, required this.onLogout});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  // Menu Cashflow hanya muncul untuk admin pusat.
  List<(String, IconData)> get _menus => [
    ('Dashboard', Icons.dashboard_outlined),
    ('Menu', Icons.restaurant_menu),
    ('Pesanan', Icons.receipt_long_outlined),
    ('Reservasi', Icons.event_note_outlined),
    ('Artikel & Promo', Icons.campaign_outlined),
    ('Pelanggan', Icons.people_outline),
    if (widget.account.isPusat) ('Cashflow', Icons.payments_outlined),
  ];

  int _index = 0;
  late String _branch;

  @override
  void initState() {
    super.initState();
    // Admin cabang terkunci di cabangnya. Admin pusat mulai dari cabang pertama.
    _branch = widget.account.branch ?? ibcBranches.first;
  }

  void _select(int i, bool wide) {
    setState(() => _index = i);
    if (!wide) Navigator.of(context).pop(); // tutup drawer
  }

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun admin?'),
        content: const Text('Anda akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onLogout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(bool wide) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Text(
                widget.account.isPusat ? 'Admin Pusat' : 'Admin Cabang',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Times New Roman',
                  color: kGreen,
                ),
              ),
            ),
            const Divider(height: 1, color: kBorder),
            const SizedBox(height: 12),
            for (int i = 0; i < _menus.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: Material(
                  color: _index == i ? kGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _select(i, wide),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                      child: Row(
                        children: [
                          Icon(
                            _menus[i].$2,
                            size: 18,
                            color: _index == i ? Colors.white : kMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _menus[i].$1,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                              _index == i ? Colors.white : kGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            const Divider(height: 1, color: kBorder),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akses Administrator',
                    style: TextStyle(fontSize: 11, color: kMuted),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _confirmLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kGreen,
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Keluar'),
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

  Widget _header(bool wide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (!wide)
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: kGreen),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECE8),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kBorder),
              ),
              child: const Icon(Icons.person_outline, color: kGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.account.isPusat
                        ? 'Administrator Pusat'
                        : 'Administrator Cabang',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kGreen,
                    ),
                  ),
                  Text(
                    widget.account.isPusat ? 'Memantau semua cabang' : _branch,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: kMuted),
                  ),
                ],
              ),
            ),
            // Dropdown cabang hanya untuk admin pusat, dan disembunyikan
            // di halaman Cashflow karena halaman itu menampilkan semua cabang.
            if (widget.account.isPusat && _menus[_index].$1 != 'Cashflow')
              SizedBox(
                width: wide ? 300 : 170,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _branch,
                      style: const TextStyle(fontSize: 12, color: kGreen),
                      items: ibcBranches
                          .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _branch = v);
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _page() {
    switch (_index) {
      case 0:
        return AdminDashboardPage(key: ValueKey('dash-$_branch'), branch: _branch);
      case 1:
        return AdminMenuPage(key: ValueKey('menu-$_branch'), branch: _branch);
      case 2:
        return const AdminPesananPage();
      case 3:
        return AdminReservasiPage(key: ValueKey('rsv-$_branch'), branch: _branch);
      case 4:
        return const AdminArtikelPage();
      case 5:
        return const AdminPelangganPage();
      case 6:
        return const AdminCashflowPage();
      default:
        return _AdminPlaceholder(title: _menus[_index].$1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      drawer: wide ? null : Drawer(child: _sidebar(false)),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 240,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: kBorder)),
                ),
                child: _sidebar(true),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _header(wide),
                Expanded(child: _page()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DASHBOARD & PLACEHOLDER
// ==========================================

class AdminDashboardPage extends StatelessWidget {
  final String branch;

  const AdminDashboardPage({super.key, required this.branch});

  Widget _stat(String label, String value, IconData icon, {Color? iconColor}) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? kGreen).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? kGreen, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreen,
                  ),
                ),
                Text(label,
                    style: const TextStyle(fontSize: 12, color: kMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([adminMenuStore, cartController]),
      builder: (context, _) {
        final items = adminMenuStore.itemsOf(branch);
        final available = items.where((e) => e.available).length;
        final isWide = MediaQuery.of(context).size.width >= 900;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Cabang',
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Times New Roman',
                        color: kGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ringkasan data real-time untuk $branch',
                      style: const TextStyle(fontSize: 13, color: kMuted),
                    ),
                  ],
                ),
                Chip(
                  avatar: const Icon(Icons.storefront, size: 16, color: kGreen),
                  label: Text(branch,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kGreen)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: kBorder),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stat Cards Grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _stat('Omset Hari Ini', 'Rp 4.850.000', Icons.payments_outlined,
                    iconColor: Colors.green),
                _stat('Pesanan Pickup', '7 Pesanan', Icons.receipt_long_outlined,
                    iconColor: Colors.orange),
                _stat('Reservasi Regular', '5 Reservasi', Icons.event_seat_outlined,
                    iconColor: Colors.blue),
                _stat('Reservasi Event', '2 Event', Icons.celebration,
                    iconColor: Colors.purple),
                _stat('Total Menu', '${items.length} Menu', Icons.restaurant_menu),
                _stat('Menu Tersedia', '$available Menu', Icons.check_circle_outline,
                    iconColor: Colors.teal),
              ],
            ),
            const SizedBox(height: 24),

            // Section: Status Meja & Area
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.table_restaurant, color: kGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Status Kapasitas Area & Ruangan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _areaStatusTile(
                          'Indoor Non-Smoking', '6 Tersedia', '2 Terisi', Icons.ac_unit),
                      _areaStatusTile('Indoor Smoking', '3 Tersedia', '1 Terisi',
                          Icons.smoking_rooms),
                      _areaStatusTile(
                          'Outdoor Garden', '4 Tersedia', '2 Terisi', Icons.deck),
                      _areaStatusTile(
                          'VIP Hall Room A', 'Dipesan (Event)', '18:00', Icons.meeting_room),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Recent Orders & Recent Reservations
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentOrdersCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRecentReservationsCard()),
                ],
              )
            else ...[
              _buildRecentOrdersCard(),
              const SizedBox(height: 16),
              _buildRecentReservationsCard(),
            ],
          ],
        );
      },
    );
  }

  Widget _areaStatusTile(String title, String status1, String status2, IconData icon) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: kGreen),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status1,
                  style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
              Text(status2,
                  style: const TextStyle(fontSize: 11, color: kMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    final recentOrders = [
      {'id': 'ORD-001', 'nama': 'Budi Santoso', 'jam': '10:30', 'total': 'Rp 51.000', 'status': 'Diproses'},
      {'id': 'ORD-002', 'nama': 'Siti Aminah', 'jam': '10:45', 'total': 'Rp 22.000', 'status': 'Siap Diambil'},
      {'id': 'ORD-003', 'nama': 'Andi Wijaya', 'jam': '11:00', 'total': 'Rp 62.000', 'status': 'Diambil'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Pickup Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGreen),
              ),
              Icon(Icons.shopping_bag_outlined, color: kGreen, size: 20),
            ],
          ),
          const Divider(height: 20),
          for (final o in recentOrders) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(o['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(o['total']!, style: const TextStyle(fontWeight: FontWeight.w600, color: kGreen)),
                ],
              ),
              subtitle: Text('${o['id']} • Ambil Jam ${o['jam']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  o['status']!,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            ),
            if (o != recentOrders.last) const Divider(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentReservationsCard() {
    final recentReservations = [
      {'id': 'RSV-REG-001', 'nama': 'Budi Santoso', 'detail': 'Meja A-04 (4 Tamu)', 'jam': '18:30', 'type': 'Regular'},
      {'id': 'RSV-EVT-001', 'nama': 'PT Jaya Abadi', 'detail': 'VIP Hall (50 Porsi)', 'jam': '18:00', 'type': 'Event'},
      {'id': 'RSV-REG-003', 'nama': 'Andi Wijaya', 'detail': 'Meja SMK-01 (6 Tamu)', 'jam': '19:15', 'type': 'Regular'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reservasi Hari Ini',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGreen),
              ),
              Icon(Icons.event_note_outlined, color: kGreen, size: 20),
            ],
          ),
          const Divider(height: 20),
          for (final r in recentReservations) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: r['type'] == 'Event' ? Colors.purple.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      r['type']!,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: r['type'] == 'Event' ? Colors.purple : Colors.blue),
                    ),
                  ),
                ],
              ),
              subtitle: Text('${r['id']} • ${r['detail']}'),
              trailing: Text(r['jam']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kGreen)),
            ),
            if (r != recentReservations.last) const Divider(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AdminPlaceholder extends StatelessWidget {
  final String title;

  const _AdminPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Halaman $title',
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'Times New Roman',
                color: kGreen,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum tersedia. Menunggu desain dan integrasi database.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CASHFLOW (KHUSUS ADMIN PUSAT)
// Data pendapatan harian per cabang.
// SEMENTARA memakai data contoh. Nanti ganti isi revenueOf() dengan
// total pesanan per cabang per hari dari database / cartController.orders.
// ==========================================

class CashflowStore {
  int revenueOf(String branch, DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final seed =
        ibcBranches.indexOf(branch) * 100000 + d.year * 372 + d.month * 31 + d.day;
    final r = Random(seed);
    final base = d.weekday >= 6 ? 4500000 : 3000000;
    return ((base + r.nextInt(2000000)) ~/ 1000) * 1000;
  }
}

final CashflowStore cashflowStore = CashflowStore();

String _rp(int v) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp ${v < 0 ? '-' : ''}$buf';
}

String _dateLabel(DateTime d) {
  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}

class AdminCashflowPage extends StatefulWidget {
  const AdminCashflowPage({super.key});

  @override
  State<AdminCashflowPage> createState() => _AdminCashflowPageState();
}

class _AdminCashflowPageState extends State<AdminCashflowPage> {
  int _range = 7;

  Widget _stat(String label, String value, IconData icon) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kGreen,
                  ),
                ),
                Text(label,
                    style: const TextStyle(fontSize: 12, color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = [
      for (int i = 0; i < _range; i++)
        DateTime(today.year, today.month, today.day - i),
    ];

    final branchTotals = <String, int>{
      for (final b in ibcBranches)
        b: dates.fold<int>(0, (sum, d) => sum + cashflowStore.revenueOf(b, d)),
    };
    final grandTotal = branchTotals.values.fold<int>(0, (a, b) => a + b);
    final todayTotal = ibcBranches.fold<int>(
        0, (sum, b) => sum + cashflowStore.revenueOf(b, dates.first));
    final topBranch = branchTotals.entries
        .reduce((a, b) => a.value >= b.value ? a : b);
    final maxBranch = topBranch.value == 0 ? 1 : topBranch.value;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Cashflow',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Times New Roman',
            color: kGreen,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pendapatan harian seluruh cabang',
          style: TextStyle(fontSize: 13, color: kMuted),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final r in const [7, 14, 30])
              ChoiceChip(
                label: Text('$r hari'),
                selected: _range == r,
                onSelected: (_) => setState(() => _range = r),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _stat('Pendapatan hari ini (semua cabang)', _rp(todayTotal),
                Icons.today_outlined),
            _stat('Total $_range hari terakhir', _rp(grandTotal),
                Icons.account_balance_wallet_outlined),
            _stat('Rata-rata per hari', _rp(grandTotal ~/ _range),
                Icons.trending_up),
            _stat('Cabang tertinggi', topBranch.key, Icons.emoji_events_outlined),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Total per cabang',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: kGreen),
        ),
        const SizedBox(height: 10),
        for (final e in branchTotals.entries)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e.key,
                          style: const TextStyle(
                              fontSize: 13, color: kGreen)),
                    ),
                    Text(_rp(e.value),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kGreen)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: e.value / maxBranch,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE7ECE8),
                    color: kGreen,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        const Text(
          'Pendapatan per hari',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: kGreen),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 56,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 44,
              columns: [
                const DataColumn(label: Text('Tanggal')),
                for (final b in ibcBranches)
                  DataColumn(
                    numeric: true,
                    label: SizedBox(
                      width: 130,
                      child: Text(b, textAlign: TextAlign.right),
                    ),
                  ),
                const DataColumn(numeric: true, label: Text('Total')),
              ],
              rows: [
                for (final d in dates)
                  DataRow(cells: [
                    DataCell(Text(_dateLabel(d))),
                    for (final b in ibcBranches)
                      DataCell(Text(_rp(cashflowStore.revenueOf(b, d)))),
                    DataCell(Text(
                      _rp(ibcBranches.fold<int>(
                          0, (s, b) => s + cashflowStore.revenueOf(b, d))),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// KELOLA MENU
// ==========================================

class AdminMenuPage extends StatefulWidget {
  final String branch;

  const AdminMenuPage({super.key, required this.branch});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  static const List<String> _categories = ['Makanan', 'Minuman', 'Camilan'];
  static const int _perPage = 8;

  // Lebar kolom tabel
  static const double _wNo = 56;
  static const double _wCat = 120;
  static const double _wPrice = 130;
  static const double _wStatus = 140;
  static const double _wAction = 240;

  final _search = TextEditingController();
  String _category = 'Semua';
  String _status = 'Semua';
  int _page = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AdminMenuItem> _filtered() {
    final q = _search.text.trim().toLowerCase();
    return adminMenuStore.itemsOf(widget.branch).where((m) {
      if (q.isNotEmpty && !m.name.toLowerCase().contains(q)) return false;
      if (_category != 'Semua' && m.category != _category) return false;
      if (_status == 'Tersedia' && !m.available) return false;
      if (_status == 'Disembunyikan' && m.available) return false;
      return true;
    }).toList();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openForm({AdminMenuItem? item}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _MenuFormDialog(item: item, branch: widget.branch),
    );
    if (saved == true) {
      _toast(item == null ? 'Menu berhasil ditambahkan' : 'Menu berhasil diubah');
    }
  }

  void _openDetail(AdminMenuItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              infoRow('Kategori', item.category),
              infoRow('Harga satuan', rupiah(item.price)),
              infoRow('Status', item.available ? 'Tersedia' : 'Disembunyikan'),
              infoRow('Deskripsi', item.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AdminMenuItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus menu?'),
        content: Text('Menu "${item.name}" akan dihapus dari daftar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              adminMenuStore.remove(item);
              _toast('Menu berhasil dihapus');
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ---------- komponen kecil ----------

  Widget _filterBox({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kMuted)),
        const SizedBox(height: 4),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorder),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        style: const TextStyle(fontSize: 12, color: kGreen),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _statusChip(bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: available ? kGreen : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: available ? kGreen : kMuted),
      ),
      child: Text(
        available ? 'Tersedia' : 'Disembunyikan',
        style: TextStyle(
          fontSize: 10,
          color: available ? Colors.white : kMuted,
        ),
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap, {Color? color}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(56, 30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: color ?? kGreen,
        side: const BorderSide(color: kBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(fontSize: 11),
      ),
      child: Text(label),
    );
  }

  Widget _headCell(String text, {double? width}) {
    final t = Text(
      text,
      style: const TextStyle(fontSize: 11, color: kMuted),
    );
    return width == null
        ? Expanded(child: t)
        : SizedBox(width: width, child: t);
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          _headCell('No.', width: _wNo),
          _headCell('Nama menu'),
          _headCell('Kategori', width: _wCat),
          _headCell('Harga satuan', width: _wPrice),
          _headCell('Status', width: _wStatus),
          _headCell('Aksi', width: _wAction),
        ],
      ),
    );
  }

  Widget _tableRow(int number, AdminMenuItem m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _wNo,
            child: Text(
              number.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 12, color: kGreen),
            ),
          ),
          Expanded(
            child: Text(
              m.name,
              style: const TextStyle(fontSize: 12, color: kGreen),
            ),
          ),
          SizedBox(
            width: _wCat,
            child: Text(m.category,
                style: const TextStyle(fontSize: 12, color: kGreen)),
          ),
          SizedBox(
            width: _wPrice,
            child: Text(rupiah(m.price),
                style: const TextStyle(fontSize: 12, color: kGreen)),
          ),
          SizedBox(
            width: _wStatus,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusChip(m.available),
            ),
          ),
          SizedBox(
            width: _wAction,
            child: Row(
              children: [
                _actionBtn('Lihat', () => _openDetail(m)),
                const SizedBox(width: 6),
                _actionBtn('Edit', () => _openForm(item: m)),
                const SizedBox(width: 6),
                _actionBtn('Hapus', () => _confirmDelete(m),
                    color: Colors.red.shade700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminMenuStore,
      builder: (context, _) {
        final all = _filtered();
        final pageCount = (all.length / _perPage).ceil().clamp(1, 9999);
        if (_page >= pageCount) _page = pageCount - 1;
        final start = _page * _perPage;
        final end = (start + _perPage).clamp(0, all.length);
        final rows = all.sublist(start, end);

        return LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 700;

            final searchField = _filterBox(
              label: 'Cari menu',
              child: TextField(
                controller: _search,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'cari',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (_) => setState(() => _page = 0),
              ),
            );
            final categoryField = _filterBox(
              label: 'Kategori',
              child: _dropdown(
                value: _category,
                items: ['Semua', ..._categories],
                onChanged: (v) => setState(() {
                  _category = v;
                  _page = 0;
                }),
              ),
            );
            final statusField = _filterBox(
              label: 'Status',
              child: _dropdown(
                value: _status,
                items: const ['Semua', 'Tersedia', 'Disembunyikan'],
                onChanged: (v) => setState(() {
                  _status = v;
                  _page = 0;
                }),
              ),
            );

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Menu',
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Times New Roman',
                              color: kGreen,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tambah, lihat, ubah, dan hapus menu restoran.',
                            style: TextStyle(fontSize: 12, color: kMuted),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _openForm(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (narrow) ...[
                  searchField,
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: categoryField),
                      const SizedBox(width: 10),
                      Expanded(child: statusField),
                    ],
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(flex: 3, child: searchField),
                      const SizedBox(width: 12),
                      Expanded(child: categoryField),
                      const SizedBox(width: 12),
                      Expanded(child: statusField),
                    ],
                  ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Daftar menu ${widget.branch} (${adminMenuStore.itemsOf(widget.branch).length} total)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kGreen,
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: kBorder),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: constraints.maxWidth - 50 < 820
                              ? 820
                              : constraints.maxWidth - 50,
                          child: Column(
                            children: [
                              _tableHeader(),
                              if (rows.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    'Tidak ada menu yang cocok.',
                                    style:
                                    TextStyle(fontSize: 12, color: kMuted),
                                  ),
                                )
                              else
                                for (int i = 0; i < rows.length; i++)
                                  _tableRow(start + i + 1, rows[i]),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 10,
                          spacing: 16,
                          children: [
                            Text(
                              all.isEmpty
                                  ? 'Menampilkan 0 dari 0 menu'
                                  : 'Menampilkan ${start + 1}-$end dari ${all.length} menu',
                              style: const TextStyle(
                                  fontSize: 11, color: kMuted),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '$_perPage per halaman',
                                  style:
                                  TextStyle(fontSize: 11, color: kMuted),
                                ),
                                const SizedBox(width: 12),
                                _actionBtn(
                                  'Sebelumnya',
                                  _page > 0
                                      ? () => setState(() => _page--)
                                      : () {},
                                  color: _page > 0 ? kGreen : kMuted,
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: kGreen,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${_page + 1}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _actionBtn(
                                  'Berikutnya',
                                  _page < pageCount - 1
                                      ? () => setState(() => _page++)
                                      : () {},
                                  color:
                                  _page < pageCount - 1 ? kGreen : kMuted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ==========================================
// FORM TAMBAH / EDIT MENU
// ==========================================

class _MenuFormDialog extends StatefulWidget {
  final AdminMenuItem? item;
  final String branch;

  const _MenuFormDialog({this.item, required this.branch});

  @override
  State<_MenuFormDialog> createState() => _MenuFormDialogState();
}

class _MenuFormDialogState extends State<_MenuFormDialog> {
  static const List<String> _categories = ['Makanan', 'Minuman', 'Camilan'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _desc;
  late String _category;
  late bool _available;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _name = TextEditingController(text: it?.name ?? '');
    _price = TextEditingController(text: it == null ? '' : '${it.price}');
    _desc = TextEditingController(text: it?.description ?? '');
    _category = it?.category ?? _categories.first;
    _available = it?.available ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _name.text.trim();
    final price = int.parse(_price.text.trim());
    final desc = _desc.text.trim();

    final it = widget.item;
    if (it == null) {
      adminMenuStore.add(
        branch: widget.branch,
        name: name,
        category: _category,
        price: price,
        description: desc,
        available: _available,
      );
    } else {
      adminMenuStore.update(
        it,
        name: name,
        category: _category,
        price: price,
        description: desc,
        available: _available,
      );
    }
    Navigator.pop(context, true);
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Tambah Menu' : 'Edit Menu'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: _dec('Nama menu'),
                  validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Nama menu wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: _dec('Kategori'),
                  items: _categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dec('Harga satuan (Rp)'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Harga harus lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: _dec('Deskripsi'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tersedia', style: TextStyle(fontSize: 13)),
                  subtitle: const Text(
                    'Matikan untuk menyembunyikan menu',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
