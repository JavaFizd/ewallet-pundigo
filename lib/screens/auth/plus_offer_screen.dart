import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common/pg_logo.dart';
import '../main_navigation_screen.dart';
import '../kyc/kyc_ktp_guide_screen.dart';
import '../kyc/kyc_face_scan_screen.dart';

/// ============================================================================
/// HALAMAN PENAWARAN PUNDIGO! PLUS (100% PERSIS DESAIN FIGMA RESMI)
/// ============================================================================
/// Sesuai tangkapan layar desain Figma:
/// 1. Top Bar: Teks 'PundiGo! Plus' di kiri & logo PG di kanan pada bar lembut.
/// 2. Badge Status: Lingkaran mint toska dengan centang [✓ PIN akun berhasil dibuat].
/// 3. Judul Besar: 'Kenalan dengan \n PundiGo! Plus' & subjudul verifikasi identitas.
/// 4. Kartu Gradien Fitur Plus: Aset vektor asli [plus_offer_card_exact.png] (816x264).
/// 5. Kartu Persyaratan: Tata letak kompak, bersih tanpa garis patah / cacat visual.
/// 6. Catatan penjelas: 'Bisa lanjut tanpa upgrade sekarang. Tingkatkan ke Plus nanti saat kamu siap.'
/// 7. Tombol Utama: 'Tingkatkan ke Plus ➔' (Gradien toska-biru).
/// 8. Tombol Sekunder: 'Nanti saja'.
/// ============================================================================
class PlusOfferScreen extends StatelessWidget {
  const PlusOfferScreen({super.key});

  void _skipToDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  void _upgradeToPlus(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KycKtpGuideScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // 1. TOP BAR DENGAN BACKGROUND LEMBUT (PERSIS FIGMA)
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFF1F5F9), // Soft slate header sesuai desain
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'PundiGo! Plus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const PgLogo(size: 26),
                ],
              ),
            ),

            // =================================================================
            // 2. KONTEN DENGAN TATA LETAK PRESISI FIGMA
            // =================================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge: ✓ PIN akun berhasil dibuat (Centang Hijau Mint Pasti Tampil)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD1FADF), // Soft mint green circle
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF00A887), // Emerald checkmark
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PIN akun berhasil dibuat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00897B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Judul Besar & Subjudul
                    Text(
                      'Kenalan dengan\nPundiGo! Plus',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Mau akses lebih? Tingkatkan akunmu dengan verifikasi identitas.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================================================
                    // 3. KARTU GRADIEN RESMI FIGMA (ASET EXACT 816x264)
                    // =========================================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BFA5).withOpacity(0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/plus_offer_card_exact.png',
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================================================
                    // 4. KARTU PERSYARATAN (TATA LETAK BERSIH & RAPI SESUAI FIGMA)
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Untuk jadi Plus, siapkan:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Verifikasi identitas saat kamu siap.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Syarat 1: KTP milikmu
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const KycKtpGuideScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const _KtpRequirementIcon(),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'KTP milikmu',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Scan atau foto KTP yang jelas.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Syarat 2: Wajah / selfie (Bebas dari cacat garis bawah)
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const KycFaceScanScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const _FaceRequirementIcon(),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Wajah / selfie',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Verifikasi wajah untuk cocokkan identitas.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Catatan Penjelas Bawah
                    Center(
                      child: Text(
                        'Bisa lanjut tanpa upgrade sekarang.\nTingkatkan ke Plus nanti saat kamu siap.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tombol 1: Tingkatkan ke Plus ➔
                    InkWell(
                      onTap: () => _upgradeToPlus(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00BFA5), Color(0xFF2979FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BFA5).withOpacity(0.32),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tingkatkan ke Plus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tombol 2: Nanti saja
                    Center(
                      child: InkWell(
                        onTap: () => _skipToDashboard(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Text(
                            'Nanti saja',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00A887),
                            ),
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
    );
  }
}

/// Ikon Vektor Presisi "KTP milikmu" (Persis Figma Penawaran PundiGo PLus.png)
class _KtpRequirementIcon extends StatelessWidget {
  const _KtpRequirementIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(22, 22),
          painter: _KtpIconPainter(),
        ),
      ),
    );
  }
}

class _KtpIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF0D9488);
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Body
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.18, size.width * 0.76, size.height * 0.74),
      const Radius.circular(4.5),
    );
    canvas.drawRRect(rrect, strokePaint);

    // Top loop
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.06),
      Offset(size.width * 0.36, size.height * 0.20),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.64, size.height * 0.06),
      Offset(size.width * 0.64, size.height * 0.20),
      strokePaint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.44),
      size.width * 0.14,
      strokePaint,
    );

    // Shoulders
    final shoulders = Path();
    shoulders.moveTo(size.width * 0.26, size.height * 0.80);
    shoulders.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.62,
      size.width * 0.74,
      size.height * 0.80,
    );
    canvas.drawPath(shoulders, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ikon Vektor Presisi "Wajah / selfie" (Persis Figma Penawaran PundiGo PLus.png)
class _FaceRequirementIcon extends StatelessWidget {
  const _FaceRequirementIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(22, 22),
          painter: _FaceScanPainter(),
        ),
      ),
    );
  }
}

class _FaceScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF0D9488);
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const cornerLen = 5.0;

    // Top-Left corner
    canvas.drawLine(Offset(size.width * 0.14, size.height * 0.14 + cornerLen), Offset(size.width * 0.14, size.height * 0.14), strokePaint);
    canvas.drawLine(Offset(size.width * 0.14, size.height * 0.14), Offset(size.width * 0.14 + cornerLen, size.height * 0.14), strokePaint);

    // Top-Right corner
    canvas.drawLine(Offset(size.width * 0.86 - cornerLen, size.height * 0.14), Offset(size.width * 0.86, size.height * 0.14), strokePaint);
    canvas.drawLine(Offset(size.width * 0.86, size.height * 0.14), Offset(size.width * 0.86, size.height * 0.14 + cornerLen), strokePaint);

    // Bottom-Left corner
    canvas.drawLine(Offset(size.width * 0.14, size.height * 0.86 - cornerLen), Offset(size.width * 0.14, size.height * 0.86), strokePaint);
    canvas.drawLine(Offset(size.width * 0.14, size.height * 0.86), Offset(size.width * 0.14 + cornerLen, size.height * 0.86), strokePaint);

    // Bottom-Right corner
    canvas.drawLine(Offset(size.width * 0.86 - cornerLen, size.height * 0.86), Offset(size.width * 0.86, size.height * 0.86), strokePaint);
    canvas.drawLine(Offset(size.width * 0.86, size.height * 0.86), Offset(size.width * 0.86, size.height * 0.86 - cornerLen), strokePaint);

    // Two Eyes
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.44), 1.6, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.44), 1.6, fillPaint);

    // Smiling Mouth
    final smile = Path();
    smile.moveTo(size.width * 0.36, size.height * 0.60);
    smile.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.74,
      size.width * 0.64,
      size.height * 0.60,
    );
    canvas.drawPath(smile, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
