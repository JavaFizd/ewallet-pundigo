import 'package:flutter/material.dart';

/// ============================================================================
/// BACKGROUND RESMI PUNDIGO (GRADASI AMBIENT ASLI FIGMA 'UNTITLED')
/// ============================================================================
/// Latar belakang otentik sesuai desain di folder figma_designs/Untitled:
/// - Pendaran lembut biru langit (#DAF4FF) di sudut atas.
/// - Area tengah putih bersih (#F8F9FE).
/// - Pendaran lembut mint/toska (#CEFAF0) di sudut bawah.
/// ============================================================================
class PundigoBackground extends StatelessWidget {
  final Widget child;

  const PundigoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FF),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Asli Figma dari folder Untitled
          Positioned.fill(
            child: Image.asset(
              'assets/images/pundigo_splash_bg.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          // Konten Utama Layar
          child,
        ],
      ),
    );
  }
}
