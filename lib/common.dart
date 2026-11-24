import 'dart:async';

import 'package:flutter/material.dart';

// ==========================================
// COMMON: warna, formatter, model, state, dan komponen bersama
// ==========================================

// ---------- WARNA ----------
const Color kGreen = Color(0xFF19352B);
const Color kBorder = Color(0xFFD8E0DA);
const Color kMuted = Color(0xFF78847B);

// ---------- DAFTAR CABANG ----------
// Catatan: ada typo "Reoad" dan "Tanggerang". Perbaiki di sini saja.
const List<String> ibcBranches = [
  'IBC Jemursari-Surabaya',
  'IBC Indragiri-Surabaya',
  'IBC Manyar Kartoarjo-Surabaya',
  'IBC Pondok Tempoe Doeloe Tegalsari-Surabaya',
  'IBC Pondok Tempoe Doloe-Citraland Surabaya',
  'IBC Veteran-Gresek',
  'IBC Taman Pinang-Sidoarjo',
  'IBC Pondok Tempoe Doeloe-Waru',
  'IBC Malang-Malang',
  'IBC Pandaan-Pandaan',
  'IBC Renon-Denpasar',
  'IBC Pondok Tempoe Doloe-Sunset Reoad Bali',
  'IBC Batam Center-Batam',
  'IBC Harapan Indah- Bekasi',
  'IBC Alam Sutera-Tanggerang',
  'IBC Batu Tulis Pesenongan-Jakarta',
  'IBC Cipete-Jakarta',
  'IBC Letjen Suprapto-Semarang (Kota Lama)',
  'IBC Teuku Umar-Semarang',
  'IBC Jogja Palagan Tentara-DIY',
];

// ---------- FORMATTER ----------
String rupiah(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return 'Rp $buffer';
}

String _two(int n) => n.toString().padLeft(2, '0');

String fmtTime(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)} WIB';

String fmtDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

// ---------- MODEL ----------
class DemoUser {
  String name;
  final String email;
  final String password;

  DemoUser({
    required this.name,
    required this.email,
    required this.password,
  });
}

class ArticleModel {
  final String? imageBadge;
  final String categoryTag;
  final String title;
  final String description;

  ArticleModel({
    this.imageBadge,
    required this.categoryTag,
    required this.title,
    required this.description,
  });
}

final List<ArticleModel> dummyArticles = [
  ArticleModel(
    categoryTag: 'CERITA KULINER',
    title: 'Cita Rasa Cianjur, Tradisi yang Terus Hidup',
    description:
    'IBC mempertahankan warisan kuliner Cianjur dengan menghadirkan cita rasa autentik, kualitas sajian, dan keramahan untuk generasi masa kini.',
  ),
  ArticleModel(
    categoryTag: 'OUTLET BARU',
    title: 'Grand Opening IBC PIK 2',
    description:
    'IBC hadir di kawasan PIK 2, Tangerang, membawa cita rasa khas Cianjur ke outlet baru dengan suasana yang lebih modern.',
  ),
];

class MenuItemModel {
  final String name;
  final String price;
  final int rawPrice; // Digunakan untuk kalkulasi total harga
  final String category;
  final String description;

  MenuItemModel({
    required this.name,
    required this.price,
    required this.rawPrice,
    required this.category,
    required this.description,
  });
}

