import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ============================================================================
/// BINGKAI KANVAS FIGMA PUNDIGO! (1 LAYAR UTUH TANPA SCROLL - FULL ARTBOARD)
/// ============================================================================
/// - Mode Kanvas Figma (Aktif Default):
///   Tinggi frame dibuat panjang (1.180px) persis seperti Artboard di Figma.
///   Menggunakan FittedBox(fit: BoxFit.contain) sehingga SELURUH KONTEN
///   (Header, Kartu, Promo, hingga Bottom Nav Bar) langsung pas dalam 1 layar
///   monitor laptop pengguna TANPA PERLU SCROLL sama sekali!
/// - Tombol toggle di pojok atas untuk berganti ke Mode Ponsel Scroll biasa.
/// ============================================================================
class MobileFrame extends StatefulWidget {
  final Widget child;

  const MobileFrame({
    super.key,
    required this.child,
  });

  @override
  State<MobileFrame> createState() => _MobileFrameState();
}

class _MobileFrameState extends State<MobileFrame> {
  // Mode Kanvas Figma aktif secara default (Full-height artboard 1 layar pas)
  bool _isFigmaCanvasMode = true;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return widget.child;
    }

    if (_isFigmaCanvasMode) {
      // -----------------------------------------------------------------------
      // MODE KANVAS FIGMA: 1 LAYAR UTUH PANJANG LENGKAP TANPA PERLU SCROLL
      // -----------------------------------------------------------------------
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Latar gelap elegan seperti kanvas Figma
        body: Stack(
          children: [
            // Konten Aplikasi Pas 1 Layar
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Container(
                    width: 480,
                    height: 1180, // Tinggi panjang utuh seperti frame Figma
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 36,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: const Size(480, 1180),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),

            // Tombol Kontrol Mode di Pojok Atas
            Positioned(
              top: 14,
              left: 16,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isFigmaCanvasMode = !_isFigmaCanvasMode;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A887),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.aspect_ratio_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        '🎨 Mode Kanvas Figma (1 Layar Utuh)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'sans-serif',
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

    // -------------------------------------------------------------------------
    // MODE PONSEL NORMAL DENGAN SCROLL
    // -------------------------------------------------------------------------
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 480),
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
          Positioned(
            top: 14,
            left: 16,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isFigmaCanvasMode = !_isFigmaCanvasMode;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.smartphone_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '📱 Mode Ponsel Scroll (Klik untuk ganti ke Kanvas Figma)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'sans-serif',
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
}
