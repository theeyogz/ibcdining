import 'package:flutter/material.dart';

import '../common.dart';

// ==========================================
// HALAMAN RESERVASI (REGULAR + BOOKING EVENT)
// ==========================================

class EventRoom {
  final String name;
  final int minCap;
  final int maxCap;

  const EventRoom(this.name, this.minCap, this.maxCap);

  String get label => '$name ($minCap-$maxCap org)';
}

class EventPackage {
  final String name;
  final int pricePerPax;

  const EventPackage(this.name, this.pricePerPax);

  String get label => '$name · ${rupiah(pricePerPax)}/pax';
}

// ==========================================
// SLOT KAPASITAS RESERVASI REGULAR (SEMENTARA, DI MEMORI)
// Kapasitas dihitung dalam jumlah orang, per cabang + tanggal + jam + area.
// Setiap reservasi mengurangi sisa kapasitas sebesar jumlah tamunya.
// Nanti ganti dengan data dari database (tabel reservasi).
// ==========================================

class RegularSlotStore {
  // TODO: placeholder, ganti dengan kapasitas asli tiap area.
  static const Map<String, int> areaCapacity = {
    'Indoor (Non-Smoking)': 40,
    'Indoor (Smoking)': 20,
    'Outdoor': 30,
  };

  final Map<String, int> _booked = {};

  static const int closeHour = 22; // restoran tutup jam 22.00
  static const int holdHours = 2; // kursi ditahan 2 jam

  // Slot dihitung per jam. Reservasi jam 21.xx menahan kursi di jam 21 dan 22
  // (jam yang sudah lewat jam tutup tidak dihitung).
  Iterable<String> _heldKeys(
      String branch, DateTime date, TimeOfDay time, String area) sync* {
    for (int h = time.hour; h < time.hour + holdHours && h < closeHour; h++) {
      yield '$branch|${date.year}-${date.month}-${date.day}|$h|$area';
    }
  }

  int capacityOf(String area) => areaCapacity[area] ?? 0;

  // Sisa kapasitas = kapasitas dikurangi jam terpadat di antara jam yang ditahan.
  int remaining(String branch, DateTime date, TimeOfDay time, String area) {
    int busiest = 0;
    for (final k in _heldKeys(branch, date, time, area)) {
      final used = _booked[k] ?? 0;
      if (used > busiest) busiest = used;
    }
    final left = capacityOf(area) - busiest;
    return left < 0 ? 0 : left;
  }

  void book(String branch, DateTime date, TimeOfDay time, String area,
      int guests) {
    for (final k in _heldKeys(branch, date, time, area)) {
      _booked[k] = (_booked[k] ?? 0) + guests;
    }
  }
}

final RegularSlotStore regularSlotStore = RegularSlotStore();

class ReservasiView extends StatefulWidget {
  const ReservasiView({super.key});

  @override
  State<ReservasiView> createState() => _ReservasiViewState();
}

class _ReservasiViewState extends State<ReservasiView> {
  static const Color primaryColor = Color(0xFF19352B);
  static const Color textColor = Color(0xFF26352C);
  static const Color mutedColor = Color(0xFF78847B);
  static const Color borderColor = Color(0xFFD8E0DA);

  bool isBookingEvent = false;

  static const int _minGuests = 2;
  static const int _maxGuests = 10;
  static const int _guestStep = 2; // jumlah tamu regular harus genap

  // Daftar cabang diambil dari common.dart (ibcBranches)
  final List<String> _locations = ibcBranches;

  final List<String> _tableAreas = [
    'Indoor (Non-Smoking)',
    'Indoor (Smoking)',
    'Outdoor',
  ];

  String? _selectedLocation;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestCount = _minGuests;
  String? _selectedArea;

