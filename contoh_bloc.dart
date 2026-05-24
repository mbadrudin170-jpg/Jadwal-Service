// // path: contoh_bloc.dart
// // Ini adalah contoh implementasi BLoC (Business Logic Component) yang sederhana.
// //
// // Tujuannya adalah untuk mengelola sebuah state (data) berupa angka (integer)
// // dan merespons terhadap dua event (peristiwa):
// // 1. Menambah angka (Increment)
// // 2. Mengurangi angka (Decrement)
// //
// // File ini menunjukkan tiga komponen utama BLoC:
// // 1. Event: Perintah yang dikirim dari UI ke BLoC.
// // 2. State: Representasi data yang akan dikirim dari BLoC ke UI.
// // 3. Bloc: Kelas yang menjadi "otak" untuk menerima Event dan menghasilkan State baru.

// import 'package:bloc/bloc.dart';

// // --- BAGIAN 1: EVENT ---
// // Event adalah input atau perintah yang dikirim dari UI ke BLoC.
// // Kita mulai dengan membuat abstract class untuk semua event yang berhubungan dengan Counter.
// abstract class CounterEvent {}

// // Event untuk memberitahu BLoC bahwa kita ingin "menambah" angka.
// // Kelas ini tidak perlu punya isi, namanya saja sudah cukup jelas.
// class CounterIncremented extends CounterEvent {}

// // Event untuk memberitahu BLoC bahwa kita ingin "mengurangi" angka.
// class CounterDecremented extends CounterEvent {}


// // --- BAGIAN 2: STATE ---
// // State adalah output atau data yang dikirim dari BLoC untuk ditampilkan di UI.
// // State ini merepresentasikan "keadaan" dari aplikasi kita pada satu waktu.

// // Dalam kasus ini, state kita sangat sederhana: hanya satu angka (integer).
// // Kita buat sebuah kelas untuk membungkus angka tersebut.
// class CounterState {
//   final int count;

//   // Constructor untuk membuat state dengan nilai angka awal.
//   const CounterState(this.count);
// }


// // --- BAGIAN 3: BLOC ---
// // Bloc adalah komponen inti yang menghubungkan Event dan State.
// // Dia menerima Event, memprosesnya, dan menghasilkan State baru.

// // Kelas CounterBloc mewarisi (extends) kelas `Bloc` dari package flutter_bloc.
// // `Bloc<CounterEvent, CounterState>` berarti: "Ini adalah BLoC yang
// // menerima turunan dari CounterEvent dan menghasilkan CounterState".
// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   // Constructor BLoC.
//   CounterBloc() : super(const CounterState(0)) { // `super(CounterState(0))` artinya state awal saat BLoC pertama kali dibuat adalah angka 0.

//     // Di sini kita mendaftarkan "handler" atau penangan untuk setiap event.
    
//     // 1. Handler untuk event `CounterIncremented`
//     // `on<NamaEvent>((event, emit) { ... })`
//     on<CounterIncremented>((event, emit) {
//       // `event`: Berisi data dari event yang masuk (jika ada).
//       // `emit`: Adalah fungsi untuk "memancarkan" atau mengeluarkan state baru.

//       // Logika bisnis kita:
//       // Ambil state saat ini (`state.count`), tambahkan 1, lalu emit state baru.
//       emit(CounterState(state.count + 1));
//     });

//     // 2. Handler untuk event `CounterDecremented`
//     on<CounterDecremented>((event, emit) {
//       // Logika bisnis kita:
//       // Ambil state saat ini (`state.count`), kurangi 1, lalu emit state baru.
//       emit(CounterState(state.count - 1));
//     });
//   }
// }

// /*
// --- Bagaimana Cara Kerjanya di UI (Gambaran)? ---

// 1. Di UI, Anda akan membuat instance dari CounterBloc:
//    final CounterBloc counterBloc = CounterBloc();

// 2. Untuk menampilkan angka, Anda akan "mendengarkan" state dari `counterBloc`.
//    Setiap kali BLoC meng-`emit` state baru, UI akan otomatis meng-update angka yang tampil.

// 3. Di UI, ada tombol tambah (+) dan kurang (-).
//    - Saat tombol (+) ditekan, Anda akan mengirim event `CounterIncremented`:
//      `counterBloc.add(CounterIncremented());`

//    - Saat tombol (-) ditekan, Anda akan mengirim event `CounterDecremented`:
//      `counterBloc.add(CounterDecremented());`

// 4. Ketika `counterBloc` menerima event `CounterIncremented`, dia akan menjalankan logikanya
//    dan meng-`emit` `CounterState(1)`. UI yang mendengarkan akan langsung berubah menampilkan angka 1.
   
// 5. Proses ini terus berulang, memisahkan total logika dari tampilan.
// */
