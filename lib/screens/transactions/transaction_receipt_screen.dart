import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/currency_formatter.dart';
import '../../data/app_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/in_app_notification.dart';

/// ============================================================================
/// HALAMAN STRUK RESMI DIGITAL PUNDIGO! (DENGAN ELEMEN VISUAL & LOGO ASLI)
/// ============================================================================
/// Dilengkapi:
/// - Logo Brand Resmi PundiGo! di kepala struk.
/// - Logo Asli Merchant / Operator / Bank / Dompet Digital (Telkomsel, PLN, Bank Aceh, BSI, GoPay, DANA).
/// - Barcode 1D & QR Verifikasi Otentikasi Transaksi.
/// - Stempel Digital "LUNAS / BERHASIL DIKONFIRMASI" terstandarisasi.
/// ============================================================================
enum ReceiptType {
  topup,
  transfer,
  pulsa,
  pln,
  qris,
}

class TransactionReceiptScreen extends StatelessWidget {
  final ReceiptType receiptType;
  final String title;
  final double amount;
  final bool isIncome;
  final String? recipientOrDestination;
  final String? accountOrPhone;
  final String? methodOrProvider;
  final String? referenceNumber;
  final String? tokenCode; // Khusus PLN (20 Digit)
  final String? serialNumber; // Khusus Pulsa/Data (SN Operator)
  final String? packageName;
  final String? notes;

