import 'package:flutter/material.dart';

import 'transaction_receipt_screen.dart';

/// ============================================================================
/// HALAMAN TOP UP BERHASIL (STRUK RESMI DIGITAL PUNDIGO!)
/// ============================================================================
/// Terintegrasi dengan [TransactionReceiptScreen] untuk menjamin tampilan
/// struk 100% berada di dalam frame smartphone dengan detail transaksi lengkap,
/// QRIS/watermark, nomor referensi unik, serta tombol bagikan struk resmi.
/// ============================================================================
class TopupSuccessScreen extends StatelessWidget {
  final double amount;
  final String method;

  const TopupSuccessScreen({
    super.key,
    this.amount = 100000,
    this.method = 'Tunai Kasir Indomaret',
  });

  @override
  Widget build(BuildContext context) {
    return TransactionReceiptScreen(
      receiptType: ReceiptType.topup,
      title: 'Top Up',
      amount: amount,
      isIncome: true,
      methodOrProvider: method,
    );
  }
}
