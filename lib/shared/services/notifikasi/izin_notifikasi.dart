// // path: lib/shared/services/notifikasi/izin_notifikasi.dart

// import 'dart:io';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/services.dart';

// Future<bool> pastikanIzinExactAlarm() async {
//   if (!Platform.isAndroid) return true;
  
//   final bool? canSchedule = await AndroidAlarmManager.canScheduleExactAlarms();
//   if (canSchedule == false) {
//     // Buka pengaturan aplikasi untuk mengaktifkan ulang Exact Alarm
//     AndroidAlarmManager.requestExactAlarmsPermission();
//     return false;
//   }
//   return true;
// }