# Dokumentasi: `lib/shared/utils/active_customer_sorter.dart`

`ActiveCustomerSorter` adalah kelas utilitas statis yang dirancang khusus untuk menangani kebutuhan kompleks pengurutan daftar pelanggan aktif. Daripada menyebar logika pengurutan di dalam widget atau state management, kelas ini memusatkannya, menciptakan sebuah komponen yang bersih, dapat diuji, dan mudah diperluas.

---

## Arsitektur dan Desain

Desain kelas ini didasarkan pada dua komponen utama:

1.  **`SortOption` enum**: Enum ini mendefinisikan semua **strategi** pengurutan yang mungkin. Ini adalah inti dari desain. Menambahkan opsi pengurutan baru di masa depan semudah menambahkan nilai baru ke `enum` ini (dan tentu saja, logikanya di metode `sort`). Ini adalah implementasi yang efektif dari **Pola Desain Strategy**, di mana setiap nilai enum mewakili algoritma/strategi pengurutan yang berbeda.

2.  **Metode `sort()` statis**: Ini adalah satu-satunya titik masuk ke utilitas ini. Ia menerima daftar yang akan diurutkan, strategi pengurutan (`SortOption`), dan data tambahan yang mungkin diperlukan (`customerNameMap`). Metode ini tidak memodifikasi daftar asli; sebaliknya, ia membuat salinan (`List.of(customers)`) dan mengurutkan salinan tersebut. Ini adalah praktik yang baik (imutable) untuk menghindari efek samping yang tidak terduga di bagian lain aplikasi.

---

## Logika Pengurutan (Comparator)

Kekuatan sebenarnya terletak pada bagaimana ia membangun fungsi `comparator` di dalam `switch` statement. Mari kita bedah beberapa kasus yang menarik:

-   **Pengurutan Sederhana (`endDate`, `startDate`)**: Ini adalah kasus paling dasar, hanya menggunakan `compareTo` bawaan pada objek `DateTime`.

-   **Pengurutan dengan Fallback (`lastUpdated`)**: Logika untuk `lastUpdated` sangat tangguh. Ia mencoba menggunakan `updatedAt`, tetapi jika nilai itu `null`, ia akan beralih (`??`) ke `startDate`. Ini mencegah error dan memastikan selalu ada tanggal yang valid untuk perbandingan. Ia juga secara eksplisit mengurutkan secara descending (`dateB.compareTo(dateA)`) yang biasanya diinginkan untuk "terbaru".

-   **Pengurutan dengan Data Eksternal (`nameAZ`, `nameZA`)**: Untuk mengurutkan berdasarkan nama, ia memerlukan `customerNameMap` tambahan. Ini menunjukkan desain yang fleksibel. `ActiveCustomerModel` mungkin tidak (dan tidak seharusnya) menyimpan nama pelanggan secara langsung jika data dinormalisasi. Pemeta ini bertindak sebagai "jembatan". Penggunaan `?? '''` memastikan keamanan jika seorang pelanggan karena alasan tertentu tidak ada di dalam peta.

-   **Pengurutan Biner dengan Pengurutan Sekunder (`paid`, `unpaid`, `activePackage`, `inactivePackage`)**: Ini adalah kasus yang paling kompleks dan paling cerdas.
    -   **Pengelompokan**: Pertama, ia mengelompokkan daftar menjadi dua bagian (misalnya, Lunas dan Belum Lunas). Logika `(isPaidA ? -1 : 1)` secara efektif menempatkan semua item yang memenuhi kriteria di bagian atas tumpukan.
    -   **Pengurutan Sekunder**: Apa yang terjadi jika dua pelanggan sama-sama Lunas? `if (isPaidA == isPaidB)` menangani kasus ini. Alih-alih membiarkan urutannya acak, ia menerapkan pengurutan sekunder yang masuk akal, yaitu berdasarkan `endDate`. Ini membuat daftar terasa jauh lebih stabil dan terorganisir bagi pengguna akhir.
    -   **Delegasi Logika**: Untuk `activePackage`, ia tidak mengulang logika. Ia mendelegasikannya ke utilitas lain (`CalculationUtil.remainingDays`) untuk menentukan apakah sebuah paket masih aktif. Ini adalah contoh bagus dari pemisahan tanggung jawab.

---

## Kesimpulan

`ActiveCustomerSorter` adalah contoh textbook tentang bagaimana merancang utilitas yang terisolasi dan sangat fungsional. Dengan memisahkan strategi (`SortOption`) dari eksekusi (`sort` method) dan dengan menangani kasus-kasus tepi dan pengurutan sekunder dengan hati-hati, ia menyediakan fungsionalitas yang kuat dan dapat diandalkan yang mudah digunakan oleh bagian lain dari aplikasi. Ini adalah komponen yang membuat kode *view* dan *state management* tetap bersih dan fokus pada tanggung jawab mereka sendiri.
