import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../notifikasi/notifikasi_page.dart';
import '../kegiatan/detail_notulensi_page.dart';

class HomeAnggotaPage extends StatefulWidget {
  const HomeAnggotaPage({super.key});

  @override
  State<HomeAnggotaPage> createState() => _HomeAnggotaPageState();
}

class _HomeAnggotaPageState extends State<HomeAnggotaPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        await ApiService.updateFcmToken(token);
      }
    }
  }

  Future<void> _fetchData() async {
    final result = await ApiService.getHomeData();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success']) {
        _data = result['data'];
      } else {
        _errorMsg = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundLight,
        body: Center(child: CircularProgressIndicator(color: brandPrimary)),
      );
    }

    if (_errorMsg.isNotEmpty || _data == null) {
      return Scaffold(
        backgroundColor: backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMsg, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMsg = '';
                  });
                  _fetchData();
                },
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      );
    }

    final user = _data!['user'];
    final nextEvent = _data!['next_event'];
    final attStats = _data!['attendance_stats'];
    final recentAtts = _data!['recent_attendances'] as List;
    final notifications = _data!['notifications'] as List;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandPrimary.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              color: brandPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(user['full_name'], user['division'] ?? 'Anggota', notifications),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Kegiatan Mendatang'),
                  const SizedBox(height: 12),
                  nextEvent != null
                      ? _buildKegiatanMendatangCard(nextEvent)
                      : _buildEmptyState('Tidak ada kegiatan mendatang.'),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Riwayat Absensi'),
                  const SizedBox(height: 12),
                  _buildAbsensiSingkat(attStats, recentAtts),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Pengumuman Terbaru'),
                  const SizedBox(height: 12),
                  notifications.isNotEmpty
                      ? _buildPengumumanList(notifications)
                      : _buildEmptyState('Belum ada pengumuman.'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Figtree',
            color: brandSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String division, List<dynamic> notifications) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${name.split(" ")[0]} 👋',
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: brandDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: brandSecondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: brandSecondary.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_center_outlined, size: 13, color: brandSecondary),
                  const SizedBox(width: 5),
                  Text(
                    'Divisi $division • Anggota',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: brandSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotifikasiPage(notifications: notifications),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: brandSecondary.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: brandDark.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: brandLight,
              child: Icon(Icons.notifications_none_rounded, color: brandPrimary, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: brandDark,
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildKegiatanMendatangCard(Map<String, dynamic> event) {
    DateTime date = DateTime.parse(event['event_date']);
    String dayStr = DateFormat('dd').format(date);
    String monthStr = DateFormat('MMM').format(date).toUpperCase();
    String timeStr = '${event['start_time'].substring(0, 5)} - ${event['end_time'] != null ? event['end_time'].substring(0, 5) : 'Selesai'}';

    return GestureDetector(
      onTap: () => _showKegiatanDetail(event),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        color: brandDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              children: [
                Text(
                  dayStr,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  monthStr,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined,
                        size: 13, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7), size: 13),
          ),
        ],
      ),
    ));
  }

  void _showKegiatanDetail(Map<String, dynamic> event) {
    DateTime date = DateTime.parse(event['event_date']);
    String formattedDate = DateFormat('dd MMM yyyy').format(date);
    String timeStr = '${event['start_time'].substring(0, 5)} - ${event['end_time'] != null ? event['end_time'].substring(0, 5) : 'Selesai'}';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: brandSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: brandDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal', formattedDate),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.access_time_outlined, 'Waktu', timeStr),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.location_on_outlined, 'Lokasi', event['location'] ?? '-'),
                const SizedBox(height: 32),
                if (event['notes'] != null && event['notes'].isNotEmpty) ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailNotulensiPage(
                            title: event['title'],
                            content: event['notes'][0]['content'] ?? '',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandLight,
                      foregroundColor: brandPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: brandPrimary, width: 1.5),
                      ),
                    ),
                    child: const Text(
                      'Lihat Notulensi',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: brandLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: brandPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12,
                  color: brandSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: brandDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiSingkat(Map<String, dynamic> stats, List recentAtts) {
    double pctValue = (stats['percentage'] ?? 0) / 100.0;

    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tingkat Kehadiran',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: brandSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFF059669).withOpacity(0.2)),
                ),
                child: Text(
                  '${stats['percentage']}%',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pctValue,
              minHeight: 5,
              backgroundColor: brandSecondary.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: brandSecondary.withOpacity(0.1)),
          const SizedBox(height: 14),

          if (recentAtts.isEmpty)
            const Text(
              'Belum ada data absensi',
              style: TextStyle(color: brandSecondary, fontSize: 13),
            )
          else
            ...recentAtts.map((att) {
              Color stColor;
              if (att['status'] == 'Hadir') stColor = const Color(0xFF059669);
              else if (att['status'] == 'Izin') stColor = const Color(0xFFD97706);
              else stColor = const Color(0xFFDC2626);

              DateTime date = DateTime.parse(att['event_date']);
              String formattedDate = DateFormat('dd MMM yyyy').format(date);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAbsensiItem(
                  status: att['status'],
                  kegiatan: att['event_title'],
                  tanggal: formattedDate,
                  color: stColor,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildAbsensiItem({
    required String status,
    required String kegiatan,
    required String tanggal,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kegiatan,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: brandDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tanggal,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 11,
                  color: brandSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPengumumanList(List notifications) {
    return Column(
      children: notifications.map((notif) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildPengumumanItem(
            judul: notif['title'] ?? 'Pengumuman',
            deskripsi: notif['message'] ?? '',
            tanggal: 'Baru',
            isBaru: true,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPengumumanItem({
    required String judul,
    required String deskripsi,
    required String tanggal,
    required bool isBaru,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBaru
              ? brandPrimary.withOpacity(0.2)
              : brandSecondary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isBaru
                      ? brandPrimary.withOpacity(0.08)
                      : brandSecondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  isBaru ? Icons.campaign_outlined : Icons.notifications_none,
                  size: 15,
                  color: isBaru ? brandPrimary : brandSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: brandDark,
                            ),
                          ),
                        ),
                        if (isBaru) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Baru',
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deskripsi,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        color: brandSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tanggal,
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 11,
                        color: brandSecondary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8896B3).withOpacity(0.06)
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