import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/app_state.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../../widgets/common/pg_logo.dart';
import '../../widgets/common/pundigo_background.dart';
import 'shared_kas_screen.dart';

/// ============================================================================
/// TAMPILAN TEMAN / PENERIMA TAUTAN PATUNGAN PINTAR (WEB INVOICE / DEEP LINK)
/// ============================================================================
/// Ini adalah layar yang dilihat oleh teman/anggota saat mereka mengeklik tautan
/// patungan yang dibagikan via WhatsApp/chat (misal: pundigo.id/split/bill-100k).
///
/// Fitur Utama:
/// 1. Mock URL Browser: https://pundigo.id/split/aroma-nusantara-100k (simulasi web/deep link).
/// 2. Header Inisiator: Dinda Syahfitri menagih bagian makan bersama.
/// 3. Rincian Struk: Kedai Kopi & Resto Nusantara (Total Rp 100.000 ÷ 4 orang).
/// 4. Tagihan Personal Teman: Rp 25.000.
/// 5. Status Real-time: PENDING ➔ berubah menjadi LUNAS ✓ setelah dibayar.
/// 6. Integrasi Dana: Otomatis masuk ke "Kas Kelompok 3 RPL".
/// 7. Pilihan Bayar: Saldo PundiGo! (dengan PIN otorisasi) atau QRIS / Bank Lain.
/// ============================================================================
class SharedPatunganScreen extends StatefulWidget {
  final double totalAmount;
  final double personalShare;
  final String placeName;
  final String initiatorName;
  final String destinationKas;

  const SharedPatunganScreen({
    super.key,
    this.totalAmount = 100000,
    this.personalShare = 25000,
    this.placeName = 'Kedai Kopi & Resto Aroma Nusantara',
    this.initiatorName = 'Taufiq',
    this.destinationKas = 'Kas Kelompok 3 RPL',
  });

  @override
  State<SharedPatunganScreen> createState() => _SharedPatunganScreenState();
}

class _SharedPatunganScreenState extends State<SharedPatunganScreen> {
  bool _isPaid = false;
  String _selectedPaymentMethod = 'PundiGo!'; // PundiGo!, QRIS, Transfer Bank
  String _enteredPin = '';
  bool _isPaying = false;

  void _onPayPressed() {
    if (_selectedPaymentMethod == 'PundiGo!') {
      _showPinBottomSheet();
    } else {
      _showOtherPaymentDialog();
    }
  }

