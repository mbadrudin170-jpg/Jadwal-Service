import 'package:flutter/material.dart';
import 'package:wifi/shared/common/text_input_field.dart';
import 'package:wifi/user/halaman/tambah_data_page.dart'; // Import halaman baru

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('User Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextInputField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            CustomTextInputField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Logic for login will go here
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // full width
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 12), // Spasi antar tombol
            // Tombol baru untuk navigasi ke halaman tambah data
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahDataPage()),
                );
              },
              child: const Text('Buka Halaman Tambah Catatan (Dev)'),
            ),
          ],
        ),
      ),
    );
  }
}
