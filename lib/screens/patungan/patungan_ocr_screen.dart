import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common/pg_logo.dart';
import 'patungan_config_screen.dart';

/// ============================================================================
/// ALUR PATUNGAN PINTAR - LAYAR 1: PEMINDAIAN STRUK & DETEKSI OTOMATIS (OCR)
/// ============================================================================
/// Spesifikasi Pengguna:
/// - Tampilan frame kamera pemindaian struk dengan kotak fokus deteksi teks.
/// - Panel bawah: Hasil pembacaan sistem otomatis yang mengekstrak rincian belanja,
///   nama tempat, dan Total Tagihan: "Rp 100.000".
/// - Tombol utama: "Gunakan Tagihan Ini ➔".
/// ============================================================================
class PatunganOcrScreen extends StatefulWidget {
  const PatunganOcrScreen({super.key});

  @override
  State<PatunganOcrScreen> createState() => _PatunganOcrScreenState();
}

class _PatunganOcrScreenState extends State<PatunganOcrScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  void _proceedToConfig() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PatunganConfigScreen(
          placeName: 'Cafe Nongkrong 3 RPL',
          totalBill: 100000,
          items: [
            {'name': '2x Paket Nasi Ayam Geprek', 'price': 50000},
            {'name': '2x Es Kopi Susu Gula Aren', 'price': 30000},
            {'name': '2x Kentang Goreng Crispy', 'price': 20000},
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark viewfinder backdrop
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // 1. TOP BAR
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Pindai Struk Kasir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Deteksi Teks Otomatis (OCR)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const PgLogo(size: 28),
                ],
              ),
            ),

            // =================================================================
            // 2. VIEWFINDER KAMERA DENGAN STRUK DAN ANIMASI LASER SCANNER
            // =================================================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.maxWidth;
                    final boxHeight = constraints.maxHeight;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Gambar Mockup Struk Kasir di dalam viewfinder
                        Container(
                          width: boxWidth * 0.88,
                          height: boxHeight * 0.94,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDFDFD),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Struk
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '☕ CAFE NONGKRONG 3 RPL',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Jl. Mahasiswa Kampus No. 3 • Meja 07',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(color: Color(0xFFCBD5E1), thickness: 1),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Baris Item 1
                              _buildReceiptItemRow(
                                title: '2x Nasi Ayam Geprek',
                                price: 'Rp 50.000',
                                isDetected: true,
                              ),
                              const SizedBox(height: 8),

                              // Baris Item 2
                              _buildReceiptItemRow(
                                title: '2x Es Kopi Susu Aren',
                                price: 'Rp 30.000',
                                isDetected: true,
                              ),
                              const SizedBox(height: 8),

                              // Baris Item 3
                              _buildReceiptItemRow(
                                title: '2x Kentang Goreng Crispy',
                                price: 'Rp 20.000',
                                isDetected: true,
                              ),
                              const SizedBox(height: 10),

                              const Spacer(),
                              const Divider(color: Color(0xFFCBD5E1), thickness: 1),
                              const SizedBox(height: 4),

                              // Baris Total Struk
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL TAGIHAN',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F7F4),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF00BFA5)),
                                    ),
                                    child: Text(
                                      'Rp 100.000',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF00796B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),

                        // Frame Kotak Fokus Viewfinder dengan 4 Sudut Corner Hijau
                        Container(
                          width: boxWidth * 0.96,
                          height: boxHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00BFA5).withOpacity(0.55),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // Corner Brackets
                        Positioned(
                          top: 4,
                          left: 4,
                          child: _buildCornerBracket(isTop: true, isLeft: true),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: _buildCornerBracket(isTop: true, isLeft: false),
                        ),
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: _buildCornerBracket(isTop: false, isLeft: true),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: _buildCornerBracket(isTop: false, isLeft: false),
                        ),

                        // Garis Laser Scanning Animasi
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: boxHeight * _scanAnimation.value,
                              left: boxWidth * 0.05,
                              right: boxWidth * 0.05,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF00FFCC),
                                      Color(0xFF00BFA5),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withOpacity(0.8),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // =================================================================
            // 3. PANEL BAWAH: HASIL PEMBACAAN SISTEM OTOMATIS (OCR)
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge OCR Sukses
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                            const SizedBox(width: 5),
                            Text(
                              'OCR Otomatis Terdeteksi',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Akurasi 100%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Kartu Ringkasan Hasil Deteksi
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF00A887),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cafe Nongkrong 3 RPL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '3 Menu Pesanan • Makan Siang Bersama',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Baris Total Tagihan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Tagihan Struk',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'Rp 100.000',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00A887),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Siap Dibagikan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Tombol Utama: "Gunakan Tagihan Ini ➔"
                  InkWell(
                    onTap: _proceedToConfig,
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
                              'Gunakan Tagihan Ini',
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
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptItemRow({
    required String title,
    required String price,
    required bool isDetected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDetected ? const Color(0xFFE6F8F5).withOpacity(0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isDetected ? Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isDetected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_circle_outline_rounded, size: 13, color: Color(0xFF00A887)),
                ),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Color(0xFF00FFCC), width: 3.5) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Color(0xFF00FFCC), width: 3.5) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Color(0xFF00FFCC), width: 3.5) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Color(0xFF00FFCC), width: 3.5) : BorderSide.none,
        ),
      ),
    );
  }
}

