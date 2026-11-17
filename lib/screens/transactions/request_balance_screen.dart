import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/app_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/in_app_notification.dart';
import '../../widgets/common/pundigo_qr_card.dart';
import 'requested_balance_payment_screen.dart';

/// ============================================================================
/// HALAMAN PUSAT MINTA SALDO (REQUEST BALANCE HUB) - PUNDIGO!
/// ============================================================================
/// 3 Metode Lengkap:
/// 1. Minta ke Kontak Teman (Pilih kontak, nominal, dan preview tampilan di HP teman)
/// 2. Kode QR Saya (QR dinamis dengan nominal fleksibel)
/// 3. Pindai QR Teman (Scanner visual untuk membayar permintaan teman)
/// ============================================================================
class RequestBalanceScreen extends StatefulWidget {
  const RequestBalanceScreen({super.key});

  @override
  State<RequestBalanceScreen> createState() => _RequestBalanceScreenState();
}

class _RequestBalanceScreenState extends State<RequestBalanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController(text: '50000');
  final TextEditingController _noteController = TextEditingController(text: 'Minta saldo PundiGo');

  // Kontak teman terpilih
  Map<String, String>? _selectedContact;
  final TextEditingController _targetPhoneController = TextEditingController();
  final TextEditingController _targetNameController = TextEditingController();
  String _sentRecipientName = '';
  bool _requestSent = false;
  double _sentAmount = 50000;
  String _sentNote = '';

  final List<Map<String, String>> _contacts = [
    {
      'name': 'Dinda Kirana',
      'phone': '0812-3456-7890',
      'email': 'dinda.kirana@gmail.com',
      'avatar': 'DK',
      'color': '0xFF00796B',
    },
    {
      'name': 'Naufal Daffa',
      'phone': '0813-4567-8901',
      'email': 'naufal.daffa@gmail.com',
      'avatar': 'ND',
      'color': '0xFF2563EB',
    },
    {
      'name': 'Rahmat Hidayat',
      'phone': '0821-5678-9012',
      'email': 'rahmat.h@gmail.com',
      'avatar': 'RH',
      'color': '0xFFD97706',
    },
    {
      'name': 'Maya Amelia',
      'phone': '0852-6789-0123',
      'email': 'maya.amelia@gmail.com',
      'avatar': 'MA',
      'color': '0xFF9333EA',
    },
    {
      'name': 'Fajar Nugraha',
      'phone': '0878-7890-1234',
      'email': 'fajar.nugraha@gmail.com',
      'avatar': 'FN',
      'color': '0xFFE11D48',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final user = AppState.instance.user;
    final bool isTaufiq = user.name.toLowerCase().contains('taufiq');
    if (isTaufiq) {
      _selectedContact = _contacts.first;
    } else {
      _selectedContact = null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _targetPhoneController.dispose();
    _targetNameController.dispose();
    super.dispose();
  }

  void _sendFriendRequest() {
    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 50000;
    if (amount < 10000) {
      InAppNotification.show(
        context,
        title: 'Nominal Terlalu Kecil',
        message: 'Minimal permintaan saldo adalah Rp 10.000.',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFD97706),
        iconBg: const Color(0xFFFEF3C7),
      );
      return;
    }

    final user = AppState.instance.user;
    final bool isTaufiq = user.name.toLowerCase().contains('taufiq');
    String recipient;

    if (isTaufiq) {
      recipient = _selectedContact?['name'] ?? 'Teman';
    } else {
      final phone = _targetPhoneController.text.trim();
      if (phone.isEmpty) {
        InAppNotification.show(
          context,
          title: 'Nomor HP Belum Diisi',
          message: 'Silakan masukkan nomor HP teman tujuan permintaan saldo.',
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7),
        );
        return;
      }
      final name = _targetNameController.text.trim();
      recipient = name.isNotEmpty ? '$name ($phone)' : phone;
    }

    setState(() {
      _requestSent = true;
      _sentAmount = amount;
      _sentRecipientName = recipient;
      _sentNote = _noteController.text.trim().isEmpty ? 'Permintaan Saldo PundiGo' : _noteController.text.trim();
    });

    InAppNotification.show(
      context,
      title: 'Permintaan Saldo Terkirim!',
      message: 'Permintaan ${CurrencyFormatter.format(_sentAmount)} telah dikirim ke $recipient.',
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF00A887),
      iconBg: const Color(0xFFE6F8F5),
      badgeText: 'Menunggu',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: const CustomAppBar(title: 'Minta Saldo'),
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // TAB SELECTOR METODE MINTA SALDO
            // =================================================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF0F172A),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: '👥 Kontak Teman'),
                  Tab(text: '📱 Kode QR Saya'),
                  Tab(text: '📷 Pindai QR Teman'),
                ],
              ),
            ),

            // =================================================================
            // KONTEN TAB
            // =================================================================
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendContactTab(),
                  _buildMyQrCodeTab(),
                  _buildScanFriendQrTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: MINTA KE KONTAK TEMAN
  // ===========================================================================
  Widget _buildFriendContactTab() {
    final user = AppState.instance.user;

    if (_requestSent) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F8F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF00A887), size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Permintaan Berhasil Dikirim!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi penagihan telah masuk ke akun teman Anda.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('Penerima Tagihan', _sentRecipientName),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Nominal Permintaan', CurrencyFormatter.format(_sentAmount), isBold: true),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Catatan', _sentNote),
                        const Divider(height: 20, color: Color(0xFFE2E8F0)),
                        _buildDetailRow('Status', 'Menunggu Pembayaran', statusColor: const Color(0xFFD97706)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TOMBOL PREVIEW TAMPILAN TEMAN
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00796B), Color(0xFF004D40)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00796B).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RequestedBalancePaymentScreen(
                              requesterName: user.name,
                              requesterPhone: user.phone,
                              requesterEmail: user.email,
                              requestedAmount: _sentAmount,
                              requestNote: _sentNote,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.preview_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Lihat Tampilan Layar Teman Penerima ➔',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  AppButton.outline(
                    text: 'Minta Lagi ke Teman Lain',
                    onPressed: () {
                      setState(() {
                        _requestSent = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final bool isTaufiq = user.name.toLowerCase().contains('taufiq');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTaufiq) ...[
            Text(
              'Pilih Teman PundiGo!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih kontak yang ingin Anda mintai saldo secara langsung:',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),

            // DAFTAR KONTAK TEMAN (HANYA TAUFIQ)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _contacts.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  final isSelected = _selectedContact?['phone'] == contact['phone'];
                  final color = Color(int.parse(contact['color']!));

                  return Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedContact = contact;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: color.withOpacity(0.15),
                        child: Text(
                          contact['avatar']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            color: color,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        contact['name']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        contact['phone']!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                      ),
                      trailing: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFF00796B) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF00796B) : const Color(0xFFCBD5E1),
                            width: 2,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            // TAMPILAN AKUN BARU: BERSIH TANPA KONTAK ORANG LAIN
            Text(
              'Nomor Handphone Tujuan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Akun baru belum memiliki kontak tersimpan. Masukkan nomor HP teman untuk meminta saldo:',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor HP Teman',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _targetPhoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF00796B), size: 20),
                      hintText: '08xx-xxxx-xxxx',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nama Teman (Opsional)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _targetNameController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B), size: 20),
                      hintText: 'Contoh: Teman Kuliah / Budi',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFD),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // NOMINAL PERMINTAAN
          Text(
            'Nominal Permintaan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Text(
                  'Rp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00796B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // PILIHAN CHIP NOMINAL CEPAT
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [10000, 25000, 50000, 100000, 200000].map((nominal) {
              return ActionChip(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                label: Text(
                  CurrencyFormatter.format(nominal.toDouble()),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _amountController.text = nominal.toString();
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // CATATAN PERMINTAAN
          Text(
            'Catatan (Opsional)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Contoh: Minta uang kas / ganti makan siang',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // TOMBOL KIRIM PERMINTAAN
          AppButton(
            text: 'Kirim Permintaan Saldo',
            onPressed: _sendFriendRequest,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: KODE QR SAYA
  // ===========================================================================
  Widget _buildMyQrCodeTab() {
    final user = AppState.instance.user;
    final amount = double.tryParse(_amountController.text) ?? 50000;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          PundigoQrCard(
            userName: user.name,
            userPhone: user.phone,
            nominal: amount,
            note: 'Minta Saldo PundiGo',
            qrSize: 200,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF00796B), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Perlihatkan kode QR di atas ke teman Anda untuk dipindai langsung menggunakan kamera PundiGo!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: PINDAI QR TEMAN
  // ===========================================================================
  Widget _buildScanFriendQrTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pemindai QR Teman',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.flash_on_rounded, color: Colors.white70, size: 20),
                  ],
                ),
                const SizedBox(height: 24),

                // FRAME VIEWFINDER KAMERA SIMULASI
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00A887), width: 3),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 100, color: Color(0xFF00A887)),
                      Positioned(
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Arahkan ke QR Teman',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Pindai kode QR dari layar teman yang meminta saldo ke Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TOMBOL SCAN DEMO INSTAN
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF00796B), Color(0xFF004D40)],
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RequestedBalancePaymentScreen(
                      requesterName: 'Taufiq',
                      requesterPhone: '0812-3456-789',
                      requesterEmail: 'topikpanas@gmail.com',
                      requestedAmount: 50000,
                      requestNote: 'Permintaan Saldo PundiGo via QR',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Simulasi Berhasil Pindai QR Taufiq (Rp 50.000)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: statusColor ?? (isBold ? const Color(0xFF00796B) : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
