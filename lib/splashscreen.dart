import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart';
import 'login_page.dart';
import 'pages/main/main_pengurus_page.dart';
import 'pages/main/main_anggota_page.dart';
import 'services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu minimal 2 detik untuk efek splash screen
    await Future.delayed(const Duration(seconds: 2));

    final token = await ApiService.getToken();
    final role = await ApiService.getRole();

    if (!mounted) return;

    if (token != null && role != null) {
      if (role == 'pengurus' || role == 'manajemen') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPengurusPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainAnggotaPage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), 
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logoaplikasi.png',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(height: 5),
                const Text(
                  'MyOrga',
                  style: TextStyle(
                    fontFamily: 'Figtree', 
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111844), 
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
