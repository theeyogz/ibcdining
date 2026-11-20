import 'package:flutter/material.dart';

import '../common.dart';
import 'cart_screens.dart';

// ==========================================
// HALAMAN PROFIL
// ==========================================

class ProfileView extends StatefulWidget {
  static const Color primaryColor = Color(0xFF19352B);

  final DemoUser user;
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late String _userName;
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _userName = widget.user.name;
    _userEmail = widget.user.email;
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content:
          const Text('Apakah Anda yakin ingin keluar dari IBC Dining?'),
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
        );
      },
    );
  }

  void _openEditProfile() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF7F8F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditProfileView(
        initialName: _userName,
        initialEmail: _userEmail,
        onSave: (newName) {
          final cleanedName = newName.trim();
          if (cleanedName.isEmpty) return;
          setState(() {
            _userName = cleanedName;
            widget.user.name = cleanedName;
            cartController.customerName = cleanedName;
          });
        },
      ),
    );
  }

  void _openOrderHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontFamily: 'Times New Roman',
              color: ProfileView.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7ECE8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD7DED9)),
                ),
                child: const Icon(Icons.person_outline,
                    color: ProfileView.primaryColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halo,',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ProfileView.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(_userEmail,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _openEditProfile,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ProfileView.primaryColor,
                  side: const BorderSide(color: Color(0xFFD8DED9)),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600),
                ),
                child: const Text('Edit Profil'),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Akun',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ProfileView.primaryColor),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _openOrderHistory,
            style: OutlinedButton.styleFrom(
              foregroundColor: ProfileView.primaryColor,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD8DED9)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Riwayat Pesanan',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ),
                Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _confirmLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: ProfileView.primaryColor,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD8DED9)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 16),
                SizedBox(width: 10),
                Text('Keluar dari Akun',
                    style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN RIWAYAT PESANAN
// ==========================================

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: kGreen),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Riwayat Pesanan',
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Times New Roman',
                      color: kGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: cartController,
                builder: (context, _) {
                  final orders = cartController.orders;
                  if (orders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Pesanan',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: kGreen),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pesanan yang berhasil dibuat melalui checkout akan muncul di halaman ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      OrderStatusView(order: order)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.receipt_long_outlined,
                                        color: kGreen, size: 19),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        order.reference,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: kGreen),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8EEE9),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        order.status.label,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: kGreen,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(fmtDateTime(order.createdAt),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                                const SizedBox(height: 8),
                                Text(
                                  order.items
                                      .map((item) =>
                                  '${item.quantity}x ${item.menu.name}')
                                      .join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, color: kBorder),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(order.branch,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: kMuted)),
                                          const SizedBox(height: 3),
                                          Text('${order.totalItems} item',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: kMuted)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      rupiah(order.total),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: kGreen),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right,
                                        color: kMuted),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HALAMAN EDIT PROFIL
// ==========================================

class EditProfileView extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final ValueChanged<String> onSave;

  const EditProfileView({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onSave,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        color: const Color(0xFFF7F8F6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF19352B),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Edit Profil',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Times New Roman',
                    color: Color(0xFF19352B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Nama',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF19352B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF19352B),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF19352B)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF19352B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.initialEmail,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_nameController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF19352B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Simpan Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
