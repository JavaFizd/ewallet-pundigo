# PundiGo! 💳✨
> **Dompet Digital Mahasiswa & Solusi Finansial Komunitas Kampus**

PundiGo! adalah aplikasi dompet digital berbasis Flutter yang dirancang khusus untuk memecahkan masalah finansial nyata mahasiswa: transparansi kas kelompok (*Saku Kelompok*), pembagian tagihan makan bersama (*Patungan Pintar*), transfer gratis antar-bank, serta sistem verifikasi identitas (KYC) yang aman dan human-friendly.

---

## 🚀 Cara Menjalankan Aplikasi (Untuk Anggota Kelompok)

### Opsi 1: Paling Mudah (Tinggal Klik 2x untuk Windows) ⭐
Jika kamu mendownload file ZIP:
1. Ekstrak file ZIP-nya.
2. Buka foldernya, lalu **klik dua kali (double click) file `JALANKAN_PUNDIGO.bat`**.
3. File ini akan otomatis mengunduh dependensi (`flutter pub get`) dan langsung membuka aplikasi di Google Chrome!

---

### Opsi 2: Menggunakan Terminal / VS Code
Buka terminal di folder project, lalu jalankan:

```bash
# 1. Clone repository (jika menggunakan Git)
git clone https://github.com/JavaFizd/pundigo-project.git
cd pundigo-project

# 2. Unduh semua dependensi paket (menghilangkan garis merah di editor)
flutter pub get

# 3. Jalankan aplikasi di browser (Google Chrome)
flutter run -d chrome
```

> **Tips:** Jika ingin menjalankan di emulator Android / HP fisik, cukup jalankan:
> ```bash
> flutter run
> ```

---

## 👥 Akun Demo & Persona Pengujian

Aplikasi ini dilengkapi 2 persona pengujian untuk simulasi alur UX:

### 1. Akun Pengguna Baru (Dinda Syahfitri)
* **Karakteristik:** Akun baru terdaftar (Basic). Saldo awal Rp 0, riwayat aktivitas bersih, dan kas/patungan belum aktif.
* **Alur Pengujian:**
  * Saat mencoba melakukan **Transfer**, **Patungan Pintar**, atau **Saku Kelompok**, sistem mewajibkan verifikasi identitas (**KYC KTP & Wajah**).
  * Di menu **Minta Saldo**, belum ada kontak teman tersimpan (bisa input nomor HP manual).
  * Setelah verifikasi KTP & Wajah selesai, akun ter-upgrade ke **Plus** dan kas/patungan mulai dari kondisi bersih (*empty state*).

### 2. Akun Pengguna Lama / Power User (Taufiq)
* **Email:** `topikpanas@gmail.com`
* **No. Handphone:** `08123456789`
* **PIN Keamanan:** `171717`
* **Karakteristik:** Akun sudah ter-upgrade **PundiGo! Plus**.
  * Memiliki saldo aktif dan riwayat mutasi transaksi.
  * Memiliki Saku Kelompok aktif (*KAS KELOMPOK TUGAS UI/UX* dengan 4 anggota).
  * Memiliki tagihan Patungan Pintar aktif (*Warung Nasi & Mie Aceh*).
  * Di menu **Minta Saldo**, sudah terisi 5 kontak teman kampus (Dinda Kirana, Naufal Daffa, Rahmat Hidayat, dll.).

---

## 🎨 Import Desain ke Figma (Figma Plugin)

Untuk anggota kelompok yang ingin meninjau atau memodifikasi desain di Figma:
1. Buka Figma dan buat kanvas baru.
2. Buka menu **Plugins** ➔ **Development** ➔ **Import plugin from manifest...**.
3. Pilih file `figma_plugin/manifest.json`.
4. Jalankan plugin **PundiGo Screen Generator** untuk menghasilkan 16 Frame UI beresolusi tinggi secara otomatis.

---

## 🛠️ Struktur Folder Utama

```
lib/
├── core/            # Tema warna, konstanta, format uang, dan utilitas
├── data/            # State management (AppState) & data lokal (DummyData)
├── models/          # Model data pengguna, transaksi, kas, dan fitur
├── screens/
│   ├── auth/        # Login, Register, OTP, dan Buat/Konfirmasi PIN
│   ├── home/        # Dashboard utama (Header Saldo, Quick Actions, Promo)
│   ├── kyc/         # Panduan Foto KTP & Verifikasi Wajah (KYC Guide)
│   ├── activity/    # Riwayat aktivitas dan mutasi dompet
│   ├── qris/        # Pindai QRIS & Tampilkan Kode QR Saya
│   ├── features/    # Menu semua fitur (Pulsa, PLN, Kas, Patungan)
│   ├── profile/     # Profil akun, ubah data diri, pusat bantuan
│   └── transactions/# Transfer, Top Up, Minta Saldo, Patungan Pintar, Saku Kas
└── widgets/         # Komponen reusable (Buttons, App Bar, Cards, Modals)
```
