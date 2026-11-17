import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/app_state.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../auth/reset_pin_screen.dart';
import 'help_center_screen.dart';

/// ============================================================================
/// HALAMAN ALUR GANTI PIN AKUN (100% PERSIS DENGAN DESAIN FIGMA)
/// ============================================================================
/// Alur pergantian PIN keamanan:
/// 1. Masukkan PIN Lama (verifikasi autentikasi pemilik akun)
/// 2. Masukkan PIN Baru (6-digit kombinasi angka baru)
/// 3. Konfirmasi Ulang PIN (memastikan tidak ada kesalahan input)
/// 4. Halaman Sukses & Sinkronisasi AppState
///
/// Tampilan kotak isian PIN menggunakan 6 kotak toska mint khas Figma
/// dengan angka jelas di dalamnya dan keyboard numerik virtual putih timbul.
/// ============================================================================
enum ChangePinStep {
  oldPin,
  newPin,
  confirmPin,
  success,
}

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  ChangePinStep _currentStep = ChangePinStep.oldPin;

  String _enteredOldPin = '';
  String _enteredNewPin = '';
  String _enteredConfirmPin = '';

  String? _errorMessage;
  bool _isProcessing = false;

  void _onDigitPressed(String digit) {
    if (_isProcessing) return;

    setState(() {
      _errorMessage = null;

      switch (_currentStep) {
        case ChangePinStep.oldPin:
          if (_enteredOldPin.length < 6) {
            _enteredOldPin += digit;
            if (_enteredOldPin.length == 6) {
              _processOldPin();
            }
          }
          break;

        case ChangePinStep.newPin:
          if (_enteredNewPin.length < 6) {
            _enteredNewPin += digit;
            if (_enteredNewPin.length == 6) {
              _processNewPin();
            }
          }
          break;

        case ChangePinStep.confirmPin:
          if (_enteredConfirmPin.length < 6) {
            _enteredConfirmPin += digit;
            if (_enteredConfirmPin.length == 6) {
              _processConfirmPin();
            }
          }
          break;

        case ChangePinStep.success:
          break;
      }
    });
  }

  void _onDeletePressed() {
    if (_isProcessing) return;

    setState(() {
      _errorMessage = null;

      switch (_currentStep) {
        case ChangePinStep.oldPin:
          if (_enteredOldPin.isNotEmpty) {
            _enteredOldPin = _enteredOldPin.substring(0, _enteredOldPin.length - 1);
          }
          break;

        case ChangePinStep.newPin:
          if (_enteredNewPin.isNotEmpty) {
            _enteredNewPin = _enteredNewPin.substring(0, _enteredNewPin.length - 1);
          }
          break;

        case ChangePinStep.confirmPin:
          if (_enteredConfirmPin.isNotEmpty) {
            _enteredConfirmPin = _enteredConfirmPin.substring(0, _enteredConfirmPin.length - 1);
          }
          break;

        case ChangePinStep.success:
          break;
      }
    });
  }

  void _processOldPin() async {
    final appState = AppState.instance;
    final actualPin = appState.user.pin;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    if (_enteredOldPin == actualPin) {
      // PIN lama benar -> Lanjut ke step pembuatan PIN Baru
      setState(() {
        _isProcessing = false;
        _errorMessage = null;
        _currentStep = ChangePinStep.newPin;
      });
    } else {
      // PIN lama salah
      setState(() {
        _isProcessing = false;
        _enteredOldPin = '';
        _errorMessage = 'PIN lama salah. Silakan coba kembali.';
      });
    }
  }

  void _processNewPin() async {
    // Validasi agar PIN baru tidak sama persis dengan PIN lama
    if (_enteredNewPin == _enteredOldPin) {
      setState(() {
        _enteredNewPin = '';
        _errorMessage = 'PIN baru tidak boleh sama dengan PIN lama.';
      });
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    // Lanjut ke step konfirmasi PIN Baru
    setState(() {
      _isProcessing = false;
      _errorMessage = null;
      _currentStep = ChangePinStep.confirmPin;
    });
  }

  void _processConfirmPin() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    if (_enteredConfirmPin == _enteredNewPin) {
      // Sukses! Update PIN di AppState
      final appState = AppState.instance;
      appState.updatePin(_enteredNewPin);

      setState(() {
        _isProcessing = false;
        _errorMessage = null;
        _currentStep = ChangePinStep.success;
      });
    } else {
      // Konfirmasi tidak cocok
      setState(() {
        _isProcessing = false;
        _enteredConfirmPin = '';
        _errorMessage = 'Konfirmasi PIN tidak cocok dengan PIN baru.';
      });
    }
  }

  void _quickFill() {
    final appState = AppState.instance;
    final actualPin = appState.user.pin.isNotEmpty ? appState.user.pin : '171717';

    if (_currentStep == ChangePinStep.oldPin) {
      setState(() => _enteredOldPin = actualPin);
      _processOldPin();
    } else if (_currentStep == ChangePinStep.newPin) {
      setState(() => _enteredNewPin = '171717');
      _processNewPin();
    } else if (_currentStep == ChangePinStep.confirmPin) {
      setState(() => _enteredConfirmPin = _enteredNewPin.isNotEmpty ? _enteredNewPin : '171717');
      _processConfirmPin();
    }
  }

  String _getCurrentEnteredPin() {
    switch (_currentStep) {
      case ChangePinStep.oldPin:
        return _enteredOldPin;
      case ChangePinStep.newPin:
        return _enteredNewPin;
      case ChangePinStep.confirmPin:
        return _enteredConfirmPin;
      case ChangePinStep.success:
        return '';
    }
  }

  String _getTitle() {
    switch (_currentStep) {
      case ChangePinStep.oldPin:
        return 'Masukkan PIN Lama';
      case ChangePinStep.newPin:
        return 'Buat PIN Akun';
      case ChangePinStep.confirmPin:
        return 'Konfirmasi PIN Akun';
      case ChangePinStep.success:
        return 'PIN Sukses';
    }
  }

  String _getBannerTitle() {
    switch (_currentStep) {
      case ChangePinStep.oldPin:
        return 'Masukkan PIN Lama Kamu';
      case ChangePinStep.newPin:
        return 'Buat PIN Transaksi 6 Digit';
      case ChangePinStep.confirmPin:
        return 'Konfirmasi Ulang PIN Kamu';
      case ChangePinStep.success:
        return '';
    }
  }

  String _getBannerSubtitle() {
    switch (_currentStep) {
      case ChangePinStep.oldPin:
        return 'Masukkan 6 digit PIN saat ini untuk memverifikasi kepemilikan akun PundiGo! kamu.';
      case ChangePinStep.newPin:
        return 'PIN digunakan untuk mengamankan setiap transaksi dan login ke akun PundiGo! kamu.';
      case ChangePinStep.confirmPin:
        return 'Masukkan kembali 6 digit PIN yang baru saja kamu buat untuk memastikan kecocokan sandi transaksi.';
      case ChangePinStep.success:
        return '';
    }
  }

  String _getTipText() {
    switch (_currentStep) {
      case ChangePinStep.oldPin:
        return 'Pastikan kamu memasukkan PIN lama akun kamu dengan benar';
      case ChangePinStep.newPin:
        return 'Hindari tanggal lahir, nomor telepon, atau angka berurutan';
      case ChangePinStep.confirmPin:
        return 'Pastikan kamu tidak lupa dengan pin kamu sendiri';
      case ChangePinStep.success:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == ChangePinStep.success) {
      return _buildSuccessScreen();
    }

    final currentPin = _getCurrentEnteredPin();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _getTitle(),
        onBack: () {
          if (_currentStep == ChangePinStep.confirmPin) {
            setState(() {
              _enteredConfirmPin = '';
              _currentStep = ChangePinStep.newPin;
            });
          } else if (_currentStep == ChangePinStep.newPin) {
            setState(() {
              _enteredNewPin = '';
              _currentStep = ChangePinStep.oldPin;
            });
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // =========================================================
                    // 1. BANNER GRADIEN BIRU-TOSKA DENGAN IKON SHIELD (FIGMA)
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFA5), Color(0xFF1E88E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BFA5).withOpacity(0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Ikon Perisai Keamanan Sesuai Desain Figma
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.verified_user_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getBannerTitle(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getBannerSubtitle(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.92),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================================================
                    // 2. TIPS KEAMANAN PILL (SESUAI DESAIN FIGMA)
                    // =========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline_rounded, color: Color(0xFF00897B), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getTipText(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // =========================================================
                    // 3. ENAM KOTAK DIGIT PIN TOSKA MINT (PERSIS FIGMA)
                    // =========================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final isFilled = index < currentPin.length;
                        final isLastFilled = isFilled && (index == currentPin.length - 1);
                        final digit = isFilled ? currentPin[index] : '';
                        final hasError = _errorMessage != null;

                        Color boxBgColor;
                        Color boxBorderColor;
                        Color textColor;

                        if (hasError) {
                          boxBgColor = const Color(0xFFFEE2E2);
                          boxBorderColor = const Color(0xFFEF4444);
                          textColor = const Color(0xFFDC2626);
                        } else if (isLastFilled) {
                          // Kotak terakhir yang baru diisi memiliki warna toska tegas (seperti angka 5 di Figma)
                          boxBgColor = const Color(0xFF00BFA5);
                          boxBorderColor = const Color(0xFF00897B);
                          textColor = Colors.white;
                        } else if (isFilled) {
                          // Kotak yang terisi memiliki warna mint toska khas Figma (#72E4D4)
                          boxBgColor = const Color(0xFF72E4D4);
                          boxBorderColor = const Color(0xFF00BFA5);
                          textColor = const Color(0xFF0F172A);
                        } else {
                          // Kotak kosong
                          boxBgColor = const Color(0xFFE6F8F5);
                          boxBorderColor = const Color(0xFFB2DFDB);
                          textColor = const Color(0xFF80CBC4);
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 44,
                          height: 54,
                          decoration: BoxDecoration(
                            color: boxBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: boxBorderColor,
                              width: 1.5,
                            ),
                            boxShadow: isFilled && !hasError
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00BFA5).withOpacity(0.18),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isFilled ? digit : '•',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: isFilled ? 20 : 26,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Pesan Error jika ada
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Tombol Simulasi Cepat (Untuk Mempermudah Presentasi Akademik)
                    InkWell(
                      onTap: _quickFill,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF00A887)),
                            const SizedBox(width: 4),
                            Text(
                              _currentStep == ChangePinStep.oldPin
                                  ? 'Isi Cepat PIN Lama (${AppState.instance.user.pin.isNotEmpty ? AppState.instance.user.pin : "171717"})'
                                  : (_currentStep == ChangePinStep.newPin
                                      ? 'Isi Cepat PIN Baru (171717)'
                                      : 'Cocokkan PIN Cepat'),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00A887),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Keterangan di bawah kotak (Sesuai Figma)
                    Text(
                      'Gunakan kombinasi angka yang tidak mudah ditebak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    if (_currentStep == ChangePinStep.oldPin) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResetPinScreen(
                                email: AppState.instance.user.email,
                                phoneNumber: AppState.instance.user.phone,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_reset_rounded, size: 18, color: Color(0xFF00A887)),
                        label: Text(
                          'Lupa PIN Lama? Reset dengan OTP Email & No. HP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00A887),
                          ),
                        ),
                      ),
                    ],

                    if (_currentStep == ChangePinStep.confirmPin) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _enteredConfirmPin = '';
                            _currentStep = ChangePinStep.newPin;
                          });
                        },
                        child: Text(
                          'Ubah PIN sebelumnya',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00A887),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // =================================================================
            // 4. KEYBOARD NUMERIK VIRTUAL (SESUAI DESAIN FIGMA)
            // =================================================================
            NumericKeyboard(
              onKeyPressed: _onDigitPressed,
              onDeletePressed: _onDeletePressed,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LAYAR SUKSES SETELAH PIN BERHASIL DIPERBARUI
  // ===========================================================================
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // Badge Sukses
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF00A887)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BFA5).withOpacity(0.38),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 26),

              Text(
                'PIN Berhasil Diperbarui!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'PIN 6-digit keamanan akun PundiGo Anda telah berhasil diperbarui. Gunakan PIN baru ini untuk otorisasi seluruh transaksi Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),

              // Kartu Status Keamanan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF00A887),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Keamanan: Terverifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jangan pernah membagikan kode PIN kepada siapapun termasuk pihak PundiGo.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol Kembali ke Profil
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFA5), Color(0xFF2979FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00BFA5).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Kembali ke Profil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
