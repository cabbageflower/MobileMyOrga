import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../kegiatan/detail_absensi_page.dart';
import '../notifikasi/notifikasi_page.dart';

class HomePengurusPage extends StatefulWidget {
  const HomePengurusPage({super.key});

  @override
  State<HomePengurusPage> createState() => _HomePengurusPageState();
}

class _HomePengurusPageState extends State<HomePengurusPage> {
  bool _isLoading = true;
  bool _isAttending = false;
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
    final stats = _data!['stats'];
    final nextEvent = _data!['next_event'];
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
                  _buildHeader(user['full_name'], notifications),
                  const SizedBox(height: 28),
                  _buildStatistikGrid(
                    members: stats['total_members'].toString(),
                    divisions: stats['total_divisions'].toString(),
                    events: stats['total_events'].toString(),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Kegiatan Terdekat'),
                  const SizedBox(height: 12),
                  nextEvent != null
                      ? _buildKegiatanTerdekatCard(nextEvent)
                      : _buildEmptyState('Tidak ada kegiatan terdekat.'),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Rekrutmen Aktif'),
                  const SizedBox(height: 12),
                  _buildRekrutmenCard(stats['pending_apps']),
                  const SizedBox(height: 28),
                  _buildSectionTitle('Notifikasi Terbaru'),
                  const SizedBox(height: 12),
                  notifications.isNotEmpty
                      ? _buildNotifikasiList(notifications)
                      : _buildEmptyState('Belum ada notifikasi.'),
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

  Widget _buildHeader(String name, List<dynamic> notifications) {
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
                color: brandPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: brandPrimary.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 13, color: brandPrimary),
                  SizedBox(width: 4),
                  Text(
                    'Pengurus',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: brandPrimary,
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

  Widget _buildStatistikGrid({required String members, required String divisions, required String events}) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          title: 'Anggota',
          value: members,
          icon: Icons.groups_outlined,
          color: brandPrimary,
          bgColor: brandPrimary.withOpacity(0.08),
        )),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(
          title: 'Divisi',
          value: divisions,
          icon: Icons.account_tree_outlined,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFF059669).withOpacity(0.08),
        )),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(
          title: 'Kegiatan',
          value: events,
          icon: Icons.event_outlined,
          color: const Color(0xFFEA580C),
          bgColor: const Color(0xFFEA580C).withOpacity(0.08),
        )),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: brandDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: brandSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAbsensi(Map<String, dynamic> event) async {
    setState(() {
      _isAttending = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showFeedbackDialog(false, 'Layanan lokasi (GPS) tidak aktif. Silakan aktifkan terlebih dahulu.', null);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showFeedbackDialog(false, 'Izin lokasi ditolak. Aplikasi butuh izin lokasi untuk absensi.', null);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showFeedbackDialog(false, 'Izin lokasi ditolak permanen. Silakan ubah di pengaturan HP.', null);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await ApiService.submitAttendance(
        event['id'],
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (result['success']) {
        _showFeedbackDialog(true, result['message'], result['data']['distance']);
      } else {
        _showFeedbackDialog(false, result['message'], result['data']?['distance']);
      }
    } catch (e) {
      if (!mounted) return;
      _showFeedbackDialog(false, 'Gagal mendapatkan lokasi atau menghubungi server.', null);
    } finally {
      if (mounted) {
        setState(() {
          _isAttending = false;
        });
      }
    }
  }

  void _showFeedbackDialog(bool isSuccess, String message, dynamic distance) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFF059669).withOpacity(0.1) : const Color(0xFFDC2626).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                    color: isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? 'Absensi Berhasil!' : 'Absensi Gagal',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: brandDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 14,
                    color: brandSecondary,
                    height: 1.5,
                  ),
                ),
                if (distance != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Jarak tercatat: ${distance}m',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: brandDark,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccess ? const Color(0xFF059669) : brandDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKegiatanTerdekatCard(Map<String, dynamic> event) {
    DateTime date = DateTime.parse(event['event_date']);
    String formattedDate = DateFormat('dd MMM yyyy').format(date);
    String timeStr = '${event['start_time'].substring(0, 5)} - ${event['end_time'] != null ? event['end_time'].substring(0, 5) : 'Selesai'}';

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.4), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event['title'],
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          _buildEventMeta(Icons.access_time_outlined, timeStr),
          const SizedBox(height: 6),
          _buildEventMeta(Icons.location_on_outlined, event['location'] ?? '-'),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          Row(
            children: _isAttending
                ? const [Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))]
                : [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAbsensi(event),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Absen',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailAbsensiPage(
                                eventId: event['id'],
                                title: event['title'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: brandDark,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Lihat Detail',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Figtree',
            color: Colors.white.withOpacity(0.75),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildRekrutmenCard(int pendingApps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add_alt_1_outlined,
              color: Color(0xFFD97706),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingApps Pendaftar Menunggu',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: brandDark,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Proses pendaftaran melalui Dashboard Web',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    color: brandSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifikasiList(List notifications) {
    return Column(
      children: notifications.map((notif) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildNotifItem(
            icon: Icons.notifications_active_outlined,
            iconColor: brandPrimary,
            iconBg: brandPrimary,
            title: notif['title'] ?? 'Notifikasi',
            time: 'Baru', // Idealnya pakai library timeago
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotifItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandSecondary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: brandDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 11,
              color: brandSecondary,
            ),
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