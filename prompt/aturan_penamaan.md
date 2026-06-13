Berikut aturan naming versi **ringkas, jelas, dan siap dipakai** (Indonesia clean style):

---

# 📌 Aturan Naming (Class, Variabel, Parameter, Function)

## 1. CLASS → “Siapa / tanggung jawabnya”

* Gunakan **kata benda**
* Nama mewakili **entitas atau layanan**

**Contoh:**

* `Pelanggan`
* `Transaksi`
* `AutentikasiService`
* `SinkronisasiData`

---

## 2. VARIABEL → “Menyimpan apa”

* Gunakan **kata benda**
* Harus spesifik, jangan umum

**Contoh:**

* `namaPelanggan`
* `jumlahTagihan`
* `statusPembayaran`

❌ Hindari: `data`, `info`, `temp`

---

## 3. PARAMETER → “Input untuk apa”

* Sama seperti variabel, tapi konteksnya input fungsi
* Harus jelas maknanya

**Contoh:**

```dart
void simpanPelanggan(String namaPelanggan)
```

---

## 4. FUNCTION → “Melakukan apa”

* Gunakan **kata kerja + objek**
* Harus menggambarkan aksi

**Contoh:**

* `hitungTagihan()`
* `ambilDataPelanggan()`
* `simpanTransaksi()`
* `hapusPelanggan()`

---

## 5. ATURAN UMUM

* Pakai **bahasa Indonesia konsisten**
* Jangan campur Inggris & Indonesia dalam satu konsep
* Nama harus **jelas tanpa perlu baca isi kode**
* Jangan terlalu panjang, tapi juga jangan ambigu

---

## 6. TEST CEPAT (wajib sebelum pakai nama)

Tanya:

* Apakah langsung paham fungsinya?
* Apakah ini jelas tanpa konteks tambahan?
* Apakah ini tidak bisa disalahartikan?

Kalau “tidak yakin” → ganti nama.

---
