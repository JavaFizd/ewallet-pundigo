import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/qris_parser.dart';
import '../../data/app_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/pundigo_qr_card.dart';
import '../transactions/transaction_receipt_screen.dart';

/// ============================================================================
/// PUSAT QRIS PUNDIGO! - DUA OPSI: PINDAI (SCAN) & KODE QR SAYA
/// ============================================================================
/// - Pindai QRIS: Pemindai cerdas dengan validasi ketat standar QRIS Bank Indonesia (EMVCo).
///   Hanya menerima dan memproses kode QR pembayaran yang valid.
/// - Kode QR Saya: Kartu QRIS resmi standar BI dengan logo PundiGo! terintegrasi
///   rapi di tengah matriks QR beresolusi tinggi (tidak menutupi data).
/// ============================================================================
class ScanQrisScreen extends StatefulWidget {
  final int initialTabIndex; // 0: Scan, 1: QR Saya
  const ScanQrisScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ScanQrisScreen> createState() => _ScanQrisScreenState();
}

class _ScanQrisScreenState extends State<ScanQrisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _laserController;
  bool _isFlashOn = false;
  double? _customNominal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // PEMROSESAN & VALIDASI KODE QRIS
  // ===========================================================================
  void _handleScannedRawData(String rawText) {
    final qris = QrisData.parse(rawText);

    if (!qris.isValid) {
      _showInvalidQrDialog(qris.errorMessage ?? 'Format kode QR tidak valid.');
      return;
    }

    _showPaymentConfirmationSheet(qris);
  }

  void _showInvalidQrDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Bukan Kode QR Valid!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Coba Lagi',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  void _showPaymentConfirmationSheet(QrisData qris) {
    final user = AppState.instance.user;
    final nominalController = TextEditingController(
      text: qris.amount != null ? qris.amount!.toInt().toString() : '',
    );
    double activeAmount = qris.amount ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasEnoughBalance = user.saldoUtama >= activeAmount && activeAmount > 0;

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBE123C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'QRIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Konfirmasi Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Detail Merchant Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildSheetRow('Penerima / Merchant', qris.merchantName, isBold: true),
                        const Divider(height: 20),
                        _buildSheetRow('Lokasi', qris.city),
                        const Divider(height: 20),
                        _buildSheetRow('Sumber Dana', 'Saldo Utama PundiGo (${CurrencyFormatter.format(user.saldoUtama)})'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Nominal jika bebas isi (Static QR)
                  if (qris.amount == null || qris.amount == 0) ...[
                    Text(
                      'Masukkan Nominal Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nominalController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setSheetState(() {
                          activeAmount = double.tryParse(val) ?? 0;
                        });
                      },
                    ),
                  ] else ...[
                    // Nominal Tetap dari QR Dinamis
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00796B),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(activeAmount),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF00897B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (activeAmount > user.saldoUtama) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Saldo Utama kamu tidak mencukupi.',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasEnoughBalance ? const Color(0xFF00BFA5) : const Color(0xFFCBD5E1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: hasEnoughBalance ? 2 : 0,
                          ),
                          onPressed: hasEnoughBalance
                              ? () {
                                  Navigator.of(ctx).pop();
                                  _executePayment(qris.merchantName, activeAmount, qris.city);
                                }
                              : null,
                          child: Text(
                            'Konfirmasi & Bayar',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _executePayment(String merchantName, double amount, String city) {
    final success = AppState.instance.bayarQris(
      amount: amount,
      merchantName: merchantName,
      city: city,
    );

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransactionReceiptScreen(
            receiptType: ReceiptType.qris,
            title: 'Pembayaran QRIS',
            amount: amount,
            isIncome: false,
            recipientOrDestination: merchantName,
            methodOrProvider: city,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
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
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 32),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pembayaran QRIS Gagal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saldo Utama kamu tidak mencukupi untuk pembayaran sebesar ${CurrencyFormatter.format(amount)} ke $merchantName.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                AppButton(
                  text: 'Tutup',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showSuccessReceipt(String merchantName, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F8F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00A887), size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'Pembayaran Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Transaksi QRIS telah diverifikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Nominal', CurrencyFormatter.format(amount), isLarge: true),
                    const Divider(height: 20),
                    _buildReceiptRow('Merchant', merchantName),
                    const Divider(height: 20),
                    _buildReceiptRow('Metode', 'PundiGo! Pay (QRIS)'),
                    const Divider(height: 20),
                    _buildReceiptRow('No. Ref', 'PG-QRIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(); // Tutup scanner, kembali ke beranda
                  },
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
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

  Widget _buildSheetRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isLarge ? 16 : 12.5,
            fontWeight: isLarge ? FontWeight.w900 : FontWeight.w700,
            color: isLarge ? const Color(0xFF00897B) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // INTERAKSI PEMINDAI (SHUTTER & GALERI)
  // ===========================================================================
  void _openScanPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Opsi Pindai QRIS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hanya kode QR pembayaran QRIS resmi yang dapat diproses.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              _buildScanOptionTile(
                icon: Icons.storefront_rounded,
                title: 'Pindai Kopi Kenangan Kampus',
                subtitle: 'QRIS Merchant Resmi • Rp 28.000',
                color: const Color(0xFF00A887),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData(QrisData.sampleKopiKenangan);
                },
              ),
              _buildScanOptionTile(
                icon: Icons.person_rounded,
                title: 'Pindai QR Taufiq',
                subtitle: 'Transfer Antar Pengguna PundiGo • Rp 50.000',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData(QrisData.sampleTaufiq);
                },
              ),
              _buildScanOptionTile(
                icon: Icons.local_convenience_store_rounded,
                title: 'Pindai Indomaret Express',
                subtitle: 'QRIS Retail Merchant • Rp 45.000',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData(QrisData.sampleIndomaret);
                },
              ),
              _buildScanOptionTile(
                icon: Icons.edit_note_rounded,
                title: 'Pindai QR Bebas Nominal',
                subtitle: 'Warung Madura Berkah • Bebas Isi Nominal',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData(QrisData.sampleWarungBebasNominal);
                },
              ),
              _buildScanOptionTile(
                icon: Icons.edit_outlined,
                title: 'Input / Tempel Teks QRIS Manual',
                subtitle: 'Masukkan string data QRIS secara langsung',
                color: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showManualInputDialog();
                },
              ),
              _buildScanOptionTile(
                icon: Icons.block_rounded,
                title: 'Uji Pindai Kode Non-QR / Gambar Rusak',
                subtitle: 'Simulasi deteksi kode tidak valid (otomatis ditolak)',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData('https://google.com/bukan-qris-invalid-data');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Tempel / Input Kode QRIS',
            style: GoogleFonts.plusJakartaSans(fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sistem akan memvalidasi apakah kode berformat QRIS resmi Bank Indonesia.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'Contoh: 00020101021226600016ID.CO...',
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final text = controller.text;
                Navigator.of(ctx).pop();
                _handleScannedRawData(text);
              },
              child: const Text('Proses QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _openGalleryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pindai dari Galeri Foto',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih gambar QRIS yang tersimpan di perangkatmu:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              _buildScanOptionTile(
                icon: Icons.image_search_rounded,
                title: 'Foto QRIS: Kopi Kenangan Kampus',
                subtitle: 'Hasil unduhan struk QRIS • Rp 28.000',
                color: const Color(0xFF00A887),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData(QrisData.sampleKopiKenangan);
                },
              ),
              _buildScanOptionTile(
                icon: Icons.image_search_rounded,
                title: 'Foto QRIS: Taufiq',
                subtitle: 'Tangkapan layar QR teman • Rp 50.000',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData(QrisData.sampleTaufiq);
                },
              ),
              _buildScanOptionTile(
                icon: Icons.hide_image_outlined,
                title: 'Pilih Gambar Acak (Bukan QR)',
                subtitle: 'Simulasi memilih foto selfie/pemandangan (otomatis ditolak)',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _handleScannedRawData('DATA_GAMBAR_BUKAN_KODE_QR');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ATUR NOMINAL QRIS SAYA
  // ===========================================================================
  void _showSetNominalDialog() {
    final controller = TextEditingController(text: _customNominal?.toInt().toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Atur Nominal Permintaan',
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tentukan jumlah yang harus dibayar saat kode QR ini dipindai oleh orang lain.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  labelText: 'Nominal Saldo',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _customNominal = null;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Bebas Nominal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final val = double.tryParse(controller.text);
                setState(() {
                  _customNominal = val;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Terapkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppState.instance.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pusat QRIS PundiGo',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF1E88E5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BFA5).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Pindai QRIS'),
                      ],
                    ),
                  ),
                  Tab(
                    iconMargin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Kode QR Saya'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // =================================================================
          // OPSI 1: PINDAI QRIS (KAMERA SCANNER CERDAS)
          // =================================================================
          _buildScannerView(),

          // =================================================================
          // OPSI 2: TAMPILKAN KODE QR SAYA (DENGAN LOGO DI TENGAH)
          // =================================================================
          _buildMyQrView(user),
        ],
      ),
    );
  }

  // View Pemindai Kamera
  Widget _buildScannerView() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Badge Instruksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.crop_free_rounded, color: Color(0xFF69F0AE), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Arahkan kamera ke kode QRIS pembayaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Jendela Pemindai Kotak dengan Sudut Hijau Neon
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
              ),
              child: Stack(
                children: [
                  Positioned(top: 8, left: 8, child: _buildReticleCorner(isTop: true, isLeft: true)),
                  Positioned(top: 8, right: 8, child: _buildReticleCorner(isTop: true, isLeft: false)),
                  Positioned(bottom: 8, left: 8, child: _buildReticleCorner(isTop: false, isLeft: true)),
                  Positioned(bottom: 8, right: 8, child: _buildReticleCorner(isTop: false, isLeft: false)),

                  // Garis Laser Scanning Animasi Bergerak
                  AnimatedBuilder(
                    animation: _laserController,
                    builder: (context, child) {
                      return Positioned(
                        top: 20 + (_laserController.value * 230),
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, Color(0xFF69F0AE), Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF69F0AE).withOpacity(0.9),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Toolbar Kontrol: Flash & Galeri
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToolButton(
                icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                label: _isFlashOn ? 'Flash Nyala' : 'Senter',
                isActive: _isFlashOn,
                onTap: () {
                  setState(() {
                    _isFlashOn = !_isFlashOn;
                  });
                },
              ),
              const SizedBox(width: 32),
              _buildToolButton(
                icon: Icons.image_rounded,
                label: 'Galeri',
                isActive: false,
                onTap: _openGalleryPicker,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tombol Shutter Ambil Foto/Scan
          GestureDetector(
            onTap: _openScanPicker,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00BFA5), width: 3.5),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
                    ),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Ketuk tombol untuk memindai QRIS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // View Kode QR Saya (Dengan Logo PundiGo di Tengah)
  Widget _buildMyQrView(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Kartu QR PundiGo dengan Logo di Tengah (Matriks Padat & Vektor Standar BI)
          PundigoQrCard(
            userName: user.name,
            userPhone: user.phone,
            nominal: _customNominal,
            note: _customNominal != null ? 'Transfer ke Rekening PundiGo' : null,
            qrSize: 210,
          ),

          const SizedBox(height: 20),

          // Tombol Tindakan Cepat (Atur Nominal, Unduh, Bagikan)
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit_note_rounded,
                  label: _customNominal != null ? 'Ubah Nominal' : 'Atur Nominal',
                  color: const Color(0xFF00BFA5),
                  onTap: _showSetNominalDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.download_rounded,
                  label: 'Simpan QR',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kode QRIS PundiGo berhasil disimpan ke galeri!'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.share_rounded,
                  label: 'Bagikan',
                  color: const Color(0xFF8B5CF6),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tautan pembayaran PundiGo disalin ke clipboard!'),
                        backgroundColor: Color(0xFF0284C7),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00BFA5) : Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReticleCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF69F0AE), width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF69F0AE), width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF69F0AE), width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF69F0AE), width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}
