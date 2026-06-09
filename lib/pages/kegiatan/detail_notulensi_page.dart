import 'package:flutter/material.dart';
import '../../app_colors.dart';

class DetailNotulensiPage extends StatelessWidget {
  final String title;
  final String content;

  const DetailNotulensiPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Notulensi Kegiatan',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: brandDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: brandDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: brandDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brandSecondary.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: brandDark.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                content.isNotEmpty ? content : 'Tidak ada notulensi.',
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 15,
                  color: brandDark,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
