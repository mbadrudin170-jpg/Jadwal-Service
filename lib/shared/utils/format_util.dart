// File: lib/shared/utils/format_util.dart
import 'package:intl/intl.dart';

class FormatWaktuLengkap {
  FormatWaktuLengkap._();

  static String formatLengkap(DateTime date) {
    final format = DateFormat('d MMM yyyy, HH:mm');
    return format.format(date);
  }

  static String formatSingkat(DateTime date) {
    final format = DateFormat('E, d MMM yy, HH:mm');
    return format.format(date);
  }
}

class FormatTanggal {
  FormatTanggal._();

  static String formatDasar(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  static String formatSingkat(DateTime date) {
    return DateFormat('E, d MMM yy').format(date);
  }

  static String formatBulanTahun(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}

class FormatJam {
  FormatJam._();

  static String formatJamMenit(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatJamMenitDetik(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static String formatTextToHour(String timeText) {
    try {
      final dateTime = DateTime.parse(timeText);
      return DateFormat('HH:mm').format(dateTime);
    } on Exception {
      return '--:--';
    }
  }
}

class FormatUang {
  FormatUang._();
  static String formatMataUang(double amount) {
    final formatter = NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount.abs());
  }
}

class FormatNomor {
  FormatNomor._();

  static String formatRibuan(int value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }
}
