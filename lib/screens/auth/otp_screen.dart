import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../services/otp_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/in_app_notification.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../../widgets/common/pundigo_background.dart';
import 'pin_screen.dart';

/// ============================================================================
/// HALAMAN VERIFIKASI KODE OTP
/// ============================================================================
/// Catatan untuk Dosen:
/// - Sesuai desain 'VERIVIKASI OTP (...).png' di Figma.
/// - Menampilkan 6 kotak input PIN OTP dengan auto-focus antar kotak.
/// - Terdapat timer hitung mundur untuk pengiriman ulang kode.
/// - Disediakan tombol 'Simulasi Cepat OTP' agar dosen dapat langsung menguji
///   alur verifikasi secara cepat tanpa menunggu SMS sungguhan.
/// ============================================================================
class OtpScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String email;
  final String method;

  const OtpScreen({
    super.key,
    this.name = 'Dinda Syahfitri',
    required this.phoneNumber,
    this.email = 'dinda.syahfitri@gmail.com',
    this.method = 'Email',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _enteredOtp = '';
  int _countdown = 41;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OtpService.sendOtpToEmail(
        context: context,
        email: widget.email,
        purpose: 'Pendaftaran Akun Baru',
        onQuickFill: () {
          setState(() => _enteredOtp = OtpService.activeOtp);
          _verifyOtp();
        },
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

      if (_enteredOtp.length == 6) {
        _verifyOtp();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredOtp.isNotEmpty) {
      setState(() {
        _enteredOtp = _enteredOtp.substring(0, _enteredOtp.length - 1);
      });
    }
  }



  void _verifyOtp() {
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

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PinScreen(
              isCreatingPin: true,
              name: widget.name,
              phone: widget.phoneNumber,
              email: widget.email,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Verifikasi OTP'),
      body: PundigoBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        'Masukkan Kode OTP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Kode verifikasi 6 digit telah dikirimkan ke alamat email:',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pill Alamat Email
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border.withOpacity(0.8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF00BFA5),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '•',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Row(
                                children: [
                                  Text(
                                    'Ubah',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF00A887),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.edit_outlined, size: 13, color: Color(0xFF00A887)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Banner Kasus Telat Masukkan OTP
                    if (_countdown == 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
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
                                'Waktu verifikasi habis. Demi keamanan akun baru Anda, kode OTP telah kedaluwarsa. Silakan kirim ulang kode baru di bawah.',
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

                    // 6 Kotak Digit OTP (Sesuai Figma)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final isFilled = index < _enteredOtp.length;
                        final isCurrent = index == _enteredOtp.length;
                        final digit = isFilled ? _enteredOtp[index] : '';
                        final isExpired = _countdown == 0;

                        Color boxBg;
                        Color borderCol;
                        if (isExpired) {
                          boxBg = const Color(0xFFFEF2F2);
                          borderCol = const Color(0xFFFCA5A5);
                        } else if (isCurrent) {
                          boxBg = const Color(0xFF00BFA5);
                          borderCol = const Color(0xFF00BFA5);
                        } else if (isFilled) {
                          boxBg = const Color(0xFF72E4D4);
                          borderCol = const Color(0xFF00BFA5);
                        } else {
                          boxBg = const Color(0xFFF0F4FD);
                          borderCol = Colors.transparent;
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 44,
                          height: 54,
                          decoration: BoxDecoration(
                            color: boxBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderCol,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: (isCurrent && !isExpired)
                              ? Container(
                                  width: 2,
                                  height: 22,
                                  color: Colors.white,
                                )
                              : Text(
                                  isFilled ? digit : '•',
                                  style: TextStyle(
                                    fontSize: isFilled ? 20 : 26,
                                    fontWeight: FontWeight.w800,
                                    color: isExpired
                                        ? const Color(0xFFDC2626)
                                        : (isFilled ? const Color(0xFF0F172A) : const Color(0xFFB0BEC5)),
                                  ),
                                ),
                        );
                      }),
                    ),

                    const SizedBox(height: 14),

                    // Tombol Isi Otomatis OTP Demo (Tanpa Modal Popup)
                    InkWell(
                      onTap: () {
                        if (_countdown == 0) _startTimer();
                        setState(() => _enteredOtp = OtpService.activeOtp);
                        _verifyOtp();
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

                    // Pill Timer Hitung Mundur (Sesuai Figma)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _countdown > 0 ? const Color(0xFFE8F1FD) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _countdown > 0 ? Icons.access_time_rounded : Icons.timer_off_outlined,
                            color: _countdown > 0 ? AppColors.textSecondary : const Color(0xFFDC2626),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _countdown > 0
                                ? 'Kirim ulang kode dalam 00:${_countdown.toString().padLeft(2, '0')}'
                                : 'Kode telah kedaluwarsa',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _countdown > 0 ? AppColors.textPrimary : const Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Link Kirim Ulang ke Email
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tidak menerima email? ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _startTimer();
                            OtpService.sendOtpToEmail(
                              context: context,
                              email: widget.email,
                              purpose: 'Pendaftaran Akun Baru',
                            );
                          },
                          child: Text(
                            'Kirim ulang ke Email →',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00A887),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Keyboard Virtual Numerik Khas Figma
            NumericKeyboard(
              onKeyPressed: _onDigitPressed,
              onDeletePressed: _onDeletePressed,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
      ),
    );
  }
}
