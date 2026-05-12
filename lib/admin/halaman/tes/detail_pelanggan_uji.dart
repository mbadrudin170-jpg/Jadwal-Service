// path: lib/halaman/tes/detail_pelanggan_uji.dart


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class DetailPelangganPage extends StatefulWidget {
  const DetailPelangganPage({super.key});

  @override
  State<DetailPelangganPage> createState() => _DetailPelangganPageState();
}

class _DetailPelangganPageState extends State<DetailPelangganPage> {
  bool _showPassword = false;
  bool _showToast = false;
  String _toastMessage = 'Info telah disalin';

  // Data pelanggan (sama seperti di React)
  final Map<String, dynamic> customer = {
    'name': 'Rivai Ardiansyah',
    'email': 'rivai.ardi@email.com',
    'phone': '+62 812 3456 7890',
    'password': 'password123456',
    'address': 'Jl. Melati No. 123, Jakarta Selatan',
    'joinDate': '12 Maret 2023',
    'status': 'Premium Member',
    'id': 'CS-89241',
    'rating': 4.8,
    'lastActive': '2 jam yang lalu',
    'macAddress': '08:00:27:6B:4A:BD',
  };

  void _handleCopy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    setState(() {
      _toastMessage = '$label telah disalin';
      _showToast = true;
    });
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  void _handleCopyAll() {
    String allInfo =
        "Nama: ${customer['name']}\nEmail: ${customer['email']}\n"
        "Phone: ${customer['phone']}\nAlamat: ${customer['address']}\nID: ${customer['id']}";
    Clipboard.setData(ClipboardData(text: allInfo));
    setState(() {
      _toastMessage = 'Info telah disalin';
      _showToast = true;
    });
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // amber-50
      body: Stack(
        children: [
          // Header Background (Purple Section)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4C1D95), // purple-900
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative Circles (Blur effect simulated)
                  Positioned(
                    top: -40,
                    left: -40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        // diperbaiki: Mengganti withOpacity dengan withAlpha.
                        color: Colors.white.withAlpha((255 * 0.05).round()),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Scroll Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Detail Pelanggan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      _ActionButton(icon: Icons.edit, onPressed: () {}),
                    ],
                  ),
                ),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Profile Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                // diperbaiki: Mengganti withOpacity dengan withAlpha.
                                color: const Color(
                                  0xFF581C87,
                                ).withAlpha((255 * 0.05).round()),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                customer['name'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Points Button (Gradient)
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFCD34D),
                                        Color(0xFFFBBF24),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        // diperbaiki: Mengganti withOpacity dengan withAlpha.
                                        color: const Color(
                                          0xFFFBBF24,
                                        ).withAlpha((255 * 0.4).round()),
                                        blurRadius: 40,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.monetization_on,
                                            size: 16,
                                            color: Color(0xFF78350F),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'SALDO POIN',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF78350F),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            '500',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF451A03),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'PTS',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF78350F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Info List Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                // diperbaiki: Mengganti withOpacity dengan withAlpha.
                                color: const Color(
                                  0xFF581C87,
                                ).withAlpha((255 * 0.05).round()),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'EMAIL',
                                value: customer['email'],
                                icon: Icons.mail_outline,
                                onCopy: () =>
                                    _handleCopy(customer['email'], 'Email'),
                              ),
                              _InfoRow(
                                label: 'NOMOR TELEPON',
                                value: customer['phone'],
                                icon: Icons.phone_outlined,
                                onCopy: () => _handleCopy(
                                  customer['phone'],
                                  'Nomor Telepon',
                                ),
                              ),
                              _InfoRow(
                                label: 'PASSWORD',
                                value: _showPassword
                                    ? customer['password']
                                    : '••••••••••••',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                showPassword: _showPassword,
                                onTogglePassword: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                                onCopy: () => _handleCopy(
                                  customer['password'],
                                  'Password',
                                ),
                              ),
                              _InfoRow(
                                label: 'ALAMAT',
                                value: customer['address'],
                                icon: Icons.map_outlined,
                                onCopy: () =>
                                    _handleCopy(customer['address'], 'Alamat'),
                              ),
                              _InfoRow(
                                label: 'MAC ADDRESS',
                                value: customer['macAddress'],
                                icon: Icons.security,
                                onCopy: () => _handleCopy(
                                  customer['macAddress'],
                                  'Mac Address',
                                ),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Master Copy Button
                        GestureDetector(
                          onTap: _handleCopyAll,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: const Color(0xFFF3E8FF),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  // diperbaiki: Mengganti withOpacity dengan withAlpha.
                                  color: const Color(
                                    0xFF581C87,
                                  ).withAlpha((255 * 0.05).round()),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F3FF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.copy,
                                    color: Color(0xFF7C3AED),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CLIPBOARD',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Text(
                                      'Salin Info Pelanggan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom Indicator (Mimics Home Indicator)
                Container(
                  height: 32,
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Toast Notification
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            bottom: _showToast ? 60 : -100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showToast ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        // diperbaiki: Mengganti withOpacity dengan withAlpha.
                        color: Colors.black.withAlpha((255 * 0.3).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _toastMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper untuk tombol bulat di App Bar
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // diperbaiki: Mengganti withOpacity dengan withAlpha.
          color: Colors.white.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// Widget helper untuk baris informasi pelanggan
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onTogglePassword;
  final VoidCallback onCopy;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isPassword = false,
    this.showPassword = false,
    this.onTogglePassword,
    required this.onCopy,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (isPassword)
                    IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: onTogglePassword,
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 18,
                      color: Color(0xFFA855F7),
                    ),
                    onPressed: onCopy,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Container(height: 1, color: const Color(0xFFF8FAFC)),
      ],
    );
  }
}
