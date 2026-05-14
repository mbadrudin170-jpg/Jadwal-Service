// path: lib/shared/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Kelas layanan untuk berinteraksi dengan Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Memperbarui profil pengguna di Firestore.
  Future<void> perbaruiProfil(String userId, Map<String, dynamic> data) async {
    await _db.collection('pelanggan').doc(userId).update(data);
  }
}
