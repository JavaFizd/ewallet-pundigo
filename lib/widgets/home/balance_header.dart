import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/user_model.dart';
import '../common/user_avatar.dart';

/// ============================================================================
/// HEADER SALDO UTAMA (100% PERSIS FIGMA DASHBOARD-3.png)
/// ============================================================================
/// - Gradien toska ke biru laut [#00BFA5 -> #0288D1] dengan lengkungan bawah (28dp).
/// - Avatar profil foto / inisial otomatis (misal AW untuk Arman Wijaya).
/// - Profil dan sapaan 'Halo, ...' interaktif dan dapat diklik untuk membuka layar profil.
/// - Tombol notifikasi lonceng putih di kanan atas.
/// - Baris Saldo Utama (Rp100.000 / nominal aktif) & tombol 'Dompet'.
/// - Badge status '● Akun Basic' putih dengan titik biru laut.
/// - Memberikan ruang tumpang tindih (54dp) untuk QuickActionsCard melayang.
/// ============================================================================
class BalanceHeader extends StatelessWidget {
  final UserModel user;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onDompetTap;
  final VoidCallback? onProfileTap;

  const BalanceHeader({
    super.key,
    required this.user,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
    this.onNotificationTap,
    this.onDompetTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF00A887),
            Color(0xFF00BFA5),
            Color(0xFF1E88E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 42, 16, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // Baris 1: Avatar & Sapaan User (Klik untuk Buka Profil), serta Notifikasi
                // -------------------------------------------------------------
                Row(
                  children: [
                    // Avatar & Sapaan User (Dapat Diklik ke Layar Profil)
                    Expanded(
                      child: InkWell(
                        onTap: onProfileTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // Avatar (Foto Pengguna atau Inisial Otomatis)
                              UserAvatar(
                                user: user,
                                radius: 22,
                                backgroundColor: const Color(0xFFDCE4FD),
                                textColor: const Color(0xFF00796B),
                              ),
                              const SizedBox(width: 12),

                              // Teks Sapaan & Nama
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Halo, ${user.name.split(' ').first}!',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.22),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.45),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            user.isPlus ? 'PLUS MEMBER' : 'MEMBER BARU',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.isPlus
                                          ? 'Senang melihatmu kembali!'
                                          : 'Selamat datang di PundiGo!',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white.withOpacity(0.92),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tombol Notifikasi Lonceng (Bersih tanpa bulatan)
                    InkWell(
                      onTap: onNotificationTap ?? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak ada notifikasi baru.')),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // -------------------------------------------------------------
                // Baris 2: Label Saldo Utama & Tombol Dompet
                // -------------------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Saldo Utama',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onToggleVisibility,
                          child: Icon(
                            isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withOpacity(0.92),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: onDompetTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white.withOpacity(0.92),
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Dompet',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.92),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // -------------------------------------------------------------
                // Baris 3: Angka Saldo Utama (Persis Figma: 'Rp100.000' tanpa spasi)
                // -------------------------------------------------------------
                Text(
                  isBalanceVisible
                      ? (user.saldoUtama == 0 ? 'Rp0' : CurrencyFormatter.format(user.saldoUtama))
                      : 'Rp••••••••',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 6),

                // -------------------------------------------------------------
                // Baris 4: Badge Akun Basic (Persis Figma DASHBOARD-3.png)
                // -------------------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: user.isPlus ? const Color(0xFF00BFA5) : const Color(0xFF0091EA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.isPlus ? '✦ PundiGo! Plus' : user.accountType,
                        style: GoogleFonts.plusJakartaSans(
                          color: user.isPlus ? const Color(0xFF00796B) : const Color(0xFF0091EA),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
}
