import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/app_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/numeric_keyboard.dart';
import '../../widgets/common/in_app_notification.dart';
import 'transaction_receipt_screen.dart';

/// ============================================================================
/// HALAMAN PENERIMA PERMINTAAN SALDO (TAMPILAN ORANG YANG DIMINTAI SALDO)
/// ============================================================================
/// Tampilan resmi saat teman/keluarga menerima dan membuka tautan permintaan saldo:
/// 1. Profil Peminta Saldo lengkap (Nama, No HP, Email, Badge Terverifikasi).
/// 2. Nominal yang diminta & Catatan/Keperluan dari peminta.
/// 3. Informasi Saldo Pengirim saat ini.
/// 4. Opsi "Tolak Permintaan" dan "Kirim Saldo Sekarang (Bayar)".
/// 5. Validasi PIN 6 Digit keamanan sebelum saldo ditransfer.
/// 6. Menampilkan Struk Resmi Digital PundiGo! dengan stempel LUNAS terverifikasi.
/// ============================================================================
class RequestedBalancePaymentScreen extends StatefulWidget {
  final String requesterName;
  final String requesterPhone;
  final String requesterEmail;
  final double requestedAmount;
  final String requestNote;

  const RequestedBalancePaymentScreen({
    super.key,
    this.requesterName = 'Taufiq',
    this.requesterPhone = '08123456789',
    this.requesterEmail = 'topikpanas@gmail.com',
    this.requestedAmount = 50000,
    this.requestNote = 'Hai! Boleh minta transfer saldo Rp50.000 untuk patungan makan siang bareng tadi ya. Terima kasih banyak!',
  });

  @override
  State<RequestedBalancePaymentScreen> createState() => _RequestedBalancePaymentScreenState();
}

class _RequestedBalancePaymentScreenState extends State<RequestedBalancePaymentScreen> {
  final AppState _appState = AppState.instance;

  void _showPinModal() {
    if (_appState.user.saldoUtama < widget.requestedAmount) {
      _showInsufficientBalanceDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _PinPaymentSheet(
          amount: widget.requestedAmount,
          requesterName: widget.requesterName,
          onSuccess: () {
            Navigator.of(ctx).pop();
            _executePayment();
          },
        );
      },
    );
  }

  void _executePayment() {
    final success = _appState.transferSaldo(
      widget.requestedAmount,
      'Permintaan Saldo: ${widget.requesterName}',
    );

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TransactionReceiptScreen(
            receiptType: ReceiptType.transfer,
            title: 'Permintaan Saldo Dipenuhi',
            amount: widget.requestedAmount,
            isIncome: false,
            recipientOrDestination: widget.requesterName,
            accountOrPhone: widget.requesterPhone,
            methodOrProvider: 'PundiGo Pay (Saldo Utama)',
            notes: widget.requestNote,
          ),
        ),
      );
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Tolak Permintaan Saldo?',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Apakah Anda yakin ingin menolak permintaan saldo dari ${widget.requesterName} sebesar ${CurrencyFormatter.format(widget.requestedAmount)}?',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                InAppNotification.show(
                  context,
                  title: 'Permintaan Ditolak',
                  message: 'Permintaan saldo dari ${widget.requesterName} telah ditolak.',
                  icon: Icons.cancel_rounded,
                  iconColor: const Color(0xFF64748B),
                  iconBg: const Color(0xFFF1F5F9),
                );
                Navigator.of(context).pop();
              },
              child: Text(
                'Tolak',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInsufficientBalanceDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
              const SizedBox(width: 8),
              Text(
                'Saldo Tidak Cukup',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            'Saldo PundiGo Anda (${CurrencyFormatter.format(_appState.user.saldoUtama)}) tidak mencukupi untuk memenuhi permintaan saldo sebesar ${CurrencyFormatter.format(widget.requestedAmount)}. Silakan isi saldo terlebih dahulu.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A887),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Mengerti',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _appState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: 'Permintaan Saldo Masuk'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER STATUS PERMINTAAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF8F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00A887).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A887),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_received_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permintaan Transfer Diterima',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF007A63),
                            ),
                          ),
                          Text(
                            'Teman Anda meminta pengiriman saldo ke dompetnya',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // KARTU PROFIL PEMINTA SALDO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFFDCE4FD),
                          child: Text(
                            widget.requesterName.isNotEmpty ? widget.requesterName.substring(0, 1).toUpperCase() : 'P',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3F51B5),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A887),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.requesterName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.requesterPhone} • ${widget.requesterEmail}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 13, color: Color(0xFF00A887)),
                          const SizedBox(width: 4),
                          Text(
                            'Akun Terverifikasi PundiGo! Plus',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF007A63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // KARTU JUMLAH & CATATAN PERMINTAAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C9A7), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C9A7).withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nominal yang Diminta:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(widget.requestedAmount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notes_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Pesan dari Peminta:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '"${widget.requestNote}"',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // KOTAK INFORMASI SUMBER DANA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sumber Pembayaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'PundiGo Saldo Utama',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Sisa Saldo Anda',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(user.saldoUtama),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF007A63),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // TOMBOL AKSI: TOLAK & KIRIM SALDO
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _showRejectDialog,
                      child: Text(
                        'Tolak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: AppButton(
                      text: 'Kirim Saldo Sekarang ➔',
                      onPressed: _showPinModal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// MODAL INPUT PIN PEMBAYARAN MINTA SALDO
/// ============================================================================
class _PinPaymentSheet extends StatefulWidget {
  final double amount;
  final String requesterName;
  final VoidCallback onSuccess;

  const _PinPaymentSheet({
    required this.amount,
    required this.requesterName,
    required this.onSuccess,
  });

  @override
  State<_PinPaymentSheet> createState() => _PinPaymentSheetState();
}

class _PinPaymentSheetState extends State<_PinPaymentSheet> {
  String _pin = '';

  void _onDigit(String d) {
    if (_pin.length < 6) {
      setState(() => _pin += d);
      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _verifyPin() {
    final correctPin = AppState.instance.user.pin.isNotEmpty ? AppState.instance.user.pin : '171717';
    if (_pin == correctPin) {
      widget.onSuccess();
    } else {
      setState(() => _pin = '');
      InAppNotification.show(
        context,
        title: 'PIN Keamanan Salah',
        message: 'PIN yang Anda masukkan keliru. Gunakan PIN 171717.',
        icon: Icons.lock_clock_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBg: const Color(0xFFFEE2E2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctPin = AppState.instance.user.pin.isNotEmpty ? AppState.instance.user.pin : '171717';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Konfirmasi PIN Keamanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kirim ${CurrencyFormatter.format(widget.amount)} kepada ${widget.requesterName}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Titik Indikator PIN (6 Titik)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final isFilled = i < _pin.length;
              return Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? const Color(0xFF00A887) : const Color(0xFFE2E8F0),
                  border: Border.all(
                    color: isFilled ? const Color(0xFF00A887) : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          // Tombol Isi Cepat PIN
          InkWell(
            onTap: () {
              setState(() => _pin = correctPin);
              _verifyPin();
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF00A887)),
                  const SizedBox(width: 4),
                  Text(
                    'Isi Cepat PIN ($correctPin)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF007A63),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          NumericKeyboard(
            onKeyPressed: _onDigit,
            onDeletePressed: _onDelete,
          ),
        ],
      ),
    );
  }
}