final List<MenuItemModel> dummyMenu = [
  MenuItemModel(
    name: 'Gurame bakar',
    price: 'Rp 145.000',
    rawPrice: 145000,
    category: 'Makanan',
    description:
    'Ikan gurame segar dibakar dengan bumbu kecap rempah khas Nusantara.',
  ),
  MenuItemModel(
    name: 'Gurame asam manis',
    price: 'Rp 145.000',
    rawPrice: 145000,
    category: 'Makanan',
    description: 'Ikan gurame krispi disiram saus asam manis spesial.',
  ),
  MenuItemModel(
    name: 'Nila pesmol',
    price: 'Rp 145.000',
    rawPrice: 145000,
    category: 'Makanan',
    description: 'Ikan nila dengan kuah kuning pesmol gurih nan aromatik.',
  ),
  MenuItemModel(
    name: 'Nila tim',
    price: 'Rp 145.000',
    rawPrice: 145000,
    category: 'Makanan',
    description: 'Ikan nila dikukus dengan ramuan bumbu jahe dan kecap asin.',
  ),
  MenuItemModel(
    name: 'Udang goreng tepung',
    price: 'Rp 120.000',
    rawPrice: 120000,
    category: 'Camilan',
    description: 'Udang pilihan digoreng balut tepung krispi dan gurih.',
  ),
  MenuItemModel(
    name: 'Ayam goreng (pcs)',
    price: 'Rp 33.000',
    rawPrice: 33000,
    category: 'Makanan',
    description: 'Ayam pejantan goreng empuk berbumbu ungkep tradisional.',
  ),
  MenuItemModel(
    name: 'Nasi Liwet',
    price: 'Rp 55.000',
    rawPrice: 55000,
    category: 'Makanan',
    description: 'Nasi gurih dimasak dengan santan, rempah, dan teri Medan.',
  ),
  MenuItemModel(
    name: 'Es Teh Manis',
    price: 'Rp 15.000',
    rawPrice: 15000,
    category: 'Minuman',
    description: 'Teh melati seduh dingin dengan gula asli.',
  ),
];

// ---------- STATE KERANJANG & PESANAN ----------
class CartItem {
  final MenuItemModel menu;
  int quantity;
  final String note;

  CartItem({required this.menu, this.quantity = 1, this.note = ''});

  int get subtotal => menu.rawPrice * quantity;
}

/// Alur: menungguPembayaran -> diproses -> siapDiambil -> diambil
/// Cabang: menungguPembayaran -> dibatalkan (otomatis jika lewat batas waktu bayar)
enum OrderStatus {
  menungguPembayaran,
  diproses,
  siapDiambil,
  diambil,
  dibatalkan,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.menungguPembayaran => 'Menunggu pembayaran',
    OrderStatus.diproses => 'Pesanan disiapkan',
    OrderStatus.siapDiambil => 'Pesanan siap diambil',
    OrderStatus.diambil => 'Pesanan diambil',
    OrderStatus.dibatalkan => 'Pesanan dibatalkan',
  };

  String get hint => switch (this) {
    OrderStatus.menungguPembayaran =>
    'Scan atau ketuk kode QR sebelum waktu pembayaran habis.',
    OrderStatus.diproses => 'Dapur sedang menyiapkan pesanan Anda.',
    OrderStatus.siapDiambil =>
    'Datang ke restoran dan tunjukkan nomor referensi ke kasir.',
    OrderStatus.diambil => 'Terima kasih sudah memesan di IBC Dining.',
    OrderStatus.dibatalkan =>
    'Pesanan dibatalkan karena pembayaran tidak diselesaikan tepat waktu.',
  };

  /// Posisi pada stepper 3 langkah (Diproses, Siap diambil, Selesai).
  /// -1 = belum ada langkah yang selesai (menunggu bayar / batal).
  int get stepIndex => switch (this) {
    OrderStatus.diproses => 0,
    OrderStatus.siapDiambil => 1,
    OrderStatus.diambil => 2,
    _ => -1,
  };
}

class PickupOrder {
  final String reference;
  final String customerName;
  final String branch;
  final TimeOfDay pickupTime;
  final String paymentMethod;
  final List<CartItem> items;
  final int total;
  final DateTime createdAt;

  /// Batas akhir pembayaran. Lewat dari ini, pesanan otomatis dibatalkan.
  final DateTime payDeadline;
  OrderStatus status;

  PickupOrder({
    required this.reference,
    required this.customerName,
    required this.branch,
    required this.pickupTime,
    required this.paymentMethod,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.payDeadline,
    this.status = OrderStatus.menungguPembayaran,
  });

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
}

class CartController extends ChangeNotifier {
  /// ASUMSI: batas waktu pembayaran 15 menit. Ubah sesuai kebijakan IBC.
  static const Duration paymentTimeout = Duration(minutes: 15);

  final List<CartItem> _items = [];
  final List<PickupOrder> _orders = [];
  String? _branch;

  /// Diisi dari Register/Login supaya nama otomatis terisi.
  String customerName = '';

  List<CartItem> get items => List.unmodifiable(_items);

  /// Riwayat pesanan pickup, terbaru di index 0.
  List<PickupOrder> get orders => List.unmodifiable(_orders);

