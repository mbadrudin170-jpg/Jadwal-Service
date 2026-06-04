# // path: prompt/aturan_analisis_error.md


---

### Aturan Analisis error
1. jika terjadi error  maka AI di wajibkan membaca file yang bersangkutan, misalnya jika ada sebuah kode yang error didalam file maka AI harus melakukan analysa apakah kode ini menggunakan kode dari file lain, maka AI wajib membaca file yang di import nya itu
2. kalau AI tidak tahu path file yang di import nya itu maka AI di wajibkan menjalankan `ls -R lib test` agar bisa lebih akurat lagi.
4. AI hanya berfokus pada kode yang bermasalah saja dan jangan menyentuh kode yang tidak bermasalah, tetapi kalau kode tersebut bersangkutan dengan kode yang error maka AI boleh menyentuh kode itu.
