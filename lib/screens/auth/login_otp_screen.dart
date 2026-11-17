import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../services/otp_service.dart';
import '../../widgets/common/in_app_notification.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../../widgets/common/pg_logo.dart';
import '../../widgets/common/pundigo_background.dart';
import 'login_pin_screen.dart';

/// ============================================================================
/// ALUR SUDAH PUNYA AKUN - LAYAR 2: VERIFIKASI KODE OTP EMAIL
/// ============================================================================
/// Fitur Khusus Sesuai Permintaan:
/// 1. Menerima OTP via Email terdaftar.
/// 2. Penanganan Kasus "Telat Masukkan OTP (Expired)":
///    - Banner peringatan waktu habis & kode kedaluwarsa.
///    - Tombol "Kirim Ulang Kode OTP ke Email".
///    - Tombol bantu "⏱️ Simulasikan Waktu Habis (Telat OTP)" untuk kemudahan uji coba.
/// ============================================================================
class LoginOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;

  const LoginOtpScreen({
    super.key,
    required this.phoneNumber,
    this.email = 'topikpanas@gmail.com',
  });

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  String _enteredOtp = '';
  int _countdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OtpService.sendOtpToEmail(
        context: context,
        email: widget.email,
        purpose: 'Masuk Akun PundiGo!',
        onQuickFill: () => setState(() => _enteredOtp = OtpService.activeOtp),
      );
    });
  }

  void _startTimer() {
    setState(() {
      _countdown = 45;
      _enteredOtp = '';
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }



  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_countdown == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP telah kedaluwarsa. Silakan kirim ulang kode baru di bawah.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_enteredOtp.length < 6) {
      setState(() {
        _enteredOtp += digit;
      });
    }
  }

  void _onDeletePressed() {
    if (_enteredOtp.isNotEmpty) {
      setState(() {
        _enteredOtp = _enteredOtp.substring(0, _enteredOtp.length - 1);
      });
    }
  }



  void _resendOtp() {
    _startTimer();
    OtpService.sendOtpToEmail(
      context: context,
      email: widget.email,
      purpose: 'Masuk Akun PundiGo!',
      onQuickFill: () => setState(() => _enteredOtp = OtpService.activeOtp),
    );
  }

  void _submitOtp() {
    if (_countdown == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode OTP telah kedaluwarsa! Harap ketuk "Kirim Ulang Kode OTP ke Email".'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan 6 digit kode OTP verifikasi.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!OtpService.verifyOtp(_enteredOtp)) {
      InAppNotification.show(
        context,
        title: 'Kode OTP Salah',
        message: 'Kode OTP yang Anda masukkan tidak cocok. Silakan periksa kembali email Anda.',
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFEE2E2),
      );
      return;
    }

    // Navigasi ke Layar 3: Masukkan PIN Akun
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPinScreen(
          phoneNumber: widget.phoneNumber,
          email: widget.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _countdown == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PundigoBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
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
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Badge Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isExpired ? const Color(0xFFFEE2E2) : const Color(0xFFE0F7F4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isExpired
                                ? const Color(0xFFEF4444).withOpacity(0.4)
                                : const Color(0xFF00BFA5).withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExpired ? Icons.error_outline_rounded : Icons.email_outlined,
                              size: 15,
                              color: isExpired ? const Color(0xFFDC2626) : const Color(0xFF00A887),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isExpired ? 'Kode OTP Kedaluwarsa' : 'Kode Dikirim via Email',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isExpired ? const Color(0xFFB91C1C) : const Color(0xFF00897B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Verifikasi Kode OTP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(text: 'Masukkan 6 digit kode verifikasi yang telah dikirimkan ke email terdaftar: '),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Banner Kasus Telat Masukkan OTP
                      if (isExpired)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_off_outlined, color: Color(0xFFDC2626), size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Waktu verifikasi habis. Demi keamanan akun, kode ini tidak lagi berlaku. Silakan kirim ulang kode baru di bawah.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: const Color(0xFF991B1B),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 6 Kotak Input Kode OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          final isFilled = index < _enteredOtp.length;
                          final isCurrent = index == _enteredOtp.length;
                          final char = isFilled ? _enteredOtp[index] : '';

                          Color borderColor;
                          Color bgColor;
                          if (isExpired) {
                            borderColor = const Color(0xFFFCA5A5);
                            bgColor = const Color(0xFFFEF2F2);
                          } else if (isCurrent) {
                            borderColor = const Color(0xFF00BFA5);
                            bgColor = Colors.white;
                          } else if (isFilled) {
                            borderColor = const Color(0xFF00A887);
                            bgColor = const Color(0xFFF0FDF4);
                          } else {
                            borderColor = const Color(0xFFCBD5E1);
                            bgColor = const Color(0xFFF8FAFC);
                          }

                          return Container(
                            width: 44,
                            height: 52,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: isCurrent || isFilled ? 1.8 : 1,
                              ),
                              boxShadow: (isCurrent && !isExpired)
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00BFA5).withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                char,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isExpired ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 14),

                      // Tombol Isi Otomatis OTP Demo (Tanpa Modal Popup)
                      InkWell(
                        onTap: () {
                          if (isExpired) _startTimer();
                          setState(() => _enteredOtp = OtpService.activeOtp);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7F4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFF00A887)),
                              const SizedBox(width: 5),
                              Text(
                                '⚡ Isi Otomatis OTP Demo (${OtpService.activeOtp})',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00897B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Status Timer & Kirim Ulang
                      if (!isExpired)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 15, color: Color(0xFF64748B)),
                            const SizedBox(width: 5),
                            Text(
                              'Kode berlaku selama: ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              '00:${_countdown.toString().padLeft(2, '0')}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00A887),
                              ),
                            ),
                          ],
                        )
                      else
                        InkWell(
                          onTap: _resendOtp,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F7F4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00BFA5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.replay_rounded, size: 16, color: Color(0xFF00A887)),
                                const SizedBox(width: 6),
                                Text(
                                  'Kirim Ulang Kode OTP ke Email',
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

                      const SizedBox(height: 20),

                      // Tombol Utama: "Konfirmasi OTP ➔"
                      InkWell(
                        onTap: _submitOtp,
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
                                  'Konfirmasi OTP',
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
                    ],
                  ),
                ),
              ),

              // Papan Tombol Angka (Numeric Keypad) Bersih
              NumericKeyboard(
                onKeyPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
