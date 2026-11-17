import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// BANNER PROMO RESMI PUNDIGO (100% ULTRA-HD VECTOR + HIGH-RES FIGMA 3D ASSET)
/// ============================================================================
/// - Tipografi & badge 100% Native Vector Flutter (tajam sempurna di layar 4K/Retina/Retina 120Hz).
/// - Gradien toska-ke-biru mulus satu kesatuan tanpa garis kotak/seam.
/// - Aset 3D kartu resmi Figma terintegrasi dalam resolusi 4x Ultra-HD (1584 x 452).
/// - Tombol 'Coba Sekarang ➔' presisi pixel-perfect sesuai desain asli Figma.
/// ============================================================================
class PromoBannerCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PromoBannerCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A887).withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.18),
            highlightColor: Colors.white.withOpacity(0.08),
            child: AspectRatio(
              aspectRatio: 396 / 113,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. High-Res 4x Seamless Background with 3D Illustration on the right
                  Image.asset(
                    'assets/images/promo_banner_bg_clean_hd.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),

                  // 2. Pure Crisp Vector Typography & Badges on the left
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = constraints.maxHeight / 113.0;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16.0 * scale,
                          11.0 * scale,
                          124.0 * scale,
                          11.0 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // #PROMO TERBAIK Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0 * scale,
                                vertical: 2.5 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(16.0 * scale),
                              ),
                              child: Text(
                                '#PROMO TERBAIK',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF1E293B),
                                  fontSize: 9.2 * scale,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            // Title: GRATIS TRANSFER ke Semua Bank!
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'GRATIS TRANSFER ke Semua Bank!',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12.8 * scale,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            // Subtitle: Bebas Biaya Admin, Kirim Uang Tanpa Batas
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Bebas Biaya Admin, Kirim Uang Tanpa Batas',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.92),
                                  fontSize: 9.0 * scale,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),

                            // Button: Coba Sekarang ➔
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.5 * scale,
                                vertical: 4.8 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.0 * scale),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4.0 * scale,
                                    offset: Offset(0, 1.5 * scale),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Coba Sekarang',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF00897B),
                                      fontSize: 9.8 * scale,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 4.0 * scale),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 11.5 * scale,
                                    color: const Color(0xFF00897B),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