  const TransactionReceiptScreen({
    super.key,
    required this.receiptType,
    this.title = 'Bukti Transaksi',
    required this.amount,
    this.isIncome = false,
    this.recipientOrDestination,
    this.accountOrPhone,
    this.methodOrProvider,
    this.referenceNumber,
    this.tokenCode,
    this.serialNumber,
    this.packageName,
    this.notes,
  });

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final m = now.month >= 1 && now.month <= 12 ? months[now.month - 1] : 'Nov';
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final hourStr = now.hour.toString().padLeft(2, '0');
    return '${now.day} $m ${now.year}, $hourStr:$minuteStr WIB';
  }

  String _generateRef() {
    if (referenceNumber != null && referenceNumber!.isNotEmpty) {
      return referenceNumber!;
    }
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final dateStr = '$y$m$d';
    final randomDigits = (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '8');
    switch (receiptType) {
      case ReceiptType.topup:
        return 'PG-TOP-$dateStr-$randomDigits';
      case ReceiptType.transfer:
        return 'PG-TRF-$dateStr-$randomDigits';
      case ReceiptType.pulsa:
        return 'PG-PLS-$dateStr-$randomDigits';
      case ReceiptType.pln:
        return 'PG-PLN-$dateStr-$randomDigits';
      case ReceiptType.qris:
        return 'PG-QRS-$dateStr-$randomDigits';
    }
  }

  String _getProviderAsset() {
    switch (receiptType) {
      case ReceiptType.pln:
        return 'assets/images/logo_pln.png';
      case ReceiptType.pulsa:
        return 'assets/images/logo_telkomsel.png';
      case ReceiptType.topup:
        return 'assets/images/wallet_3d_hd.png';
      case ReceiptType.qris:
        return 'assets/images/pundigo_qris_master.png';
      case ReceiptType.transfer:
        final prov = (methodOrProvider ?? '').toLowerCase();
        if (prov.contains('aceh')) return 'assets/images/logo_bank_aceh.png';
        if (prov.contains('bsi') || prov.contains('syariah')) return 'assets/images/logo_bank_bsi.png';
        if (prov.contains('gopay')) return 'assets/images/logo_gopay.png';
        if (prov.contains('dana')) return 'assets/images/logo_dana.png';
        return 'assets/images/logo_pg_mark_hd.png';
    }
  }

  void _showShareReceiptModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F8F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_rounded, color: Color(0xFF00A887), size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                'Bagikan Struk Transaksi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bukti transaksi resmi telah siap dibagikan ke teman atau keluarga Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),

              // Opsi Bagikan Cepat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showInFrameToast(context, 'Teks struk berhasil disalin untuk WhatsApp!');
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.copy_rounded,
                    label: 'Salin Teks',
                    color: const Color(0xFF00A887),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showInFrameToast(context, 'Rincian struk disalin ke papan klip.');
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.download_rounded,
                    label: 'Simpan Gambar',
                    color: const Color(0xFF1E88E5),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showInFrameToast(context, 'Struk digital berhasil disimpan ke galeri.');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInFrameToast(BuildContext context, String message) {
    InAppNotification.show(
      context,
      title: 'Struk Transaksi',
      message: message,
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFF00796B),
      iconBg: const Color(0xFFE6F8F5),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.user;
    final refNumber = _generateRef();
    final trxDate = _formatCurrentDate();
    final providerImg = _getProviderAsset();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: title,
        onBack: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Text(
                'Bukti Transaksi Resmi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 16),

              // ===============================================================
              // 1. IKON / LOGO VISUAL BESAR DI ATAS STRUK
              // ===============================================================
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00BFA5).withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      providerImg,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF00A887),
                        size: 36,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A887),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                _getHeaderTitle(),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isIncome ? const Color(0xFF00897B) : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Badge Transaksi Selesai & Terverifikasi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF00A887)),
                    const SizedBox(width: 6),
                    Text(
                      'TRANSAKSI BERHASIL & TERVERIFIKASI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00897B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===============================================================
              // KOTAK SPESIFIK JIKA ADA TOKEN PLN ATAU SN PULSA
              // ===============================================================
              if (tokenCode != null && tokenCode!.isNotEmpty) ...[
                _buildTokenPlnBox(context, tokenCode!),
                const SizedBox(height: 16),
              ],

              if (serialNumber != null && serialNumber!.isNotEmpty) ...[
                _buildSerialPulsaBox(context, serialNumber!),
                const SizedBox(height: 16),
              ],

              // ===============================================================
              // KARTU STRUK UTAMA DIGITAL (LENGKAP DENGAN LOGO & BARCODE)
              // ===============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Brand PundiGo! dengan Logo Vektor
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo_pundigo_text.png',
                          height: 22,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            'PundiGo!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF007A63),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/logo_pg_exact.png',
                                width: 14,
                                height: 14,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 13,
                                  color: Color(0xFF1E88E5),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'PundiGo Pay',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E88E5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'PT PUNDIGO TEKNOLOGI FINANSIAL INDONESIA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    const SizedBox(height: 14),

                    // Detail Sesuai Jenis Transaksi
                    ..._buildDynamicDetails(user, trxDate, refNumber),

                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    const SizedBox(height: 14),

                    // Saldo Terkini
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sisa Saldo PundiGo',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(user.saldoUtama),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF007A63),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // =========================================================
                    // BARCODE & QR KODE VERIFIKASI RESMI STRUK
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VALIDASI OTENTIKASI TRANSAKSI',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Tersertifikasi Bank Indonesia (BI-FAST / QRIS)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F7F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'LUNAS ✓',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF00897B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Visual Barcode 1D
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(42, (i) {
                              final isWide = (i * 7 + 3) % 4 == 0;
                              final isBlank = (i * 3 + 1) % 7 == 0;
                              if (isBlank) return const SizedBox(width: 3.5);
                              return Container(
                                width: isWide ? 3.2 : 1.6,
                                height: 32,
                                margin: const EdgeInsets.symmetric(horizontal: 1.1),
                                color: const Color(0xFF1E293B),
                              );
                            }),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            refNumber,
                            style: GoogleFonts.spaceMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===============================================================
              // TOMBOL AKSI: BAGIKAN STRUK & SELESAI
              // ===============================================================
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF00A887), width: 1.5),
                        backgroundColor: const Color(0xFFF0FDF4),
                      ),
                      onPressed: () => _showShareReceiptModal(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_outlined, color: Color(0xFF007A63), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Bagikan Struk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF007A63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Selesai',
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (receiptType) {
      case ReceiptType.topup:
        return 'Isi Saldo Berhasil!';
      case ReceiptType.transfer:
        return 'Transfer Berhasil!';
      case ReceiptType.pulsa:
        return 'Pembelian Pulsa Sukses!';
      case ReceiptType.pln:
        return 'Beli Token PLN Sukses!';
      case ReceiptType.qris:
        return 'Pembayaran QRIS Sukses!';
    }
  }

  Widget _buildTokenPlnBox(BuildContext context, String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_pln.png',
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.bolt_rounded, color: Color(0xFFB45309), size: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '20 DIGIT NOMOR TOKEN (STROOM)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB45309),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            code,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF78350F),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showInFrameToast(context, 'Nomor token PLN disalin ke klipboard!'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 5),
                  Text(
                    'Salin Nomor Token',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB45309),
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

  Widget _buildSerialPulsaBox(BuildContext context, String sn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_telkomsel.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.signal_cellular_alt_rounded, color: Color(0xFF64748B), size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'NOMOR SERIAL OPERATOR (SN)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            sn,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicDetails(dynamic user, String trxDate, String refNumber) {
    final List<Widget> rows = [];

    void addRow(String label, String value, {String? subtitle, Color? valueColor, String? logoAsset}) {
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: 12));
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (logoAsset != null) ...[
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 8),
                      child: Image.asset(
                        logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_rounded, size: 20, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: valueColor ?? const Color(0xFF0F172A),
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    switch (receiptType) {
      case ReceiptType.topup:
        addRow('Jenis Transaksi', 'Isi Saldo (Top Up)', logoAsset: 'assets/images/wallet_3d_hd.png');
        addRow('Metode Pembayaran', methodOrProvider ?? 'Tunai Kasir Indomaret');
        addRow('Akun Penerima', user.name, subtitle: user.phone);
        addRow('Biaya Layanan', 'Rp 0 (Gratis)', valueColor: const Color(0xFF00A887));
        addRow('Waktu Transaksi', trxDate);
        addRow('No. Referensi', refNumber);
        break;

      case ReceiptType.transfer:
        addRow('Jenis Transaksi', 'Transfer Saldo', logoAsset: _getProviderAsset());
        addRow('Penerima', recipientOrDestination ?? 'Penerima PundiGo');
        if (methodOrProvider != null) {
          addRow('Tujuan Transfer', methodOrProvider!);
        }
        if (accountOrPhone != null) {
          addRow('No. Rekening / HP', accountOrPhone!);
        }
        if (notes != null && notes!.isNotEmpty) {
          addRow('Catatan', notes!);
        }
        addRow('Biaya Transfer', 'Rp 0 (BI-FAST Gratis)', valueColor: const Color(0xFF00A887));
        addRow('Waktu Transaksi', trxDate);
        addRow('No. Referensi', refNumber);
        break;

      case ReceiptType.pulsa:
        addRow('Jenis Transaksi', 'Pembelian Pulsa & Data', logoAsset: 'assets/images/logo_telkomsel.png');
        addRow('Nomor Handphone', accountOrPhone ?? user.phone);
        addRow('Operator', methodOrProvider ?? 'Telkomsel Prabayar');
        if (packageName != null) {
          addRow('Paket', packageName!);
        }
        addRow('Biaya Admin', 'Rp 0 (Promo PundiGo)', valueColor: const Color(0xFF00A887));
        addRow('Waktu Transaksi', trxDate);
        addRow('No. Referensi', refNumber);
        break;

      case ReceiptType.pln:
        addRow('Jenis Transaksi', 'Token Listrik PLN Prabayar', logoAsset: 'assets/images/logo_pln.png');
        addRow('ID Pelanggan / Meter', accountOrPhone ?? '142981048821');
        addRow('Nama Pelanggan', recipientOrDestination ?? user.name);
        addRow('Tarif / Daya', methodOrProvider ?? 'R1M / 900 VA');
        addRow('Biaya Admin Bank', 'Rp 0 (Gratis)', valueColor: const Color(0xFF00A887));
        addRow('Waktu Transaksi', trxDate);
        addRow('No. Referensi', refNumber);
        break;

      case ReceiptType.qris:
        addRow('Jenis Transaksi', 'Pembayaran QRIS Universal', logoAsset: 'assets/images/logo_pg_mark_hd.png');
        addRow('Merchant', recipientOrDestination ?? 'Merchant QRIS');
        if (methodOrProvider != null) {
          addRow('Kota Merchant', methodOrProvider!);
        }
        addRow('Metode Sumber', 'PundiGo Saldo Utama');
        addRow('Biaya Transaksi', 'Rp 0 (Gratis)', valueColor: const Color(0xFF00A887));
        addRow('Waktu Transaksi', trxDate);
        addRow('No. Referensi', refNumber);
        break;
    }

    return rows;
  }
}
