import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'kyc_ktp_camera_screen.dart';

/// ============================================================================
/// 1. PANDUAN PENGAMBILAN FOTO KTP (SESUAI FIGMA: Frame-3.png)
/// ============================================================================
class KycKtpGuideScreen extends StatelessWidget {
  const KycKtpGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: const CustomAppBar(title: 'Scan KTP'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Judul
              Text(
                'Foto KTP Asli',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Posisikan kartu di tengah bingkai kamera.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 20),

              // =============================================================
              // ILUSTRASI BINGKAI SCAN KTP (MINIMALIS & NATURAL / HUMAN UI DESIGN)
              // =============================================================
              Center(
                child: Container(
                  width: double.infinity,
                  height: 185,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 4 Sudut Siku Kamera Bersih (Corner Brackets)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFF00A887), width: 2.5),
                              left: BorderSide(color: Color(0xFF00A887), width: 2.5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFF00A887), width: 2.5),
                              right: BorderSide(color: Color(0xFF00A887), width: 2.5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF00A887), width: 2.5),
                              left: BorderSide(color: Color(0xFF00A887), width: 2.5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFF00A887), width: 2.5),
                              right: BorderSide(color: Color(0xFF00A887), width: 2.5),
                            ),
                          ),
                        ),
                      ),

                      // Kartu e-KTP Siluet Wireframe Murni (Standar Desain Figma Human UI)
                      Container(
                        width: 280,
                        height: 135,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Siluet Garis Identitas Sisi Kiri (Tanpa Teks / Nama)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Siluet Header Kecil
                                  Container(
                                    width: 38,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A887).withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(3.5),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  // Siluet NIK
                                  Container(
                                    width: 135,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF94A3B8),
                                      borderRadius: BorderRadius.circular(4.5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Siluet Nama
                                  Container(
                                    width: 95,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCBD5E1),
                                      borderRadius: BorderRadius.circular(3.5),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  // Siluet Baris Informasi 1
                                  Container(
                                    width: 120,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Siluet Baris Informasi 2
                                  Container(
                                    width: 75,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Kotak Pas Foto Siluet di Kanan (Tanpa Teks)
                            Container(
                              width: 62,
                              height: 84,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                              ),
                              child: Center(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2E8F0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 22,
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
              ),

              const SizedBox(height: 24),

              // Bagian Petunjuk Pengambilan Foto
              Text(
                'PETUNJUK PENGAMBILAN FOTO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 14),

              // Poin 1
              _buildGuideItem(
                icon: Icons.credit_card_rounded,
                iconColor: const Color(0xFF00BFA5),
                bgColor: const Color(0xFFE6F8F5),
                title: 'e-KTP Asli Fisik',
                description: 'Gunakan kartu asli fisik, bukan salinan fotokopi atau hasil cetak kertas.',
              ),
              const SizedBox(height: 12),

              // Poin 2
              _buildGuideItem(
                icon: Icons.crop_free_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                title: 'Presisi 4 Sudut',
                description: 'Pastikan seluruh sudut KTP masuk ke dalam bingkai kamera dan tidak terpotong.',
              ),
              const SizedBox(height: 12),

              // Poin 3
              _buildGuideItem(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                title: 'Bebas Pantulan Cahaya',
                description: 'NIK dan nama jelas terbaca, hindari silau lampu langsung maupun bayangan gelap.',
              ),

              const SizedBox(height: 20),

              // Kotak Enkripsi & Regulasi BI (Persis Figma)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security_rounded, size: 20, color: Color(0xFF059669)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data Anda terlindungi enkripsi 256-bit dan diawasi sesuai regulasi sistem pembayaran Bank Indonesia.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Tombol Buka Kamera & Scan KTP
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const KycKtpCameraScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFA5), Color(0xFF1E88E5)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BFA5).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Buka Kamera & Scan KTP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
