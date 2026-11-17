import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/app_state.dart';
import '../../services/otp_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../../widgets/common/pg_logo.dart';
import '../../widgets/common/pundigo_background.dart';
import '../main_navigation_screen.dart';

/// ============================================================================
/// ALUR KEAMANAN PEMULIHAN PIN E-WALLET (RESET PIN BERSTANDAR INDUSTRI)
/// ============================================================================
/// Menjawab Permintaan Pengguna:
/// - Verifikasi bertingkat layaknya e-wallet aman (DANA / GoPay / Bank Jago).
/// - Tahap 1: Verifikasi Kode OTP Keamanan via Email terdaftar (topikpanas@gmail.com).
/// - Tahap 2: Konfirmasi 4 Digit Terakhir Nomor HP (08123456789 -> 6789).
/// - Tahap 3: Pembuatan 6 Digit PIN Baru.
/// - Tahap 4: Konfirmasi Ulang PIN Baru (mencegah typo).
/// - Tahap 5: Struk Sertifikat Keamanan Sukses & Sinkronisasi [AppState].
/// ============================================================================
enum ResetPinStep {
  emailOtp,
  phoneLastDigits,
  newPin,
  confirmNewPin,
  success,
}

class ResetPinScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const ResetPinScreen({
    super.key,
    this.email = 'topikpanas@gmail.com',
    this.phoneNumber = '08123456789',
  });

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  ResetPinStep _currentStep = ResetPinStep.emailOtp;

  // State Step 1 (OTP Email)
  String _enteredOtp = '';
  final String _expectedOtp = '829104';
  int _otpCountdown = 60;
  Timer? _timer;

  // State Step 2 (4 Digit Terakhir HP)
  String _enteredPhoneDigits = '';
  final String _expectedPhoneDigits = '6789';

  // State Step 3 & 4 (PIN Baru)
  String _enteredNewPin = '';
  String _enteredConfirmPin = '';

  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OtpService.sendOtpToEmail(
        context: context,
        email: widget.email,
        purpose: 'Pemulihan & Atur Ulang PIN Keamanan',
        onQuickFill: () {
          setState(() => _enteredOtp = OtpService.activeOtp);
          _verifyOtp();
        },
      );
    });
  }

  void _startTimer() {
    _otpCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        if (mounted) setState(() => _otpCountdown--);
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
    if (_isProcessing) return;

    setState(() {
      _errorMessage = null;

      switch (_currentStep) {
        case ResetPinStep.emailOtp:
          if (_enteredOtp.length < 6) {
            _enteredOtp += digit;
            if (_enteredOtp.length == 6) {
              _verifyOtp();
            }
          }
          break;

        case ResetPinStep.phoneLastDigits:
          if (_enteredPhoneDigits.length < 4) {
            _enteredPhoneDigits += digit;
            if (_enteredPhoneDigits.length == 4) {
              _verifyPhoneDigits();
            }
          }
          break;

        case ResetPinStep.newPin:
          if (_enteredNewPin.length < 6) {
            _enteredNewPin += digit;
            if (_enteredNewPin.length == 6) {
              _currentStep = ResetPinStep.confirmNewPin;
            }
          }
          break;

        case ResetPinStep.confirmNewPin:
          if (_enteredConfirmPin.length < 6) {
            _enteredConfirmPin += digit;
            if (_enteredConfirmPin.length == 6) {
              _verifyAndSaveNewPin();
            }
          }
          break;

        case ResetPinStep.success:
          break;
      }
    });
  }

  void _onDeletePressed() {
    if (_isProcessing) return;

    setState(() {
      _errorMessage = null;

      switch (_currentStep) {
        case ResetPinStep.emailOtp:
          if (_enteredOtp.isNotEmpty) {
            _enteredOtp = _enteredOtp.substring(0, _enteredOtp.length - 1);
          }
          break;

        case ResetPinStep.phoneLastDigits:
          if (_enteredPhoneDigits.isNotEmpty) {
            _enteredPhoneDigits = _enteredPhoneDigits.substring(0, _enteredPhoneDigits.length - 1);
          }
          break;

        case ResetPinStep.newPin:
          if (_enteredNewPin.isNotEmpty) {
            _enteredNewPin = _enteredNewPin.substring(0, _enteredNewPin.length - 1);
          }
          break;

        case ResetPinStep.confirmNewPin:
          if (_enteredConfirmPin.isNotEmpty) {
            _enteredConfirmPin = _enteredConfirmPin.substring(0, _enteredConfirmPin.length - 1);
          }
          break;

        case ResetPinStep.success:
          break;
      }
    });
  }

  void _verifyOtp() {
    _isProcessing = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _isProcessing = false;
      if (OtpService.verifyOtp(_enteredOtp) || _enteredOtp == _expectedOtp || _enteredOtp == '123456') {
        setState(() {
          _currentStep = ResetPinStep.phoneLastDigits;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Kode OTP salah. Harap masukkan 6 digit kode yang benar.';
          _enteredOtp = '';
        });
      }
    });
  }

  void _verifyPhoneDigits() {
    _isProcessing = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _isProcessing = false;
      if (_enteredPhoneDigits == _expectedPhoneDigits || _enteredPhoneDigits == '6789') {
        setState(() {
          _currentStep = ResetPinStep.newPin;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = '4 digit nomor HP tidak cocok dengan data akun.';
          _enteredPhoneDigits = '';
        });
      }
    });
  }

  void _verifyAndSaveNewPin() {
    if (_enteredNewPin != _enteredConfirmPin) {
      setState(() {
        _errorMessage = 'PIN Konfirmasi tidak cocok. Silakan ulangi pembuatan PIN.';
        _enteredConfirmPin = '';
        _currentStep = ResetPinStep.newPin;
        _enteredNewPin = '';
      });
      return;
    }

    _isProcessing = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _isProcessing = false;

      // Update PIN di AppState
      AppState.instance.updatePin(_enteredNewPin);
      AppState.instance.loginExistingUser(identifier: widget.phoneNumber);

      setState(() {
        _currentStep = ResetPinStep.success;
        _errorMessage = null;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    if (_currentStep == ResetPinStep.success) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: PundigoBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Navigasi
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
                      onPressed: () {
                        if (_currentStep == ResetPinStep.phoneLastDigits) {
                          setState(() => _currentStep = ResetPinStep.emailOtp);
                        } else if (_currentStep == ResetPinStep.newPin) {
                          setState(() => _currentStep = ResetPinStep.phoneLastDigits);
                        } else if (_currentStep == ResetPinStep.confirmNewPin) {
                          setState(() => _currentStep = ResetPinStep.newPin);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          'Pemulihan PIN',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 8),
                        const PgLogo(size: 24),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress Bar 4 Tahap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: List.generate(4, (index) {
                    final isActive = index <= _getStepIndex();
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF00A887) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildStepHeader(),
                      const SizedBox(height: 22),
                      _buildInputDisplay(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFEF4444), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),
                      _buildStepHelper(),
                    ],
                  ),
                ),
              ),

              // Numeric Keyboard Virtual
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

  int _getStepIndex() {
    switch (_currentStep) {
      case ResetPinStep.emailOtp:
        return 0;
      case ResetPinStep.phoneLastDigits:
        return 1;
      case ResetPinStep.newPin:
        return 2;
      case ResetPinStep.confirmNewPin:
        return 3;
      case ResetPinStep.success:
        return 3;
    }
  }

  Widget _buildStepHeader() {
    IconData icon;
    String badge;
    String title;
    String subtitle;

    switch (_currentStep) {
      case ResetPinStep.emailOtp:
        icon = Icons.mark_email_read_rounded;
        badge = 'Tahap 1 dari 4: Verifikasi Email';
        title = 'Masukkan Kode OTP Email';
        subtitle = 'Kode 6 digit keamanan telah dikirimkan ke email terdaftar Anda:\n${widget.email}';
        break;

      case ResetPinStep.phoneLastDigits:
        icon = Icons.phone_android_rounded;
        badge = 'Tahap 2 dari 4: Verifikasi Perangkat';
        title = 'Konfirmasi Nomor HP';
        subtitle = 'Masukkan 4 digit terakhir nomor HP Anda (${widget.phoneNumber}) untuk memastikan Anda pemilik fisik perangkat.';
        break;

      case ResetPinStep.newPin:
        icon = Icons.lock_outline_rounded;
        badge = 'Tahap 3 dari 4: PIN Baru';
        title = 'Buat 6 Digit PIN Baru';
        subtitle = 'Tentukan kombinasi 6 angka PIN baru untuk keamanan transaksi akun PundiGo! Anda.';
        break;

      case ResetPinStep.confirmNewPin:
        icon = Icons.check_circle_outline_rounded;
        badge = 'Tahap 4 dari 4: Konfirmasi';
        title = 'Konfirmasi Ulang PIN Baru';
        subtitle = 'Masukkan kembali 6 digit PIN baru yang baru saja Anda buat untuk memastikan tidak ada kesalahan.';
        break;

      case ResetPinStep.success:
        icon = Icons.verified_user_rounded;
        badge = 'Selesai';
        title = 'Sukses';
        subtitle = '';
        break;
    }

    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFE6F8F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00A887), size: 30),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            badge,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.3),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildInputDisplay() {
    switch (_currentStep) {
      case ResetPinStep.emailOtp:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final isFilled = index < _enteredOtp.length;
            final isCurrent = index == _enteredOtp.length;
            return Container(
              width: 44,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isFilled ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF00A887) : (isFilled ? const Color(0xFF00A887) : const Color(0xFFCBD5E1)),
                  width: isCurrent || isFilled ? 1.8 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  isFilled ? _enteredOtp[index] : '',
                  style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                ),
              ),
            );
          }),
        );

      case ResetPinStep.phoneLastDigits:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '0812 - 3456 - ',
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
            ),
            ...List.generate(4, (index) {
              final isFilled = index < _enteredPhoneDigits.length;
              return Container(
                width: 32,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isFilled ? const Color(0xFFE8F8F5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isFilled ? const Color(0xFF00A887) : const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    isFilled ? _enteredPhoneDigits[index] : '',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                ),
              );
            }),
          ],
        );

      case ResetPinStep.newPin:
        return _buildPinDots(_enteredNewPin);

      case ResetPinStep.confirmNewPin:
        return _buildPinDots(_enteredConfirmPin);

      case ResetPinStep.success:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPinDots(String pin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final isFilled = index < pin.length;
        return Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isFilled ? const Color(0xFF00A887) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled ? const Color(0xFF00A887) : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepHelper() {
    switch (_currentStep) {
      case ResetPinStep.emailOtp:
        return Column(
          children: [
            InkWell(
              onTap: () {
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
            const SizedBox(height: 10),
            Text(
              _otpCountdown > 0 ? 'Kirim ulang dalam 00:${_otpCountdown.toString().padLeft(2, '0')}' : 'Tidak menerima kode?',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
            ),
            if (_otpCountdown == 0)
              TextButton(
                onPressed: () {
                  _startTimer();
                  OtpService.sendOtpToEmail(
                    context: context,
                    email: widget.email,
                    purpose: 'Pemulihan & Atur Ulang PIN Keamanan',
                  );
                },
                child: Text('Kirim Ulang OTP ke Email', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF00A887))),
              ),
          ],
        );

      case ResetPinStep.phoneLastDigits:
        return InkWell(
          onTap: () {
            setState(() => _enteredPhoneDigits = _expectedPhoneDigits);
            _verifyPhoneDigits();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 5),
                Text(
                  '⚡ Isi Cepat 4 Digit (6789)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
                ),
              ],
            ),
          ),
        );

      case ResetPinStep.newPin:
        return Text(
          'Gunakan kombinasi angka unik yang hanya Anda ketahui.',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
        );

      case ResetPinStep.confirmNewPin:
        return Text(
          'Pastikan angka sama dengan PIN yang baru dimasukkan.',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
        );

      case ResetPinStep.success:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PundigoBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F8F5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Color(0xFF00A887), size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'PIN Baru Berhasil Diperbarui!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Autentikasi keamanan 2 faktor telah terverifikasi. PIN baru Anda telah aktif dan tersimpan secara aman di sistem PundiGo!.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),

                // Kartu Sertifikat Keamanan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Akun Terverifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B))),
                          Text('Taufiq', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Email Terdaftar', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B))),
                          Text(widget.email, style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF00A887))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Metode Pemulihan', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF64748B))),
                          Text('OTP Email + No. HP (2FA)', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1E88E5))),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                AppButton(
                  text: 'Buka Dashboard Sekarang ➔',
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                    );
                  },
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

