import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/in_app_notification.dart';
import '../../widgets/common/pundigo_background.dart';

/// ============================================================================
/// HUB SIMULASI TAMPILAN LINK TERPISAH (DEMO HUB PUNDIGO!)
/// ============================================================================
/// Halaman khusus untuk menjawab permintaan pengguna & dosen:
/// "aku mau semua yang berkaitan menurut kamu itu coba buat link terpisah agar
/// tau gimana tampilannya (kas, patungan, notif minta saldo, dan tampilan dimintai saldo)"
/// ============================================================================
class DemoLinksHubScreen extends StatelessWidget {
  const DemoLinksHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Katalog Tautan Simulasi'),
      body: PundigoBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A887), Color(0xFF1E88E5)],
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.language_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pusat Tautan Penerima',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Uji coba tampilan dari sudut pandang teman yang menerima tautan (Kas, Patungan, dan Minta Saldo).',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.92),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 1. TAMPILAN LINK SAKU KAS KELOMPOK
                // =============================================================
                _buildLinkCard(
                  context,
                  badge: 'KAS KELOMPOK',
                  badgeColor: const Color(0xFF00A887),
                  title: 'Tampilan Penerima Link Saku Kas',
                  urlRoute: '/shared-kas',
                  fullUrl: 'http://localhost:8888/#/shared-kas',
                  desc: 'Tampilan web saat teman membuka tautan kas kelompok: melihat saldo kas terkumpul (Rp 350.000), target, setor iuran kas, dan bukti nota transparan.',
                  icon: Icons.folder_shared_rounded,
                  iconColor: const Color(0xFF00A887),
                  bgColor: const Color(0xFFE6F8F5),
                ),

                const SizedBox(height: 14),

                // =============================================================
                // 2. TAMPILAN LINK PATUNGAN PINTAR
                // =============================================================
                _buildLinkCard(
                  context,
                  badge: 'PATUNGAN PINTAR (SPLIT BILL)',
                  badgeColor: const Color(0xFF2563EB),
                  title: 'Tampilan Penerima Link Patungan',
                  urlRoute: '/shared-patungan',
                  fullUrl: 'http://localhost:8888/#/shared-patungan',
                  desc: 'Tampilan invoice web saat teman ditagih makan bersama oleh Taufiq: melihat rincian struk (Rp 100.000), bagian tagihan personal (Rp 25.000), dan tombol bayar langsung via PundiGo / QRIS.',
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),

                const SizedBox(height: 14),

                // =============================================================
                // 3. TAMPILAN ORANG YANG DIMINTAI SALDO
                // =============================================================
                _buildLinkCard(
                  context,
                  badge: 'MINTA SALDO (PAYMENT REQUEST)',
                  badgeColor: const Color(0xFFD97706),
                  title: 'Tampilan Orang yang Dimintai Saldo',
                  urlRoute: '/minta-saldo',
                  fullUrl: 'http://localhost:8888/#/minta-saldo',
                  desc: 'Tampilan saat teman dimintai saldo oleh Taufiq: melihat profil peminta, nominal Rp 50.000, catatan, serta opsi "Kirim Saldo Sekarang" atau "Tolak Permintaan".',
                  icon: Icons.call_received_rounded,
                  iconColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                ),

                const SizedBox(height: 14),

                // =============================================================
                // 4. SIMULASI NOTIFIKASI MINTA SALDO MASUK
                // =============================================================
                _buildLinkCard(
                  context,
                  badge: 'NOTIFIKASI SISTEM',
                  badgeColor: const Color(0xFF7C3AED),
                  title: 'Simulasi Notifikasi Minta Saldo Masuk',
                  urlRoute: '/notif-minta-saldo',
                  fullUrl: 'http://localhost:8888/#/notif-minta-saldo',
                  desc: 'Simulasi notifikasi push sistem di layar HP teman saat Taufiq meminta saldo: "🔔 Taufiq Meminta Saldo Rp 50.000" dengan tombol cepat untuk meninjau dan bayar.',
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFF3E8FF),
                ),

                const SizedBox(height: 24),

                // Tombol Kembali ke Aplikasi Utama
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/main'),
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: Text(
                      'Kembali ke Beranda Utama PundiGo!',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context, {
    required String badge,
    required Color badgeColor,
    required String title,
    required String urlRoute,
    required String fullUrl,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Baris URL & Salin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fullUrl,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: fullUrl));
                    InAppNotification.show(
                      context,
                      title: 'Tautan Disalin!',
                      message: '$fullUrl siap dibuka di tab baru.',
                      icon: Icons.link_rounded,
                      iconColor: const Color(0xFF00A887),
                      iconBg: const Color(0xFFE6F8F5),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF00A887)),
                        const SizedBox(width: 3),
                        Text(
                          'Salin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00A887),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Tombol Buka Tampilan
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: badgeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pushNamed(urlRoute),
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
              label: Text(
                'Buka Tampilan Halaman Ini ➔',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