  // Sisa kapasitas slot regular. Null jika lokasi/tanggal/waktu/area belum lengkap.
  int? get _slotRemaining {
    final loc = _selectedLocation;
    final date = _selectedDate;
    final time = _selectedTime;
    final area = _selectedArea;
    if (loc == null || date == null || time == null || area == null) {
      return null;
    }
    return regularSlotStore.remaining(loc, date, time, area);
  }

  // Batas atas jumlah tamu: maksimal per reservasi atau sisa slot (yang lebih kecil).
  int get _guestLimit {
    final left = _slotRemaining;
    if (left == null) return _maxGuests;
    final evenLeft = left - (left % _guestStep); // bulatkan turun ke genap
    return evenLeft < _maxGuests ? evenLeft : _maxGuests;
  }

  // ---------- Booking Event (Private) ----------
  static const int _eventMinGuests = 30;
  static const int _eventMaxGuests = 100;
  static const int _eventPortionStep = 5;
  static const int _eventMinLeadDays = 3; // asumsi: DP 24 jam + pelunasan H-1

  final List<String> _eventTypes = [
    'Ulang Tahun',
    'Sangjit',
    'Tea Pai',
    'Pertemuan / Meeting',
    'Lainnya',
  ];

  // TODO: placeholder, ganti dengan data ruangan asli per cabang.
  final List<EventRoom> _eventRooms = const [
    EventRoom('Ruang Meeting', 30, 40),
    EventRoom('Ruang VIP', 30, 50),
    EventRoom('Ruang Pendopo', 50, 100),
  ];

  // TODO: placeholder, ganti dengan paket & harga asli.
  final List<EventPackage> _eventPackages = const [
    EventPackage('Paket Silver', 85000),
    EventPackage('Paket Gold', 110000),
    EventPackage('Paket Platinum', 150000),
  ];

  String? _eventLocation;
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  String? _eventType;
  EventRoom? _eventRoom;
  EventPackage? _eventPackage;
  int _eventPortions = _eventMinGuests;
  final TextEditingController _eventNoteController = TextEditingController();

  @override
  void dispose() {
    _eventNoteController.dispose();
    super.dispose();
  }

  int get _eventPortionMin => _eventRoom?.minCap ?? _eventMinGuests;
  int get _eventPortionMax => _eventRoom?.maxCap ?? _eventMaxGuests;
  bool get _eventPortionActive => _eventRoom != null && _eventPackage != null;
  int get _eventTotal => (_eventPackage?.pricePerPax ?? 0) * _eventPortions;
  int get _eventDp => _eventTotal ~/ 2;

  void _selectEventRoom(EventRoom room) {
    setState(() {
      _eventRoom = room;
      if (_eventPortions < room.minCap) _eventPortions = room.minCap;
      if (_eventPortions > room.maxCap) _eventPortions = room.maxCap;
    });
  }

