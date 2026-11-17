import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/currency_formatter.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/pundigo_background.dart';
import '../transactions/requested_balance_payment_screen.dart';

/// ============================================================================
/// SIMULASI NOTIFIKASI PERMINTAAN SALDO MASUK (TAMPILAN DI HP TEMAN)
/// ============================================================================
/// Menjawab permintaan pengguna:
/// "gimana kalo dimintai saldo, dan notif minta saldo itu dimana tampilannya"
/// Halaman ini menampilkan simulasi notifikasi sistem yang muncul di perangkat
/// penerima ketika Taufiq mengirimkan permintaan saldo.
/// ============================================================================
class NotificationMintaSaldoScreen extends StatelessWidget {
  final String requesterName;
  final double requestedAmount;
  final String requestNote;

  const NotificationMintaSaldoScreen({
    super.key,
    this.requesterName = 'Taufiq',
    this.requestedAmount = 50000,
    this.requestNote = 'Hai! Boleh minta transfer saldo Rp50.000 untuk patungan makan siang bareng tadi ya. Terima kasih banyak!',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: const CustomAppBar(title: 'Simulasi Notifikasi Masuk'),
      body: PundigoBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Penjelasan Rute
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00A887).withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF00796B), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ini adalah simulasi layar ponsel teman Anda saat menerima notifikasi permintaan saldo dari $requesterName.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF004D40),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =============================================================
                // KARTU NOTIFIKASI PUSH SISTEM (SEPERTI DI STATUS BAR HP)
                // =============================================================
                Text(
                  'NOTIFIKASI SISTEM (LOCK SCREEN / STATUS BAR)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RequestedBalancePaymentScreen(
                          requesterName: requesterName,
                          requestedAmount: requestedAmount,
                          requestNote: requestNote,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00A887).withOpacity(0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A887).withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00A887),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PUNDIGO! SECURITY',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF00897B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Baru saja',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFE0F7F4),
                              child: Text(
                                requesterName.isNotEmpty ? requesterName[0] : 'T',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00796B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$requesterName Meminta Saldo',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Nominal: ${CurrencyFormatter.format(requestedAmount)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00A887),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '"$requestNote"',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Ketuk untuk Meninjau & Bayar ➔',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00A887),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // =============================================================
                // RINCIAN AKSI TEMAN SAAT DIMINTAI SALDO
                // =============================================================
                Text(
                  'ALUR PENERIMA KETIKA MENGEKLIK NOTIFIKASI INI',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                _buildStepCard(
                  number: '1',
                  title: 'Melihat Profil Lengkap Peminta',
                  desc: 'Penerima dapat melihat nama lengkap ($requesterName), nomor HP, email, dan catatan tujuan permintaan.',
                ),
                const SizedBox(height: 10),
                _buildStepCard(
                  number: '2',
                  title: 'Memilih Aksi: Bayar atau Tolak',
                  desc: 'Penerima memiliki kendali penuh: bisa langsung menekan tombol "Kirim Saldo Sekarang" atau "Tolak Permintaan".',
                ),
                const SizedBox(height: 10),
                _buildStepCard(
                  number: '3',
                  title: 'Otorisasi PIN Keamanan 6 Digit',
                  desc: 'Saldo pengirim tidak akan terpotong sebelum memasukkan 6 digit PIN akun demi keamanan.',
                ),
                const SizedBox(height: 10),
                _buildStepCard(
                  number: '4',
                  title: 'Struk Resmi Digital Terbit',
                  desc: 'Begitu berhasil, struk transaksi resmi bertanda stempel LUNAS terbit otomatis dan saldo Taufiq langsung bertambah!',
                ),

                const SizedBox(height: 24),

                // Tombol Buka Halaman Dimintai Saldo
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A887),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RequestedBalancePaymentScreen(
                            requesterName: requesterName,
                            requestedAmount: requestedAmount,
                            requestNote: requestNote,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    label: Text(
                      'Buka Halaman Pembayaran Saldo ➔',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({required String number, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F7F4),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00796B),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
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
