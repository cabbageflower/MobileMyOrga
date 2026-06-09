import 'package:flutter/material.dart';
import 'pages/main/main_pengurus_page.dart';
import 'pages/main/main_anggota_page.dart';
import 'app_colors.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> result = {};
      try {
        result = await ApiService.login(
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        result = {
          'success': false,
          'message': 'Terjadi kesalahan: $e',
        };
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }

      if (!mounted) return;

      if (result['success']) {
        if (result['role'] == 'pengurus' || result['role'] == 'manajemen') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPengurusPage()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainAnggotaPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email dan password tidak boleh kosong.'),
          backgroundColor: brandDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Stack(
        children: [
          // Background grid pattern
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // Blur blob
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandPrimary.withOpacity(0.12),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // Logo + App name
                    Column(
                      children: [
                        Container(
                          child: Image.asset(
                            'assets/logoaplikasi.png',
                            width: 72,
                            height: 72,
                          ),
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          'MyOrga',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: brandDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Card form
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: brandSecondary.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: brandDark.withOpacity(0.06),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Masuk',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111844),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          _buildLabel('Email'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _emailController,
                            hint: 'nama@gmail.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          // Password
                          _buildLabel('Password'),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _passwordController,
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Color(0xFF111844),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Login button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF111844),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 24, height: 24, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                  )
                                : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: brandDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 14,
        color: brandDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Figtree',
          fontSize: 14,
          color: brandSecondary.withOpacity(0.6),
        ),
        prefixIcon: Icon(icon, color: brandSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandSecondary.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandSecondary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandPrimary, width: 1.5),
        ),
      ),
    );
  }
}

// Grid background painter — replikasi efek grid di hero web
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8896B3).withOpacity(0.08)
      ..strokeWidth = 0.5;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}