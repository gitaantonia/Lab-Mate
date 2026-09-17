import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'home_screen.dart';
import 'home_aslab_screen.dart';
import 'home_praktikan_screen.dart';
import '../utils/session_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final akun = await DBHelper.instance.login(username, password);

      if (akun == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username atau password salah')),
        );
        return;
      }
            // Pastikan role pilihan sesuai dengan role akun
      if (akun['role'] != selectedRole) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akun ini terdaftar sebagai ${akun['role']}. '
              'Silakan pilih role yang sesuai.',
            ),
          ),
        );
        return;
      }

      await SessionHelper.saveSession(
        akunId: akun['id'],
        username: akun['username'],
        role: akun['role'],
        praktikanId: akun['praktikan_id'],
      );

      if (!mounted) return;

      if (akun['role'] == 'aslab') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeAslabScreen()),
        );
      } else if (akun['role'] == 'praktikan') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePraktikanScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat login: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color lightBlue = Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========================================
                    // LOGO
                    // ========================================

                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: primaryBlue,
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'LabMate',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sistem Manajemen Praktikum',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ========================================
                    // LOGIN SEBAGAI
                    // ========================================
                    const Text(
                      'Login sebagai',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Aslab',
                            subtitle: 'Kelola praktikum',
                            icon: Icons.admin_panel_settings_rounded,
                            value: 'aslab',
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Praktikan',
                            subtitle: 'Lihat kegiatan',
                            icon: Icons.person_rounded,
                            value: 'praktikan',
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ========================================
                    // USERNAME
                    // ========================================
                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Masukkan username',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ========================================
                    // PASSWORD
                    // ========================================
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172033),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!isLoading) {
                          login();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ========================================
                    // LOGIN BUTTON
                    // ========================================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'Silakan masuk sesuai akun yang digunakan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final bool isSelected = selectedRole == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isLoading
          ? null
          : () {
              setState(() {
                selectedRole = value;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? color : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
