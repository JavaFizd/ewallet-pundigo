import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/feature_models.dart';
import 'dummy_data.dart';

/// ============================================================================
/// STATE MANAGEMENT SEDERHANA (APP STATE)
/// ============================================================================
/// Catatan untuk Dosen:
/// Menggunakan ChangeNotifier murni bawaan Flutter tanpa dependensi rumit,
/// sehingga sangat mudah dipelajari dan dipahami alurnya.
/// Semua perubahan data (transfer, top up, ganti profil) langsung
/// terupdate secara reaktif di layar aplikasi.
/// ============================================================================
class AppState extends ChangeNotifier {
  // Singleton pattern agar state dapat diakses di seluruh screen
  static final AppState instance = AppState._internal();
  factory AppState() => instance;
  AppState._internal();

  UserModel _user = DummyData.currentUser;
  bool _isBalanceVisible = true;
  bool _isNewAccount = true;
  final List<TransactionModel> _transactions = [];
  KasKelompokModel _kasKelompok = KasKelompokModel(
    id: 'kas_empty',
    title: 'Belum Ada Kas',
    memberCount: 0,
    collectedAmount: 0,
    targetAmount: 0,
  );
  final List<KasMutasiModel> _kasMutasi = [];

  // Getters
  UserModel get user => _user;
  bool get isBalanceVisible => _isBalanceVisible;
  bool get isNewAccount => _isNewAccount;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  KasKelompokModel get kasKelompok => _kasKelompok;
  List<KasMutasiModel> get kasMutasi => List.unmodifiable(_kasMutasi);


  // Sembunyikan atau tampilkan saldo utama (Ikon Mata di Dashboard)
  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  // Mendaftarkan akun baru dari awal (Simulasi Pendaftaran Akun Baru)
  void registerNewUser({
    required String name,
    required String phone,
    required String email,
    required String pin,
    String? photoUrl,
  }) {
    final cleanName = name.trim().isEmpty ? 'Taufiq' : name.trim();
    final initials = UserModel.computeInitials(cleanName);

    String formattedPhone = phone.trim();
    if (formattedPhone.isEmpty) {
      formattedPhone = '+62 812-3456-789';
    } else if (!formattedPhone.startsWith('+62')) {
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '+62 ${formattedPhone.substring(1)}';
      } else if (formattedPhone.startsWith('62')) {
        formattedPhone = '+$formattedPhone';
      } else {
        formattedPhone = '+62 $formattedPhone';
      }
    }

