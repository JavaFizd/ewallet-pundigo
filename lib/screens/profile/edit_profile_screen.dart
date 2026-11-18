import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/app_state.dart';
import '../../models/user_model.dart';
import '../../widgets/common/plus_upgrade_dialog.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/profile/photo_picker_modal.dart';
import '../kyc/kyc_ktp_camera_screen.dart';

/// ============================================================================
/// HALAMAN INFORMASI AKUN & UBAH DATA DIRI (100% IDENTIK DENGAN FIGMA)
/// ============================================================================
/// Menyajikan seluruh elemen desain resmi:
/// 1. AppBar: 'Informasi Akun' dengan leading back dan aksi profil + logo PG.
/// 2. Header: 'Ubah Data Diri' + 'Kelola identitas dan kredensial akunmu' + Badge '● Akun Basic'.
/// 3. Avatar tengah: Inisial otomatis dinamis (misal: 'DS'), badge kamera, link 'Ubah Foto Profil'.
/// 4. Input Nama Lengkap / Panggilan dengan ikon pensil toska & keterangan resmi.
/// 5. Input Nomor Handphone dengan centang verifikasi hijau, tombol 'Ubah', dan status SMS OTP.
/// 6. Kartu Promo Gradien PundiGo Plus: 'Ingin nikmati limit saldo hingga Rp20 Juta?' + tombol 'Upgrade Sekarang ➔'.
/// 7. Bagian Data Kependudukan (KTP): NIK, Tanggal Lahir, Jenis Kelamin, Alamat Domisili KTP (Status Terkunci/Terverifikasi).
/// 8. Tombol 'Simpan Perubahan' dengan gradien toska-ke-biru elegan.
/// ============================================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AppState _appState = AppState.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String? _currentPhotoUrl;
  String? _currentKtpPhotoUrl;
  bool _isEditingPhone = false;

  @override
  void initState() {
    super.initState();
    final user = _appState.user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _emailController = TextEditingController(text: user.email);
    _currentPhotoUrl = user.photoUrl;
    _currentKtpPhotoUrl = user.ktpPhotoUrl;

    // Perbarui inisial avatar secara real-time saat pengguna mengetik nama baru
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _openPhotoPicker() {
    final previewUser = _appState.user.copyWith(
      name: _nameController.text.trim(),
      photoUrl: _currentPhotoUrl,
      clearPhoto: _currentPhotoUrl == null || _currentPhotoUrl!.isEmpty,
    );

    PhotoPickerModal.show(
      context,
      user: previewUser,
      isKtpMode: false,
      onPhotoSelected: (selectedPhoto) {
        setState(() {
          _currentPhotoUrl = selectedPhoto;
        });

        if (selectedPhoto == null) {
          final initials = UserModel.computeInitials(_nameController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Foto profil dihapus. Sistem otomatis menampilkan inisial "$initials".',
              ),
              backgroundColor: const Color(0xFF00796B),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil dipilih!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  Future<void> _openKtpPhotoPicker() async {
    final scanned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const KycKtpCameraScreen(returnToProfile: true),
      ),
    );
    if (scanned == true && mounted) {
      setState(() {
        _currentKtpPhotoUrl = _appState.user.ktpPhotoUrl;
        _currentPhotoUrl = _appState.user.photoUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan e-KTP berhasil! Foto profil otomatis berubah mengikuti foto KTP.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _saveProfile() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap tidak boleh kosong.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    _appState.updateUserProfile(
      name: newName,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      photoUrl: _currentPhotoUrl,
      clearPhoto: _currentPhotoUrl == null || _currentPhotoUrl!.isEmpty,
      ktpPhotoUrl: _currentKtpPhotoUrl,
      clearKtpPhoto: _currentKtpPhotoUrl == null || _currentKtpPhotoUrl!.isEmpty,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan profil berhasil disimpan!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = _appState.user;
    final liveName = _nameController.text.trim().isEmpty ? user.name : _nameController.text.trim();
    final liveInitials = UserModel.computeInitials(liveName);

    final previewUser = user.copyWith(
      name: liveName,
      initials: liveInitials,
      photoUrl: _currentPhotoUrl,
      clearPhoto: _currentPhotoUrl == null || _currentPhotoUrl!.isEmpty,
      ktpPhotoUrl: _currentKtpPhotoUrl,
      clearKtpPhoto: _currentKtpPhotoUrl == null || _currentKtpPhotoUrl!.isEmpty,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Informasi Akun',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF00A887),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              'assets/images/logo_pg_mark_hd.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================================
              // 1. HEADER HALAMAN: 'Ubah Data Diri' + BADGE STATUS
              // ===============================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubah Data Diri',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kelola identitas dan kredensial akunmu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: user.isPlus ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: user.isPlus ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: user.isPlus ? const Color(0xFF0284C7) : const Color(0xFF00A887),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.isPlus ? 'Akun Plus' : 'Akun Basic',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: user.isPlus ? const Color(0xFF0369A1) : const Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ===============================================================
              // 2. AVATAR TENGAH (INISIAL OTOMATIS + BADGE KAMERA)
              // ===============================================================
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Lingkaran Avatar Utama
                        GestureDetector(
                          onTap: _openPhotoPicker,
                          child: Container(
                            width: 94,
                            height: 94,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE0E7FF), // Soft Indigo/Lavender
                              border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: UserAvatar(
                                user: previewUser,
                                radius: 47,
                                showCameraBadge: false,
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),

                        // Badge Kamera di Sudut Kanan Bawah
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _openPhotoPicker,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00695C), // Dark Emerald Teal
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Tautan Ubah Foto Profil
                    InkWell(
                      onTap: _openPhotoPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Ubah Foto Profil',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00A887),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===============================================================
              // 3. INPUT: NAMA LENGKAP / PANGGILAN
              // ===============================================================
              Text(
                'Nama Lengkap / Panggilan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _nameController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    suffixIcon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF00A887),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Nama yang digunakan dan ditampilkan di aplikasi PundiGo!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 18),

              // ===============================================================
              // 4. INPUT: NOMOR HANDPHONE
              // ===============================================================
              Text(
                'Nomor Handphone',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        enabled: _isEditingPhone,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF059669),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isEditingPhone = !_isEditingPhone;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isEditingPhone ? const Color(0xFF00A887) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isEditingPhone ? 'Selesai' : 'Ubah',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _isEditingPhone ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 13, color: Color(0xFF059669)),
                  const SizedBox(width: 4),
                  Text(
                    'Terverifikasi melalui SMS OTP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ===============================================================
              // 5. BANNER PROMO PUNDIGO PLUS (GRADIENT BIRU-TOSKA)
              // ===============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00A887), // Rich Emerald
                      Color(0xFF0288D1), // Ocean Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A887).withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Lingkaran dekoratif transparan
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingin nikmati limit saldo hingga\nRp20 Juta?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data identitas resmi (NIK, Tanggal Lahir, Jenis Kelamin, Alamat) dapat diakses dan diverifikasi penuh setelah verifikasi Akun Plus.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.92),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () => PlusUpgradeDialog.show(context, featureName: 'Akses Data Kependudukan KTP'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Upgrade Sekarang',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF00A887),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Color(0xFF00A887),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===============================================================
              // 6. BAGIAN: DATA KEPENDUDUKAN (KTP)
              // ===============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Kependudukan (KTP)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        user.isPlus ? Icons.verified : Icons.lock_outline_rounded,
                        size: 13,
                        color: user.isPlus ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.isPlus ? 'Terverifikasi' : 'Fitur Terkunci',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: user.isPlus ? const Color(0xFF059669) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Field 1: NIK
              _buildKtpField(
                label: 'Nomor Induk Kependudukan (NIK)',
                value: (user.isPlus || previewUser.hasKtpPhoto) ? '1171025805980002' : 'Wajib Upgrade PundiGo! Plus',
                icon: (user.isPlus || previewUser.hasKtpPhoto) ? Icons.verified_outlined : Icons.lock_outline_rounded,
              ),

              const SizedBox(height: 12),

              // Field 2: Tanggal Lahir
              _buildKtpField(
                label: 'Tanggal Lahir',
                value: (user.isPlus || previewUser.hasKtpPhoto) ? '14 Mei 1998' : 'Belum terverifikasi',
                icon: Icons.calendar_today_outlined,
              ),

              const SizedBox(height: 12),

              // Field 3: Jenis Kelamin
              _buildKtpField(
                label: 'Jenis Kelamin',
                value: (user.isPlus || previewUser.hasKtpPhoto) ? 'Perempuan' : 'Belum terverifikasi',
                icon: (user.isPlus || previewUser.hasKtpPhoto) ? Icons.verified_outlined : Icons.lock_outline_rounded,
              ),

              const SizedBox(height: 12),

              // Field 4: Alamat Domisili KTP
              _buildKtpField(
                label: 'Alamat Domisili KTP',
                value: (user.isPlus || previewUser.hasKtpPhoto) ? 'Jl. Teuku Nyak Arief No. 45, Banda Aceh' : 'Belum terverifikasi',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 14),

              // Field 5: Foto / Kartu e-KTP (Sesuai Revisi Dosen)
              _buildKtpPhotoCard(
                isPlus: user.isPlus,
                liveName: liveName,
                previewUser: previewUser,
              ),

              const SizedBox(height: 32),

              // ===============================================================
              // 7. TOMBOL BESAR: SIMPAN PERUBAHAN
              // ===============================================================
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00A887),
                      Color(0xFF0288D1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A887).withOpacity(0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveProfile,
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.white.withOpacity(0.2),
                    child: Center(
                      child: Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKtpPortrait(UserModel previewUser, {double width = 66, double height = 84}) {
    Widget content;
    if (previewUser.hasKtpPhoto) {
      final photo = previewUser.ktpPhotoUrl!.trim();
      if (photo.startsWith('assets/')) {
        content = Image.asset(photo, width: width, height: height, fit: BoxFit.cover);
      } else if (photo.startsWith('http://') || photo.startsWith('https://')) {
        content = Image.network(
          photo,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildKtpEmptyPortrait(),
        );
      } else if (photo.startsWith('data:image') || photo.length > 100) {
        try {
          final cleanBase64 = photo.contains(',') ? photo.split(',').last : photo;
          content = Image.memory(base64Decode(cleanBase64), width: width, height: height, fit: BoxFit.cover);
        } catch (_) {
          content = _buildKtpEmptyPortrait();
        }
      } else {
        content = _buildKtpEmptyPortrait();
      }
    } else {
      content = _buildKtpEmptyPortrait();
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: content,
      ),
    );
  }

  Widget _buildKtpEmptyPortrait() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 32, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildKtpPhotoCard({
    required bool isPlus,
    required String liveName,
    required UserModel previewUser,
    bool interactive = true,
  }) {
    final hasKtpPhoto = previewUser.hasKtpPhoto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Foto KTP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              hasKtpPhoto ? 'e-KTP Terpasang' : 'Belum Dimasukkan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasKtpPhoto ? const Color(0xFF059669) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (!hasKtpPhoto)
          // TAMPILAN SEBELUM MEMASUKKAN KTP -> TOMBOL MUDAH "MASUKKAN KTP"
          InkWell(
            onTap: interactive ? _openKtpPhotoPicker : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF99F6E4), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6FAF5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.credit_card_rounded,
                      color: Color(0xFF00897B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Masukkan Foto e-KTP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Unggah e-KTP untuk melengkapi data identitas & memperbarui foto profil otomatis',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A887), Color(0xFF0288D1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00A887).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.document_scanner_rounded, size: 15, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Scan & Masukkan KTP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // TAMPILAN SESUDAH MEMASUKKAN KTP -> KARTU e-KTP REALISTIS INDONESIA!
          Column(
            children: [
              InkWell(
                onTap: interactive ? _openKtpPhotoPicker : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFC5EBF9),
                        Color(0xFF9ADAF4),
                        Color(0xFFD6F1FC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1.3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withOpacity(0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Resmi e-KTP RI
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'PROVINSI ACEH',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'KOTA BANDA ACEH',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, color: const Color(0xFF0369A1).withOpacity(0.25)),
                      const SizedBox(height: 8),

                      // NIK Besar Khas e-KTP
                      Row(
                        children: [
                          SizedBox(
                            width: 74,
                            child: Text(
                              'NIK',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Text(
                            ':  1171025805980002',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 0.9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Isi Data e-KTP Kiri + Pasfoto Cewek Kanan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ktpDataRow('Nama', liveName.toUpperCase(), boldValue: true),
                                _ktpDataRow('Tempat/Tgl Lahir', 'BANDA ACEH, 14-05-1998'),
                                _ktpDataRow('Jenis Kelamin', 'PEREMPUAN    Gol. Darah: O'),
                                _ktpDataRow('Alamat', 'JL. TEUKU NYAK ARIEF NO. 45'),
                                _ktpDataRow('   RT/RW', '002 / 004'),
                                _ktpDataRow('   Kel/Desa', 'DARUSSALAM'),
                                _ktpDataRow('   Kecamatan', 'SYIAH KUALA'),
                                _ktpDataRow('Agama', 'ISLAM'),
                                _ktpDataRow('Status Kawin', 'BELUM KAWIN'),
                                _ktpDataRow('Pekerjaan', 'MAHASISWA'),
                                _ktpDataRow('Kewarganegaraan', 'WNI'),
                                _ktpDataRow('Berlaku Hingga', 'SEUMUR HIDUP'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Kolom Pasfoto + Tanggal + Tanda Tangan
                          Column(
                            children: [
                              _buildKtpPortrait(previewUser, width: 72, height: 92),
                              const SizedBox(height: 4),
                              Text(
                                'BANDA ACEH',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '18-11-2026',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                UserModel.computeInitials(liveName),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF0F172A).withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (interactive) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 5),
                        Text(
                          'e-KTP terpasang & foto profil diperbarui',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _openKtpPhotoPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FAF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                        ),
                        child: Text(
                          'Scan Ulang KTP',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00796B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _ktpDataRow(String label, String value, {bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.2,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              ': $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.4,
                fontWeight: boldValue ? FontWeight.w800 : FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKtpField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ],
    );
  }
}