  void _changeEventPortions(int delta) {
    setState(() {
      var next = _eventPortions + delta;
      if (next < _eventPortionMin) next = _eventPortionMin;
      if (next > _eventPortionMax) next = _eventPortionMax;
      _eventPortions = next;
    });
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: _eventMinLeadDays));
    final current = _eventDate;
    final picked = await showDatePicker(
      context: context,
      initialDate:
      (current != null && !current.isBefore(first)) ? current : first,
      firstDate: first,
      lastDate: first.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _pickEventTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked != null) {
      setState(() => _eventTime = picked);
    }
  }

  void _resetEventForm() {
    setState(() {
      _eventLocation = null;
      _eventDate = null;
      _eventTime = null;
      _eventType = null;
      _eventRoom = null;
      _eventPackage = null;
      _eventPortions = _eventMinGuests;
      _eventNoteController.clear();
    });
  }

  void _confirmEvent() {
    FocusScope.of(context).unfocus();

    final missing = <String>[];
    if (_eventLocation == null) missing.add('lokasi');
    if (_eventDate == null) missing.add('tanggal');
    if (_eventTime == null) missing.add('waktu');
    if (_eventType == null) missing.add('jenis acara');
    if (_eventRoom == null) missing.add('ruangan');
    if (_eventPackage == null) missing.add('paket makanan');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Lengkapi dulu: ${missing.join(', ')}')),
        );
      return;
    }

    final code =
        'EVT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final note = _eventNoteController.text.trim();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.hourglass_top_rounded,
                    size: 44, color: primaryColor),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Pengajuan Reservasi Event',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 22,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Kode: $code',
                  style: const TextStyle(fontSize: 12, color: mutedColor),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: borderColor),
              _ticketRow('Status', 'Menunggu persetujuan restoran'),
              _ticketRow('Lokasi', _eventLocation!),
              _ticketRow('Tanggal', _formatDate(_eventDate!)),
              _ticketRow('Waktu', _formatTime(_eventTime!)),
              _ticketRow('Jenis acara', _eventType!),
              _ticketRow('Ruangan', _eventRoom!.name),
              _ticketRow('Paket', _eventPackage!.name),
              _ticketRow('Jumlah porsi', '$_eventPortions porsi'),
              if (note.isNotEmpty) _ticketRow('Catatan', note),
              const Divider(color: borderColor),
              _ticketRow('Total estimasi', rupiah(_eventTotal)),
              _ticketRow('DP 50%', rupiah(_eventDp)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7ECE8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Restoran akan memeriksa permintaan Anda. Jika disetujui, '
                      'DP 50% dibayar maksimal 24 jam setelah konfirmasi. '
                      'Pelunasan paling lambat H-1 acara. Pengingat dikirim '
                      'pada H-2 dan H-1.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.45,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) _resetEventForm();
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')} WIB';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked == null) return;

    // Restoran tutup jam 22.00, jadi jam itu ke atas tidak bisa dipesan.
    if (picked.hour >= RegularSlotStore.closeHour) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
                'Restoran tutup pukul 22.00. Pilih waktu sebelum jam tersebut.'),
          ),
        );
      return;
    }
    setState(() => _selectedTime = picked);
  }

  void _confirmRegular() {
    final missing = <String>[];
    if (_selectedLocation == null) missing.add('lokasi');
    if (_selectedDate == null) missing.add('tanggal');
    if (_selectedTime == null) missing.add('waktu');
    if (_selectedArea == null) missing.add('area meja');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Lengkapi dulu: ${missing.join(', ')}')),
        );
      return;
    }

    // Cek sisa kapasitas slot, lalu kurangi sesuai jumlah tamu.
    final left = _slotRemaining ?? 0;
    if (_guestCount > left) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(left == 0
                ? 'Slot ini sudah penuh. Pilih jam, tanggal, atau area lain.'
                : 'Sisa kapasitas slot ini hanya $left orang.'),
          ),
        );
      return;
    }
    regularSlotStore.book(_selectedLocation!, _selectedDate!, _selectedTime!,
        _selectedArea!, _guestCount);
    final leftAfter = regularSlotStore.remaining(
        _selectedLocation!, _selectedDate!, _selectedTime!, _selectedArea!);
    setState(() {});

    final code =
        'IBC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.check_circle, size: 48, color: primaryColor),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Tiket Reservasi',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 22,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Kode: $code',
                  style: const TextStyle(fontSize: 12, color: mutedColor),
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: borderColor),
              _ticketRow('Lokasi', _selectedLocation!),
              _ticketRow('Tanggal', _formatDate(_selectedDate!)),
              _ticketRow('Waktu', _formatTime(_selectedTime!)),
              _ticketRow('Jumlah tamu', '$_guestCount Orang'),
              _ticketRow('Area meja', _selectedArea!),
              _ticketRow('Sisa slot area ini', '$leftAfter orang'),
              const Divider(color: borderColor),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: mutedColor)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE7ECE8) : const Color(0xFFF0F2F0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: enabled ? const Color(0xFF344A3D) : const Color(0xFFBBC3BD),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildField(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 11, color: mutedColor),
          ),
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 20, color: mutedColor),
          style: const TextStyle(fontSize: 11, color: textColor),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          const Text(
            'Reservasi Restoran',
            style: TextStyle(
              fontFamily: 'Times New Roman',
              fontSize: 25,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Halo, Pelanggan!',
            style: TextStyle(fontSize: 12, color: mutedColor),
          ),
          const Text(
            'Pilih jenis reservasi dan jadwal kedatangan Anda.',
            style: TextStyle(fontSize: 12, color: mutedColor),
          ),
          const SizedBox(height: 23),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE7ECE8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                _buildTab('Regular (2-10 Org)', false),
                _buildTab('Booking Event', true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: isBookingEvent ? _buildBookingEvent() : _buildRegular(),
          ),
          const SizedBox(height: 14),
          if (isBookingEvent) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECE8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimasi Biaya:',
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                      Text(
                        rupiah(_eventTotal),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DP 50% (setelah disetujui):',
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                      Text(
                        rupiah(_eventDp),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
          ],
          GestureDetector(
            onTap: isBookingEvent ? _confirmEvent : _confirmRegular,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isBookingEvent
                        ? 'Ajukan Reservasi'
                        : 'Konfirmasi & Cetak Tiket',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Icon(
                    Icons.arrow_forward,
                    size: 19,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool eventTab) {
    final selected = isBookingEvent == eventTab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isBookingEvent = eventTab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : mutedColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Reservasi',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 11),
        _buildDropdownField(
          hint: 'Pilih Lokasi',
          value: _selectedLocation,
          items: _locations,
          onChanged: (v) => setState(() => _selectedLocation = v),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickDate,
                child: _buildField(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: mutedColor),
                      const SizedBox(width: 6),
                      Text(
                        _selectedDate == null
                            ? 'Pilih tanggal'
                            : _formatDate(_selectedDate!),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                          _selectedDate == null ? mutedColor : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickTime,
                child: _buildField(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: mutedColor),
                      const SizedBox(width: 6),
                      Text(
                        _selectedTime == null
                            ? 'Pilih waktu'
                            : _formatTime(_selectedTime!),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                          _selectedTime == null ? mutedColor : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'Jumlah tamu',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _counterButton(
              Icons.remove,
              _guestCount - _guestStep >= _minGuests
                  ? () => setState(() => _guestCount -= _guestStep)
                  : null,
            ),
            Text(
              '$_guestCount Orang',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            _counterButton(
              Icons.add,
              _guestCount + _guestStep <= _guestLimit
                  ? () => setState(() => _guestCount += _guestStep)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildSlotInfo(),
        const SizedBox(height: 17),
        const Text(
          'Pilih Area Meja',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        _buildDropdownField(
          hint: 'Pilih area meja',
          value: _selectedArea,
          items: _tableAreas,
          onChanged: (v) => setState(() => _selectedArea = v),
        ),
      ],
    );
  }

  Widget _buildBookingEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Reservasi',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 11),
        _buildDropdownField(
          hint: 'Pilih Lokasi',
          value: _eventLocation,
          items: _locations,
          onChanged: (v) => setState(() => _eventLocation = v),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickEventDate,
                child: _buildField(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: mutedColor),
                      const SizedBox(width: 6),
                      Text(
                        _eventDate == null
                            ? 'Pilih tanggal'
                            : _formatDate(_eventDate!),
                        style: TextStyle(
                          fontSize: 10,
                          color: _eventDate == null ? mutedColor : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _pickEventTime,
                child: _buildField(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: mutedColor),
                      const SizedBox(width: 6),
                      Text(
                        _eventTime == null
                            ? 'Pilih waktu'
                            : _formatTime(_eventTime!),
                        style: TextStyle(
                          fontSize: 10,
                          color: _eventTime == null ? mutedColor : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Pemesanan event minimal 3 hari sebelum acara.',
          style: TextStyle(fontSize: 9, color: mutedColor),
        ),
        const SizedBox(height: 14),
        const Divider(color: borderColor),
        const SizedBox(height: 20),
        const Text(
          '1. Pilih Jenis Acara',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          hint: 'Pilih Jenis Acara',
          value: _eventType,
          items: _eventTypes,
          onChanged: (v) => setState(() => _eventType = v),
        ),
        const SizedBox(height: 27),
        const Text(
          '2. Pilih Ruangan & Estimasi Kapasitas',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          hint: 'Pilih Ruangan Event',
          value: _eventRoom?.label,
          items: _eventRooms.map((r) => r.label).toList(),
          onChanged: (v) {
            if (v == null) return;
            _selectEventRoom(_eventRooms.firstWhere((r) => r.label == v));
          },
        ),
        const SizedBox(height: 27),
        const Text(
          '3. Pilih Paket Makanan (Per Pax)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          hint: 'Pilih Paket Pax Makanan',
          value: _eventPackage?.label,
          items: _eventPackages.map((p) => p.label).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _eventPackage = _eventPackages.firstWhere((p) => p.label == v);
            });
          },
        ),
        const SizedBox(height: 27),
        const Text(
          '4. Jumlah Porsi',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _counterButton(
              Icons.remove,
              _eventPortionActive && _eventPortions > _eventPortionMin
                  ? () => _changeEventPortions(-_eventPortionStep)
                  : null,
            ),
            Text(
              '$_eventPortions porsi',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                _eventPortionActive ? FontWeight.w600 : FontWeight.normal,
                color: _eventPortionActive ? textColor : mutedColor,
              ),
            ),
            _counterButton(
              Icons.add,
              _eventPortionActive && _eventPortions < _eventPortionMax
                  ? () => _changeEventPortions(_eventPortionStep)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Minimum $_eventPortionMin · Maks. $_eventPortionMax porsi '
              '(kelipatan $_eventPortionStep)\n'
              'Pilih ruangan dan paket terlebih dahulu untuk mengaktifkan '
              'penyesuaian porsi.',
          style: const TextStyle(
            fontSize: 9,
            height: 1.45,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 27),
        const Text(
          '5. Catatan Khusus (Opsional)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _eventNoteController,
          maxLines: 3,
          style: const TextStyle(fontSize: 11, color: textColor),
          decoration: InputDecoration(
            hintText: 'Contoh: dekorasi ulang tahun, kue, alergi makanan',
            hintStyle: const TextStyle(fontSize: 11, color: mutedColor),
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Ketentuan: DP 50% dibayar maksimal 24 jam setelah reservasi '
              'disetujui restoran. Pelunasan paling lambat H-1 acara.',
          style: TextStyle(fontSize: 9, height: 1.45, color: mutedColor),
        ),
      ],
    );
  }

  // Info sisa slot di bawah counter jumlah tamu (Regular).
  Widget _buildSlotInfo() {
    final left = _slotRemaining;
    final area = _selectedArea;

    if (left == null || area == null) {
      return const Text(
        'Pilih lokasi, tanggal, waktu, dan area meja untuk melihat sisa slot.',
        style: TextStyle(fontSize: 9, height: 1.45, color: mutedColor),
      );
    }

    final total = regularSlotStore.capacityOf(area);
    final tooMany = _guestCount > left;
    final full = left == 0;
    final color = (full || tooMany) ? Colors.red.shade700 : primaryColor;

    final text = full
        ? 'Slot penuh untuk area ini. Pilih jam, tanggal, atau area lain.'
        : tooMany
        ? 'Sisa slot hanya $left orang. Kurangi jumlah tamu atau pilih slot lain.'
        : 'Sisa slot: $left dari $total orang (jam ${_selectedTime!.hour.toString().padLeft(2, '0')}.00).';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECE8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.event_seat_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
