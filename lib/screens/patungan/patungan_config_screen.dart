import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common/pg_logo.dart';
import 'patungan_payment_screen.dart';

/// ============================================================================
/// ALUR PATUNGAN PINTAR - LAYAR 2: KONFIGURASI PEMBAGIAN & REKENING TUJUAN
/// ============================================================================
/// Spesifikasi Pengguna:
/// - Header: Judul "Atur Pembagian & Tujuan Dana".
/// - Pilihan Sistem Pembagian: Terpilih opsi "Bagi Rata Otomatis" (4 Orang = @Rp 25.000 / orang).
/// - Kotak Tujuan Saldo Masuk: Switch toggle aktif "Otomatis Masukkan ke Saku Kelompok" (Terpilih: Kas Kelompok 3 RPL).
/// - Indikator Status Sistem: Menampilkan status tagihan awal bernilai "PENDING (0/4 Terbayar)".
/// - Tombol utama: "Terbitkan Tagihan Kelompok ➔".
/// ============================================================================
class PatunganConfigScreen extends StatefulWidget {
  final String placeName;
  final double totalBill;
  final List<Map<String, dynamic>> items;

  const PatunganConfigScreen({
    super.key,
    required this.placeName,
    required this.totalBill,
    required this.items,
  });

  @override
  State<PatunganConfigScreen> createState() => _PatunganConfigScreenState();
}

class _PatunganConfigScreenState extends State<PatunganConfigScreen> {
  // Toggle switch aktif: Otomatis Masukkan ke Saku Kelompok
  bool _autoSyncToKas = true;

  // Daftar 4 Anggota Patungan (@Rp 25.000)
  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Taufiq (Saya)',
      'role': 'Penyelenggara / Penyetor',
      'share': 25000,
      'status': 'PENDING',
      'avatar': 'DS',
      'isSelf': true,
    },
    {
      'name': 'Naufal Daffa',
      'role': 'Anggota Kelompok',
      'share': 25000,
      'status': 'PENDING',
      'avatar': 'ND',
      'isSelf': false,
    },
    {
      'name': 'Maya Lestari',
      'role': 'Anggota Kelompok',
      'share': 25000,
      'status': 'PENDING',
      'avatar': 'ML',
      'isSelf': false,
    },
    {
      'name': 'Rahmat Hidayat',
      'role': 'Anggota Kelompok',
      'share': 25000,
      'status': 'PENDING',
      'avatar': 'RH',
      'isSelf': false,
    },
  ];

  void _proceedToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatunganPaymentScreen(
          placeName: widget.placeName,
          totalBill: widget.totalBill,
          personalShare: 25000,
          kasName: 'Kas Kelompok 3 RPL',
          members: _members,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1E293B)),
        ),
        title: Text(
          'Atur Pembagian & Tujuan Dana',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Center(child: PgLogo(size: 26)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // 1. KARTU TOTAL TAGIHAN STRUK
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00A887), Color(0xFF00BFA5), Color(0xFF1E88E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A887).withOpacity(0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storefront_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.placeName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp 100.000',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '3 Menu Struk • 4 Orang Anggota',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  color: Colors.white.withOpacity(0.92),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================================================
                    // 2. PILIHAN SISTEM PEMBAGIAN: "BAGI RATA OTOMATIS"
                    // =========================================================
                    Text(
                      'Sistem Pembagian',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00BFA5), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A887),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.balance_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Bagi Rata Otomatis',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A887),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Terpilih',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Rp 100.000 ÷ 4 Orang = @Rp 25.000 / orang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF00796B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF00A887), size: 22),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================================================
                    // 3. KOTAK TUJUAN SALDO MASUK: SAKU KELOMPOK 3 RPL
                    // =========================================================
                    Text(
                      'Tujuan Dana Patungan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F7F4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: Color(0xFF00A887),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Otomatis Masukkan ke Saku Kelompok',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Dana patungan langsung menambah saldo kas',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch.adaptive(
                                value: _autoSyncToKas,
                                activeColor: const Color(0xFF00A887),
                                onChanged: (val) {
                                  setState(() {
                                    _autoSyncToKas = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFFE2E8F0)),
                          // Rekening Tujuan Terpilih
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF3FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.folder_shared_rounded, color: Color(0xFF1E88E5), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kas Kelompok 3 RPL',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Saldo saat ini: Rp 250.000',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F7F4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Terhubung ✓',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00A887),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =========================================================
                    // 4. INDIKATOR STATUS SISTEM & DAFTAR 4 ANGGOTA
                    // =========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Beban Tagihan Anggota (4 Orang)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        // Indikator Status Sistem: "PENDING (0/4 Terbayar)"
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEA580C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'PENDING (0/4 Terbayar)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFC2410C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Daftar 4 Anggota
                    ...List.generate(_members.length, (index) {
                      final m = _members[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: m['isSelf'] ? const Color(0xFFE0F7F4) : const Color(0xFFEBF3FE),
                              child: Text(
                                m['avatar'] as String,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: m['isSelf'] ? const Color(0xFF00796B) : const Color(0xFF1E88E5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['name'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    m['role'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp 25.000',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Menunggu Bayar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF97316),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // =================================================================
            // 5. TOMBOL UTAMA: "Terbitkan Tagihan Kelompok ➔"
            // =================================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: InkWell(
                onTap: _proceedToPayment,
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
                          'Terbitkan Tagihan Kelompok',
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
            ),
          ],
        ),
      ),
    );
  }
}

