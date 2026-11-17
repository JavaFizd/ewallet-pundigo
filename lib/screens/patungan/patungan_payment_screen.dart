import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/app_state.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../../widgets/common/pg_logo.dart';
import 'patungan_kas_result_screen.dart';

/// ============================================================================
/// ALUR PATUNGAN PINTAR - LAYAR 3: EKSEKUSI PEMOTONGAN SALDO ANGGOTA
/// ============================================================================
/// Spesifikasi Pengguna:
/// - Header: Judul "Konfirmasi Potong Saldo".
/// - Rincian Beban Anggota: Tagihan personal sebesar "Rp 25.000" atas nama anggota.
/// - Validasi Otorisasi: Indikator input 6 digit PIN untuk mengeksekusi
///   pendebitan saldo PundiGo secara aman.
/// - Status Transaksi Sistem: Pembaruan real-time saat saldo didebit, status
///   tagihan anggota berubah dari "PENDING" menjadi "LUNAS ✓".
/// - Tombol utama: "Bayar & Catat ke Saku Kelompok ➔".
/// ============================================================================
class PatunganPaymentScreen extends StatefulWidget {
  final String placeName;
  final double totalBill;
  final double personalShare;
  final String kasName;
  final List<Map<String, dynamic>> members;

  const PatunganPaymentScreen({
    super.key,
    required this.placeName,
    required this.totalBill,
    required this.personalShare,
    required this.kasName,
    required this.members,
  });

  @override
  State<PatunganPaymentScreen> createState() => _PatunganPaymentScreenState();
}

class _PatunganPaymentScreenState extends State<PatunganPaymentScreen> {
  final AppState _appState = AppState.instance;
  String _enteredPin = '';

  // Status Real-Time Transaksi
  bool _isPaid = false;
  bool _isProcessing = false;

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 6 && !_isProcessing) {
      setState(() {
        _enteredPin += digit;
      });

      // Begitu PIN lengkap 6 digit, otomatis validasi otorisasi
      if (_enteredPin.length == 6) {
        _executePayment();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty && !_isProcessing) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _quickFillPin() {
    setState(() {
      _enteredPin = '170845';
    });
    _executePayment();
  }

  void _executePayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulasi otorisasi bank/fintech 600ms
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    // Perbarui status anggota menjadi LUNAS ✓ secara real-time
    setState(() {
      _isProcessing = false;
      _isPaid = true;
    });

    // Eksekusi mutasi di AppState:
    // 1. Potong saldo personal Dinda Rp 25.000
    // 2. Tambah kas kelompok 3 RPL menjadi Rp 350.000
    // 3. Catat mutasi "+Rp 100.000 dari Patungan Pintar Struk"
    _appState.executePatunganKeKas(
      totalAmount: widget.totalBill,
      personalAmount: widget.personalShare,
      placeName: widget.placeName,
      kasTitle: widget.kasName,
    );
  }

  void _navigateToKasResult() {
    if (!_isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan 6 digit PIN untuk mengeksekusi pembayaran.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PatunganKasResultScreen(
          kasName: widget.kasName,
          totalCollected: 350000,
          patunganAmount: widget.totalBill,
          placeName: widget.placeName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _appState.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1E293B)),
        ),
        title: Text(
          'Konfirmasi Potong Saldo',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(child: PgLogo(size: 26)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Column(
                  children: [
                    // =========================================================
                    // 1. KARTU RINCIAN BEBAN ANGGOTA (DINDA SYAHFITRI)
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isPaid ? const Color(0xFF00A887) : const Color(0xFFE2E8F0),
                          width: _isPaid ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFE0F7F4),
                                    child: Text(
                                      user.initials,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF00796B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Tagihan Personal Patungan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Indikator Status Transaksi: PENDING -> LUNAS ✓
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isPaid ? const Color(0xFFE8F8EE) : const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isPaid ? const Color(0xFF10B981) : const Color(0xFFF97316),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isPaid ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                                      size: 13,
                                      color: _isPaid ? const Color(0xFF10B981) : const Color(0xFFEA580C),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _isPaid ? 'LUNAS ✓' : 'PENDING',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: _isPaid ? const Color(0xFF065F46) : const Color(0xFFC2410C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 22, color: Color(0xFFE2E8F0)),

                          // Nominal Tagihan Personal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nominal Didebit',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rp 25.000',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF00A887),
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Tujuan Rekening Kas',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.kasName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E88E5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================================================
                    // 2. VALIDASI OTORISASI: INPUT 6 DIGIT PIN
                    // =========================================================
                    Text(
                      'Masukkan 6 Digit PIN PundiGo',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Otorisasi pendebitan saldo aman terenkripsi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 6 Bulatan PIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final isFilled = index < _enteredPin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: isFilled ? 18 : 16,
                          height: isFilled ? 18 : 16,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? (_isPaid ? const Color(0xFF10B981) : const Color(0xFF00BFA5))
                                : const Color(0xFFE2E8F0),
                            boxShadow: isFilled
                                ? [
                                    BoxShadow(
                                      color: (_isPaid ? const Color(0xFF10B981) : const Color(0xFF00BFA5))
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Tombol Bantuan Demo Isi PIN
                    if (!_isPaid)
                      GestureDetector(
                        onTap: _quickFillPin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F8F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 13, color: Color(0xFF00A887)),
                              const SizedBox(width: 4),
                              Text(
                                '⚡ Masukkan PIN (170845)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00A887),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Otorisasi Berhasil • Saldo Berhasil Didebit',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    // =========================================================
                    // 3. TOMBOL UTAMA: "Bayar & Catat ke Saku Kelompok ➔"
                    // =========================================================
                    InkWell(
                      onTap: _isPaid ? _navigateToKasResult : _executePayment,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isPaid ? 'Buka Buku Kas Kelompok' : 'Bayar & Catat ke Saku Kelompok',
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
                  ],
                ),
              ),
            ),

            // Numpad Keypad Angka Bersih di Bawah
            if (!_isPaid)
              NumericKeyboard(
                onKeyPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
              )
            else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

