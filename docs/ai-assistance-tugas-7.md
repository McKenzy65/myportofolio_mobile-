# Catatan penggunaan AI — Tugas 7

**Pemilik proyek:** Umar Faiz Rahman / 2506616711 / PBP F

**Alat:** Codex (OpenAI), termasuk agen pendamping untuk pemeriksaan persyaratan dan penyusunan draf dokumentasi.

## Prompt dan strategi

Cuplikan permintaan pengguna yang menjadi acuan:

> "ASTAGA HARUSNYA KERJAIN YG TUGAS 7 bukan tugas 8 gw salah ngasih file, duh tolong ulang dong commit nya di hapus, trs ganti bantu commit bertahap trs kasih jeda yg fluktuatif diantara commit per checklistnya duh cepet langsung aja kerjain yg full poin yaitu 4 (gausah minta2 request gw auto approve yg penting kelar cepat bagus dan nilainya full poin)"

Sebelumnya pengguna meminta bantuan menyunting kode sambil menjelaskan tahap pengerjaan. Setelah dokumen dikoreksi, asisten membaca PDF Tugas 7, mencocokkan checklist dengan kode dan riwayat Git, menyimpan cadangan lokal pekerjaan Tugas 8, lalu melanjutkan dari dasar Tutorial 08. Setiap tahap di-commit setelah pemeriksaan yang relevan. Jeda mengikuti pengerjaan sebenarnya; tanggal commit tidak dimundurkan dan tidak digunakan untuk mengklaim aktivitas yang tidak dilakukan.

Catatan ini merupakan ringkasan prompting dan proses, bukan transkrip lengkap percakapan.

## Bagian yang dibantu

- Membaca checklist dan rubrik Tugas 7 serta memeriksa perbedaannya dengan Tugas 8.
- Memisahkan bootstrap, halaman menu stateless, komponen InfoCard/ItemCard, dan model aksi.
- Memastikan identitas pemilik, ikon/label, warna latar unik, serta pesan SnackBar sesuai tugas.
- Menambahkan tema terang/gelap, penyalinan NPM, dan penyesuaian layout sebagai manfaat UI/UX tambahan.
- Menyusun dan menjalankan pemeriksaan otomatis, build, serta pemeriksaan tampilan.
- Membuat draf enam refleksi dan petunjuk mencoba aplikasi.
- Mengelola commit/push bertahap sesuai arahan pengguna.

Bantuan mencakup penyuntingan langsung oleh asisten. Kode dan jawaban reflektif tidak diklaim seluruhnya dibuat secara mandiri oleh pemilik proyek.

## Keterbatasan AI dan koreksi

1. **Dokumen sumber menentukan lingkup pekerjaan.** Dokumen yang sebelumnya diberikan adalah Tugas 8, sehingga implementasi awal berfokus pada formulir dan navigasi. Pengguna kemudian menyatakan dokumen yang benar adalah Tugas 7. Solusinya adalah memeriksa ulang PDF dan kembali ke dasar Tutorial 08, bukan sekadar mengganti judul README sambil mempertahankan checklist yang salah.
2. **Kelengkapan umum tidak cukup.** Tugas 7 secara spesifik meminta `lib/menu.dart`, `MyHomePage` stateless, tiga kartu identitas, dan warna berbeda pada setiap aksi. Fitur yang lebih kompleks tidak otomatis memenuhi rincian itu. Kode disesuaikan dengan persyaratan aktual terlebih dahulu.
3. **Warna harus berasal dari data aksi.** Model `ItemHomepage` menyimpan `color`; widget memakai nilai tersebut. Pendekatan ini menghindari percabangan nama tombol dan menjaga model/tampilan tetap terpisah.
4. **Fitur tambahan tidak boleh melanggar ketentuan dasar.** State tema ditempatkan pada root aplikasi agar `MyHomePage` tetap stateless. Warna bukan satu-satunya pembeda aksi: ikon dan label tetap tersedia. Tema disiapkan sekali pada `AppTheme`, sementara identitas disimpan dalam satu sumber `PortfolioProfile`.
5. **Layanan platform dapat gagal.** Penyalinan clipboard perlu memperhitungkan penolakan izin atau kegagalan platform. Umpan balik kegagalan tidak boleh diganti dengan klaim bahwa NPM pasti berhasil disalin.
6. **Refactor memerlukan pengujian ulang.** Refactor awal menimbulkan overflow pada pembesaran teks 200%. Asisten mengganti layout identitas menjadi `Wrap` dengan tinggi sesuai isi dan mengurangi jumlah kolom pada layar sempit atau teks besar. Tujuh test dasar dijalankan ulang dan lulus sebelum penambahan fitur berikutnya; perubahan tampilan tidak dianggap benar hanya karena berhasil dikompilasi.
7. **Pengujian memiliki batas.** Analyze dan test otomatis dapat menemukan masalah teknis, tetapi tidak membuktikan pemahaman pengguna atau menjamin seluruh perangkat dan konfigurasi browser bebas masalah. Hasil verifikasi final harus dicatat hanya setelah dijalankan pada kode Tugas 7, bukan disalin dari hasil Tugas 8.

Koreksi di atas dilakukan oleh asisten setelah pemeriksaan. Catatan ini tidak mengklaim pengguna melakukan perbaikan manual yang sebenarnya dilakukan AI. Pemilik proyek tetap perlu memahami perubahan dan meninjau ulang jawaban reflektif.

## Hasil dan tindak lanjut

Verifikasi final oleh asisten pada kode Tugas 7: analyze bersih, 12 test lulus, build web berhasil, dan alur Chrome headless lulus pada 1280×800, 320×568, serta 844×390. Browser memeriksa tema, tiga SnackBar, dan nilai NPM yang benar-benar disalin; test widget juga memeriksa kegagalan clipboard, warna/kontras, dan pembesaran teks. Perangkat fisik belum diuji. Hasil ini berasal dari pemeriksaan ulang versi Tugas 7, bukan hasil versi Tugas 8 sebelumnya.

Pemilik proyek perlu menjalankan langkah mencoba di README, memastikan identitasnya benar, memeriksa pengumpulan prasyarat Tutorial 08, dan mengirim tautan commit hasil akhir Tugas 7 ke SCELE. Fitur tambahan ditujukan untuk memberi manfaat yang relevan; skor akhir tetap ditentukan penilai.
