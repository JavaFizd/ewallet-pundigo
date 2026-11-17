import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/app_state.dart';
import '../../widgets/common/pg_logo.dart';
import '../../widgets/common/pundigo_background.dart';

/// ============================================================================
/// TAMPILAN TEMAN / PENERIMA TAUTAN SAKU KAS KELOMPOK (WEB / DEEP LINK)
/// ============================================================================
/// Ini adalah layar yang dilihat oleh teman/anggota saat mereka mengeklik tautan
/// Saku Kas Kelompok yang dibagikan (misal: pundigo.id/kas/kelompok-3-rpl).
///
/// Fitur Utama:
/// 1. Mock URL Browser: https://pundigo.id/kas/kelompok-3-rpl.
/// 2. Header Kas: Saku Kelompok 3 RPL (Dikelola oleh Taufiq).
/// 3. Saldo Kas Real-time: Rp 350.000 (Target Rp 500.000, 70% Tercapai).
/// 4. Anggota Aktif: 4 Orang.
/// 5. Aksi Teman:
///    - Setor Iuran Kas (Pilihan nominal Rp 10.000, Rp 25.000, Rp 50.000).
///    - Gabung Menjadi Anggota Kas Ini.
/// 6. Buku Kas Terbuka: Riwayat mutasi transparan real-time.
/// ============================================================================
class SharedKasScreen extends StatefulWidget {
  final String kasId;

  const SharedKasScreen({super.key, this.kasId = 'kas_rpl_03'});

  @override
  State<SharedKasScreen> createState() => _SharedKasScreenState();
}

class _SharedKasScreenState extends State<SharedKasScreen> {
  final AppState _appState = AppState.instance;
  int _selectedAmount = 25000;
  bool _isJoined = false;

  @override
  Widget build(BuildContext context) {
    final kas = _appState.kasKelompok;
    final mutasiList = _appState.kasMutasi;

    final progress = (kas.collectedAmount / kas.targetAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: PundigoBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ===============================================================
              // 1. SIMULASI URL BROWSER / DEEP LINK HEADER
              // ===============================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'pundigo.id/kas/kelompok-3-rpl',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11.5,
                                  color: const Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const PgLogo(size: 24),
                  ],
                ),
              ),

              // ===============================================================
              // 2. KONTEN UTAMA SAKU KAS KELOMPOK
              // ===============================================================
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Undangan Kas
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00BFA5).withOpacity(0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.groups_rounded,
                                size: 14,
                                color: Color(0xFF00A887),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Saku Kas Kelompok Terbuka PundiGo!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00897B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Card Saldo & Target Kas
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00A887), Color(0xFF0288D1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00A887).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
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
                                    const Icon(
                                      Icons.folder_shared_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      kas.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${kas.memberCount} Anggota',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Saldo Kas Terkumpul',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${kas.collectedAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Progress Bar Target Kas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progres Target (Rp 500.000)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.white.withOpacity(0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // AKSI TEMAN: SETOR IURAN KAS
                      // =======================================================
                      Text(
                        'Setor Iuran ke Kas Kelompok Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Pilihan Nominal Cepat
                      Row(
                        children: [
                          _buildNominalChip(10000),
                          const SizedBox(width: 8),
                          _buildNominalChip(25000),
                          const SizedBox(width: 8),
                          _buildNominalChip(50000),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Tombol Eksekusi Setor Iuran
                      InkWell(
                        onTap: _executeSetorKas,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00BFA5), Color(0xFF1E88E5)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BFA5).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Setor Rp ${_selectedAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Sekarang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tombol Gabung Kas
                      if (!_isJoined)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00A887)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(double.infinity, 46),
                          ),
                          onPressed: () {
                            setState(() {
                              _isJoined = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selamat! Anda telah bergabung ke Saku Kelompok 3 RPL.',
                                ),
                                backgroundColor: Color(0xFF00A887),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Color(0xFF00A887),
                            size: 18,
                          ),
                          label: Text(
                            'Gabung Menjadi Anggota Kas Ini',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF00A887),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Anda Sudah Bergabung sebagai Anggota ✓',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 22),

                      // =======================================================
                      // BUKU KAS TRANSPARAN: LOG MUTASI REAL-TIME
                      // =======================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Riwayat Mutasi Kas Transparan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Live Log',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // List Entri Mutasi
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mutasiList.length,
                        itemBuilder: (context, index) {
                          final item = mutasiList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_downward_rounded,
                                    color: Color(0xFF16A34A),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        item.subtitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '+Rp ${item.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNominalChip(int amount) {
    final isSelected = _selectedAmount == amount;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAmount = amount;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE0F7F4)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00BFA5)
                  : const Color(0xFFCBD5E1),
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Center(
            child: Text(
              'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF00796B)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _executeSetorKas() {
    _appState.addKasContribution(
      _selectedAmount.toDouble(),
      uploader: 'Anggota (via Tautan Kas)',
    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Terima kasih! Iuran Rp ${_selectedAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} berhasil disetor ke Kas Kelompok.',
        ),
        backgroundColor: const Color(0xFF00A887),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