  String? get branch => _branch;
  int get totalItems => _items.fold(0, (s, i) => s + i.quantity);
  int get totalPrice => _items.fold(0, (s, i) => s + i.subtotal);

  void setBranch(String? value) {
    _branch = value;
    notifyListeners();
  }

  void add(MenuItemModel menu, int qty, String note) {
    final idx =
    _items.indexWhere((i) => i.menu.name == menu.name && i.note == note);
    if (idx >= 0) {
      _items[idx].quantity += qty;
    } else {
      _items.add(CartItem(menu: menu, quantity: qty, note: note));
    }
    notifyListeners();
  }

  void changeQuantity(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) _items.remove(item);
    notifyListeners();
  }

  /// Membuat pesanan berstatus "menunggu pembayaran" dan memasang timer
  /// auto-batal. Timer ada di controller, jadi tetap jalan walau user sudah
  /// keluar dari halaman status.
  PickupOrder placeOrder({
    required String customerName,
    required TimeOfDay pickupTime,
    required String paymentMethod,
  }) {
    final now = DateTime.now();
    final order = PickupOrder(
      reference: 'PU-${now.millisecondsSinceEpoch.toString().substring(7)}',
      customerName: customerName,
      branch: _branch ?? '-',
      pickupTime: pickupTime,
      paymentMethod: paymentMethod,
      items: _items
          .map((i) =>
          CartItem(menu: i.menu, quantity: i.quantity, note: i.note))
          .toList(),
      total: totalPrice,
      createdAt: now,
      payDeadline: now.add(paymentTimeout),
    );
    _orders.insert(0, order);
    _items.clear();
    notifyListeners();

    // Auto-batal jika sampai batas waktu belum dibayar.
    Timer(paymentTimeout, () => cancelIfUnpaid(order));
    return order;
  }

  /// Dipanggil saat pembayaran terkonfirmasi.
  /// DEMO: dipicu ketuk QR. Pada sistem asli, dari callback payment gateway.
  void confirmPayment(PickupOrder order) {
    if (order.status != OrderStatus.menungguPembayaran) return;
    // Cegah bayar setelah lewat batas waktu (timer bisa telat sedikit).
    if (DateTime.now().isAfter(order.payDeadline)) {
      cancelIfUnpaid(order);
      return;
    }
    order.status = OrderStatus.diproses;
    notifyListeners();
  }

  /// Membatalkan pesanan yang belum dibayar. Aman dipanggil berulang.
  void cancelIfUnpaid(PickupOrder order) {
    if (order.status != OrderStatus.menungguPembayaran) return;
    order.status = OrderStatus.dibatalkan;
    notifyListeners();
  }

  /// DEMO: pada sistem asli status diubah staf/admin.
  void advanceStatus(PickupOrder order) {
    if (order.status == OrderStatus.diproses) {
      order.status = OrderStatus.siapDiambil;
    } else if (order.status == OrderStatus.siapDiambil) {
      order.status = OrderStatus.diambil;
    } else {
      return; // menunggu bayar / selesai / batal: tidak bisa dimajukan
    }
    notifyListeners();
  }
}

final CartController cartController = CartController();

// ---------- KOMPONEN BERSAMA ----------
Future<void> showBranchPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih cabang pengambilan',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 20,
                      color: kGreen,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: ibcBranches
                      .map(
                        (b) => ListTile(
                      title: Text(b, style: const TextStyle(fontSize: 13)),
                      trailing: b == cartController.branch
                          ? const Icon(Icons.check, color: kGreen)
                          : null,
                      onTap: () {
                        cartController.setBranch(b);
                        Navigator.pop(sheetContext);
                      },
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  const PageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(Icons.arrow_back, color: kGreen, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Times New Roman',
                  color: kGreen,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 12, color: kMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kGreen,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

Widget infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kMuted)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF26352C),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget orderItemRow(CartItem i) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i.menu.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF26352C),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${i.quantity} × ${rupiah(i.menu.rawPrice)}',
                style: const TextStyle(fontSize: 11, color: kMuted),
              ),
              if (i.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Catatan: ${i.note}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: kMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          rupiah(i.subtotal),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF26352C),
          ),
        ),
      ],
    ),
  );
}

BoxDecoration bottomBarDecoration() => BoxDecoration(
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, -4),
    ),
  ],
);
