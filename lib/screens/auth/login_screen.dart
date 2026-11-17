import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/pg_logo.dart';
import '../../widgets/common/pundigo_background.dart';
import 'login_otp_screen.dart';
import 'register_screen.dart';

/// ============================================================================
/// HALAMAN MASUK / LOGIN AKUN LAMA PUNDIGO!
/// ============================================================================
/// Alur Sesuai Permintaan:
/// 1. Masukkan Nomor Handphone dan Email terdaftar.
/// 2. Klik "Kirim Kode OTP ke Email ➔" untuk lanjut ke Verifikasi OTP.
/// 3. Dilengkapi tombol bantu "⚡ Isi Akun Terdaftar" untuk kemudahan demo.
/// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onTextChanged);
    _emailController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onTextChanged);
    _emailController.removeListener(_onTextChanged);
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Isi data demo akun yang sudah ada
  void _fillSampleData() {
    setState(() {
      _phoneController.text = '08123456789';
      _emailController.text = 'topikpanas@gmail.com';
    });
  }

  // Kosongkan form
  void _clearForm() {
    setState(() {
      _phoneController.clear();
      _emailController.clear();
    });
  }

  bool get _isFormValid =>
      _phoneController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _emailController.text.contains('@');

  // Lanjut ke Layar OTP
  void _proceedToOtp() {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan nomor handphone terdaftar Anda.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan alamat email terdaftar yang valid.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigasi ke Layar 2: Verifikasi OTP Email
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginOtpScreen(
          phoneNumber: phone,
          email: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _isFormValid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PundigoBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =============================================================
                // 1. TOP BAR: BRAND PUNDIGO! & LOGO PG
                // =============================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PundiGo!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const PgLogo(size: 32),
                  ],
                ),

                const SizedBox(height: 22),

                // =============================================================
                // 2. BADGE & HEADING MASUK
                // =============================================================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7F4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF00A887)),
                      const SizedBox(width: 5),
                      Text(
                        'Pemulihan Akun Terdaftar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00897B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Selamat Datang Kembali!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Masukkan nomor handphone dan email terdaftar untuk menerima kode verifikasi OTP.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 18),

                // =============================================================
                // 3. TOMBOL BANTU CEPAT (DEMO/DOSEN)
                // =============================================================
                Row(
                  children: [
                    InkWell(
                      onTap: _fillSampleData,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7F4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on_rounded, size: 13, color: Color(0xFF00A887)),
                            const SizedBox(width: 4),
                            Text(
                              '⚡ Isi Otomatis Akun Demo',
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
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _clearForm,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.clear_rounded, size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              'Kosongkan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 4. KOLOM INPUT 1: NOMOR HANDPHONE
                // =============================================================
                CustomTextField(
                  label: 'Nomor Handphone Terdaftar',
                  controller: _phoneController,
                  hintText: 'Contoh: 08123456789',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Color(0xFF00A887), size: 20),
                ),

                const SizedBox(height: 18),

                // =============================================================
                // 5. KOLOM INPUT 2: ALAMAT EMAIL
                // =============================================================
                CustomTextField(
                  label: 'Alamat Email Terdaftar',
                  controller: _emailController,
                  hintText: 'Contoh: topikpanas@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF00A887), size: 20),
                ),

                const SizedBox(height: 14),

                // Info Keamanan
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC).withOpacity(0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sistem akan mencocokkan nomor HP & email Anda sebelum mengirimkan 6 digit kode OTP ke kotak masuk email.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF15803D),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // =============================================================
                // 6. TOMBOL UTAMA: LANJUT KE VERIFIKASI OTP
                // =============================================================
                InkWell(
                  onTap: _proceedToOtp,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isValid
                          ? const LinearGradient(
                              colors: [Color(0xFF00BFA5), Color(0xFF1E88E5)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      color: isValid ? null : const Color(0xFFD6D6D6),
                      boxShadow: isValid
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00BFA5).withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Kirim Kode OTP ke Email',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =============================================================
                // 7. FOOTER: BELUM PUNYA AKUN? DAFTAR (SERASI DENGAN SUDAH PUNYA AKUN)
                // =============================================================
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(
                              text: 'Daftar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00A887),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