    _user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: cleanName,
      phone: formattedPhone,
      email: email.trim().isEmpty ? 'dinda.syahfitri@gmail.com' : email.trim(),
      initials: initials,
      photoUrl: photoUrl,
      accountType: 'Akun Basic',
      saldoUtama: 0,
      saldoDompet: 0,
      pin: pin.isNotEmpty ? pin : '171717',
    );
    _isNewAccount = true;
    _transactions.clear();
    _kasKelompok = KasKelompokModel(
      id: 'kas_empty',
      title: 'Belum Ada Kas',
      memberCount: 0,
      collectedAmount: 0,
      targetAmount: 0,
    );
    _kasMutasi.clear();
    _isBalanceVisible = true;
    notifyListeners();
  }

  // Update profil pengguna (Nama, No HP, Email, Foto Profil, dan Foto KTP secara terpisah)
  void updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    bool clearPhoto = false,
    String? ktpPhotoUrl,
    bool clearKtpPhoto = false,
  }) {
    _user = _user.copyWith(
      name: name ?? _user.name,
      phone: phone ?? _user.phone,
      email: email ?? _user.email,
      photoUrl: clearPhoto ? null : (photoUrl ?? _user.photoUrl),
      clearPhoto: clearPhoto,
      ktpPhotoUrl: clearKtpPhoto ? null : (ktpPhotoUrl ?? _user.ktpPhotoUrl),
      clearKtpPhoto: clearKtpPhoto,
    );
    notifyListeners();
  }

  // Simpan hasil Scan KTP -> otomatis menyimpan Foto KTP & memperbarui Foto Profil
  void completeKtpScan({String ktpAsset = 'assets/images/profile_dinda.jpg'}) {
    _user = _user.copyWith(
      ktpPhotoUrl: ktpAsset,
      photoUrl: ktpAsset,
    );
    notifyListeners();
  }

  // Upgrade akun ke PundiGo! Plus
  void upgradeToPlus() {
    final ktpPhoto = _user.hasKtpPhoto ? _user.ktpPhotoUrl : 'assets/images/profile_dinda.jpg';
    _user = _user.copyWith(
      accountType: 'Akun Plus',
      ktpPhotoUrl: ktpPhoto,
      photoUrl: _user.hasPhoto ? _user.photoUrl : ktpPhoto,
    );
    notifyListeners();
  }

  // Masuk sebagai pengguna lama (Sudah terdaftar: topikpanas@gmail.com / 08123456789 / PIN 171717)
  void loginExistingUser({String? identifier}) {
    _isNewAccount = false;
    _user = _user.copyWith(
      name: 'Taufiq',
      initials: 'TF',
      phone: '08123456789',
      email: 'topikpanas@gmail.com',
      pin: _user.pin.isEmpty || _user.pin == '170845' ? '171717' : _user.pin,
      accountType: 'Akun Plus',
      saldoUtama: 100000,
      saldoDompet: 50000,
    );
    if (_transactions.isEmpty) {
      _transactions.addAll(DummyData.initialTransactions);
    }
    _kasKelompok = DummyData.defaultKas;
    if (_kasMutasi.isEmpty) {
      _kasMutasi.addAll([
        KasMutasiModel(
          title: 'Beli ATK & Print Makalah',
          subtitle: 'Nota No. 0429 • Fotokopi Kampus',
          amount: 35000,
          isIncome: false,
          date: DateTime.now().subtract(const Duration(days: 1)),
          hasReceipt: true,
          uploader: 'Taufiq (Bendahara)',
        ),
        KasMutasiModel(
          title: 'Iuran Kas: Rahmat Hidayat',
          subtitle: 'Transfer via PundiGo!',
          amount: 25000,
          isIncome: true,
          date: DateTime.now().subtract(const Duration(days: 2)),
          hasReceipt: false,
          uploader: 'Rahmat Hidayat',
        ),
        KasMutasiModel(
          title: 'Iuran Kas: Maya Lestari',
          subtitle: 'Transfer via Bank Aceh',
          amount: 25000,
          isIncome: true,
          date: DateTime.now().subtract(const Duration(days: 3)),
          hasReceipt: false,
          uploader: 'Maya Lestari',
        ),
      ]);
    }
    notifyListeners();
  }

  // Update PIN keamanan akun 6-digit
  void updatePin(String newPin) {
    _user = _user.copyWith(pin: newPin);
    notifyListeners();
  }

  // Melakukan transfer saldo
  bool transferSaldo(double amount, String recipientName) {
    if (_user.saldoUtama < amount) return false;

    // Kurangi saldo utama
    _user = _user.copyWith(saldoUtama: _user.saldoUtama - amount);

    // Tambahkan riwayat transaksi baru di posisi teratas
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        title: 'Transfer ke $recipientName',
        subtitle: 'Hari ini • Sukses',
        date: DateTime.now(),
        amount: amount,
        isIncome: false,
        status: 'Sukses',
        referenceNumber: 'PG-TRF-${DateTime.now().millisecondsSinceEpoch}',
        category: 'Transfer',
      ),
    );

    notifyListeners();
    return true;
  }

  // Melakukan Top Up saldo
  void topUpSaldo(double amount, {String method = 'Indomaret'}) {
    _user = _user.copyWith(saldoUtama: _user.saldoUtama + amount);

    _transactions.insert(
      0,
      TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        title: 'Top Up $method',
        subtitle: 'Hari ini • Sukses',
        date: DateTime.now(),
        amount: amount,
        isIncome: true,
        status: 'Sukses',
        referenceNumber: 'PG-IDM-${DateTime.now().millisecondsSinceEpoch}',
        category: 'TopUp',
      ),
    );

    notifyListeners();
  }

  // Menambah iuran kas kelompok
  bool setorKas(double amount, {String uploader = 'Taufiq'}) {
    if (_user.saldoUtama >= amount) {
      _user = _user.copyWith(saldoUtama: _user.saldoUtama - amount);
      _kasKelompok = KasKelompokModel(
        id: _kasKelompok.id,
        title: _kasKelompok.title,
        memberCount: _kasKelompok.memberCount,
        collectedAmount: _kasKelompok.collectedAmount + amount,
        targetAmount: _kasKelompok.targetAmount,
      );
      _kasMutasi.insert(
        0,
        KasMutasiModel(
          title: 'Iuran Kas: $uploader',
          subtitle: 'Transfer via PundiGo!',
          amount: amount,
          isIncome: true,
          date: DateTime.now(),
          hasReceipt: false,
          uploader: uploader,
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Menerima iuran kas dari anggota via tautan / QRIS / transfer
  void addKasContribution(double amount, {String uploader = 'Anggota (via Tautan)'}) {
    _kasKelompok = KasKelompokModel(
      id: _kasKelompok.id,
      title: _kasKelompok.title,
      memberCount: _kasKelompok.memberCount,
      collectedAmount: _kasKelompok.collectedAmount + amount,
      targetAmount: _kasKelompok.targetAmount,
    );
    _kasMutasi.insert(
      0,
      KasMutasiModel(
        title: 'Iuran Kas: $uploader',
        subtitle: 'Setoran via Tautan Kas • Dikonfirmasi',
        amount: amount,
        isIncome: true,
        date: DateTime.now(),
        hasReceipt: true,
        uploader: uploader,
      ),
    );
    notifyListeners();
  }

  // Mencatat pengeluaran kas kelompok oleh bendahara dengan bukti nota
  bool catatPengeluaranKas({
    required String title,
    required double amount,
    String subtitle = 'Nota terlampir • Telah diverifikasi',
    bool hasReceipt = true,
  }) {
    if (_kasKelompok.collectedAmount >= amount) {
      _kasKelompok = KasKelompokModel(
        id: _kasKelompok.id,
        title: _kasKelompok.title,
        memberCount: _kasKelompok.memberCount,
        collectedAmount: _kasKelompok.collectedAmount - amount,
        targetAmount: _kasKelompok.targetAmount,
      );
      _kasMutasi.insert(
        0,
        KasMutasiModel(
          title: title,
          subtitle: subtitle,
          amount: amount,
          isIncome: false,
          date: DateTime.now(),
          hasReceipt: hasReceipt,
          uploader: 'Taufiq (Bendahara)',
        ),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // Integrasi Patungan Pintar Otomatis ke Saku Kas Kelompok
  void executePatunganKeKas({
    required double totalAmount,
    required double personalAmount,
    required String placeName,
    required String kasTitle,
  }) {
    // 1. Potong saldo personal Dinda Rp 25.000 jika cukup
    if (_user.saldoUtama >= personalAmount) {
      _user = _user.copyWith(saldoUtama: _user.saldoUtama - personalAmount);
    }

    // 2. Tambah kas kelompok 3 RPL menjadi Rp 350.000 (sesuai spesifikasi)
    _kasKelompok = KasKelompokModel(
      id: 'kas_rpl_03',
      title: 'Kas Kelompok 3 RPL',
      memberCount: 4,
      collectedAmount: 350000,
      targetAmount: 500000,
    );

    // 3. Catat di riwayat transaksi personal Dinda
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        title: 'Patungan: $placeName',
        subtitle: 'Auto-debit kas kelompok • Lunas ✓',
        date: DateTime.now(),
        amount: personalAmount,
        isIncome: false,
        status: 'Sukses',
        referenceNumber: 'PG-SPLIT-${DateTime.now().millisecondsSinceEpoch}',
        category: 'Patungan Pintar',
      ),
    );

    // 4. Catat mutasi masuk otomatis di buku kas kelompok
    _kasMutasi.insert(
      0,
      KasMutasiModel(
        title: '+Rp 100.000 dari Patungan Pintar Struk',
        subtitle: 'Otomatis dari $placeName • 4 Anggota Lunas',
        amount: totalAmount,
        isIncome: true,
        date: DateTime.now(),
        hasReceipt: true,
        uploader: 'Taufiq, Naufal, Maya, Rahmat',
      ),
    );

    notifyListeners();
  }


  // Pembelian Token Listrik PLN
  bool bayarTokenListrik({required double amount, required String idPelanggan, required String tokenCode}) {
    if (_user.saldoUtama < amount) return false;

    _user = _user.copyWith(saldoUtama: _user.saldoUtama - amount);
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        title: 'Token Listrik PLN',
        subtitle: 'ID: $idPelanggan • Sukses',
        date: DateTime.now(),
        amount: amount,
        isIncome: false,
        status: 'Sukses',
        referenceNumber: 'PG-PLN-${DateTime.now().millisecondsSinceEpoch}',
        category: 'Tagihan',
      ),
    );
    notifyListeners();
    return true;
  }

  // Pembayaran Transaksi QRIS Resmi
  bool bayarQris({
    required double amount,
    required String merchantName,
    String? city,
  }) {
    if (_user.saldoUtama < amount) return false;

    _user = _user.copyWith(saldoUtama: _user.saldoUtama - amount);
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        title: 'QRIS: $merchantName',
        subtitle: '${city ?? 'Indonesia'} • Sukses',
        date: DateTime.now(),
        amount: amount,
        isIncome: false,
        status: 'Sukses',
        referenceNumber: 'PG-QRIS-${DateTime.now().millisecondsSinceEpoch}',
        category: 'QRIS',
      ),
    );

    notifyListeners();
    return true;
  }

  // Pembelian Pulsa & Paket Data
  bool beliPulsa({required double amount, required String phone, required String packageName}) {
    if (_user.saldoUtama < amount) return false;

    _user = _user.copyWith(saldoUtama: _user.saldoUtama - amount);
    _transactions.insert(
      0,
      TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        title: 'Pulsa / Paket Data',
        subtitle: '$phone ($packageName) • Sukses',
        date: DateTime.now(),
        amount: amount,
        isIncome: false,
        status: 'Sukses',
        referenceNumber: 'PG-PLS-${DateTime.now().millisecondsSinceEpoch}',
        category: 'Pulsa',
      ),
    );
    notifyListeners();
    return true;
  }
}

