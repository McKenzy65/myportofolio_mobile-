# Catatan bantuan AI untuk Tugas 8

Pemilik proyek menggunakan Codex (OpenAI) untuk menyunting proyek Flutter, menyusun pengujian, dan menulis draf empat refleksi di README. Berikut cuplikan percakapan dan keputusan yang memengaruhi implementasi.

| Arahan pemilik proyek | Pengaruh pada pekerjaan |
| --- | --- |
| “Kamu bantu edit kodenya, lalu jelaskan tiap tahap dan cara saya mencobanya.” | Codex menyunting kode dan menyiapkan demonstrasi yang bisa diulang dari kartu maupun drawer. |
| “ASTAGA HARUSNYA KERJAIN YG TUGAS 7 bukan tugas 8 gw salah ngasih file” | Pada tahap sebelumnya, pemilik mengoreksi dokumen acuan dan menyunting README Tugas 7. Pekerjaan sertifikasi waktu itu tersedia sebagai cadangan lokal. |
| “bantu mas sesuai checklist dan gw mau full point nilai nya 4” dengan lampiran `tugas-8 (1).pdf` | Untuk tugas kali ini, Codex membaca checklist Tugas 8 dan mencocokkan cadangan dengan halaman utama, formulir proyek, tema, dan drawer yang sekarang ada. |

### Keputusan dan koreksi

- Pada cadangan lama, susunan kartu berbeda dari halaman utama Tugas 7 saat ini. Codex menambahkan tujuan sertifikasi pada model aksi yang dipakai sekarang dan memakai kembali drawer Tutorial 09. Dengan demikian identitas pemilik, salin NPM, pilihan tema, dan jalur **Add Project** tetap bisa digunakan.
- Angka empat digit tampak wajar untuk tahun, tetapi model Django `Certification.year` memakai `PositiveIntegerField`. Validator menerima bilangan bulat desimal dalam rentang 0–2147483647. Judul wajib dan maksimal 255 karakter setelah spasi tepi dibuang. Deskripsi wajib. Status unggulan merupakan pilihan ya/tidak.
- Pratinjau dapat memperlihatkan draf yang belum lengkap. Agar ini tidak disalahartikan sebagai keberhasilan **Simpan**, ringkasan baru dibuka setelah semua validator lulus. Ringkasan tidak mengirim data ke Django. Konfirmasi pindah halaman melindungi draf saat navigasi di aplikasi, sedangkan memuat ulang tab menghapus draf.
- Codex menyiapkan kasus uji untuk teks kosong, batas judul dan tahun, dua jalur navigasi, dialog, serta ruang layar terbatas. Hasil perangkat fisik dan konfirmasi administrasi Tutorial 09 di SCELE memerlukan pemeriksaan tersendiri.

Pemilik proyek memilih dokumen yang benar dan sebelumnya mengedit README Tugas 7. Adaptasi Dart, pengujian, serta penyusunan dokumentasi Tugas 8 di atas dikerjakan dengan bantuan langsung Codex.