  void _showPinBottomSheet() {
    setState(() {
      _enteredPin = '';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetCtx, setSheetState) {
            void onDigit(String d) {
              if (_enteredPin.length < 6) {
                setSheetState(() {
                  _enteredPin += d;
                });
                if (_enteredPin.length == 6) {
                  _executePayment(ctx);
                }
              }
            }

            void onDelete() {
              if (_enteredPin.isNotEmpty) {
                setSheetState(() {
                  _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
                });
              }
            }

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_rounded, color: Color(0xFF00A887), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Konfirmasi PIN PundiGo!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Bayar tagihan Rp 25.000 ke ${widget.destinationKas}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 6 Bulatan PIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < _enteredPin.length;
                      return Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? const Color(0xFF00A887) : const Color(0xFFE2E8F0),
                          border: Border.all(
                            color: isFilled ? const Color(0xFF00796B) : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 14),

                  // Tombol Cepat Pengujian
                  GestureDetector(
                    onTap: () {
                      setSheetState(() {
                        _enteredPin = '171717';
                      });
                      _executePayment(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on_rounded, size: 13, color: Color(0xFF00A887)),
                          const SizedBox(width: 4),
                          Text(
                            '⚡ Otorisasi Cepat (Isi 171717)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00A887),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  NumericKeyboard(
                    onKeyPressed: onDigit,
                    onDeletePressed: onDelete,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _executePayment(BuildContext bottomSheetContext) {
    Navigator.of(bottomSheetContext).pop();

    setState(() {
      _isPaying = true;
    });

    // Simulasi proses potong saldo & catat ke kas
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isPaid = true;
          _isPaying = false;
        });

        // Update kas di AppState jika belum
        AppState.instance.executePatunganKeKas(
          totalAmount: widget.totalAmount,
          personalAmount: widget.personalShare,
          placeName: widget.placeName,
          kasTitle: widget.destinationKas,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Pembayaran Berhasil! Tagihan Lunas ✓ & dana langsung masuk ke Kas Kelompok.'),
                ),
              ],
            ),
            backgroundColor: Color(0xFF00A887),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showOtherPaymentDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: Color(0xFF00A887), size: 24),
              const SizedBox(width: 10),
              Text(
                'Pembayaran QRIS / Lainnya',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/pundigo_qris_master.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_rounded, size: 100, color: Color(0xFF00A887)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Pindai QRIS di atas menggunakan mobile banking atau e-wallet apa pun untuk membayar Rp 25.000.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Tutup',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A887),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                setState(() {
                  _isPaid = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran QRIS terverifikasi lunas ✓!'),
                    backgroundColor: Color(0xFF00A887),
                  ),
                );
              },
              child: Text(
                'Simulasi Lunas ✓',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PundigoBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===============================================================
              // 1. SIMULASI URL BROWSER / DEEP LINK HEADER
              // ===============================================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, size: 13, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'pundigo.id/split/aroma-nusantara-100k',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11.5,
                                  color: const Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const PgLogo(size: 24),
                  ],
                ),
              ),

              // ===============================================================
              // 2. KONTEN UTAMA TAGIHAN TEMAN
              // ===============================================================
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Tautan Resmi
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFF00A887)),
                              const SizedBox(width: 6),
                              Text(
                                'Tagihan Patungan Pintar PundiGo!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00897B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Kartu Informasi Inisiator
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00A887), Color(0xFF0288D1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00A887).withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFDCE4FD),
                                  child: Text(
                                    'DS',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF00796B),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.initiatorName,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'Mengirimkan tagihan makan bersama',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.placeName,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // KARTU RINCIAN TAGIHAN & NOMINAL BEBAN TEMAN
                      // =======================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tagihan Bagian Anda',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                // Badge Status Pembayaran
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isPaid ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                                        size: 13,
                                        color: _isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isPaid ? 'LUNAS ✓' : 'PENDING',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: _isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp 25.000',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),

                            // Detail Perhitungan Struk
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Struk Belanja:',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                                ),
                                Text(
                                  'Rp 100.000',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sistem Pembagian:',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                                ),
                                Text(
                                  'Bagi Rata (4 Orang)',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF00796B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tujuan Saldo:',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.folder_shared_rounded, size: 14, color: Color(0xFF00A887)),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.destinationKas,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF00A887)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =======================================================
                      // METODE PEMBAYARAN FLEKSIBEL (JIKA BELUM LUNAS)
                      // =======================================================
                      if (!_isPaid) ...[
                        Text(
                          'Pilih Metode Pembayaran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Opsi 1: PundiGo! E-Wallet
                        _buildPaymentOptionTile(
                          id: 'PundiGo!',
                          title: 'Dompet PundiGo!',
                          subtitle: 'Saldo Aktif Terhubung • 1-Klik Otorisasi PIN',
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF00A887),
                          badge: 'Rekomendasi',
                        ),
                        const SizedBox(height: 8),

                        // Opsi 2: QRIS
                        _buildPaymentOptionTile(
                          id: 'QRIS',
                          title: 'QRIS Universal (BCA, GoPay, OVO, dll)',
                          subtitle: 'Pindai kode QR dari aplikasi bank/dompet apa pun',
                          icon: Icons.qr_code_rounded,
                          iconColor: const Color(0xFF0288D1),
                        ),

                        const SizedBox(height: 24),

                        // Tombol Aksi Utama Bayar
                        InkWell(
                          onTap: _isPaying ? null : _onPayPressed,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00BFA5), Color(0xFF1E88E5)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00BFA5).withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isPaying
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Bayar Rp 25.000 Sekarang',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // =====================================================
                        // JIKA SUDAH LUNAS: BUKTI DIGITAL & TAUTAN KE KAS
                        // =====================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
                              const SizedBox(height: 8),
                              Text(
                                'Pembayaran Anda Berhasil!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF14532D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dana Rp 25.000 telah diteruskan secara otomatis ke Buku Kas Kelompok 3 RPL.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF15803D)),
                              ),
                              const SizedBox(height: 14),

                              // Tombol ke Buku Kas Kelompok
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A887),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SharedKasScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 18),
                                label: Text(
                                  'Buka Buku Kas Kelompok 3 RPL ➔',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Shortcut Demo Cepat ke Saku Kas
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SharedKasScreen()),
                            );
                          },
                          icon: const Icon(Icons.link_rounded, size: 16, color: Color(0xFF00A887)),
                          label: Text(
                            'Lihat Tampilan Teman saat Membuka Link Kas ➔',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00A887),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badge,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BFA5) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A887),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF00BFA5) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

