import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  bool _isLoading = true;
  bool _isAttending = false;
  Map<String, dynamic>? _nextEvent;
  List<dynamic> _recentAttendances = [];
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    final result = await ApiService.getHomeData();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        final next = result['data']['next_event'];
        // Check if nextEvent is today
        if (next != null) {
          DateTime eventDate = DateTime.parse(next['event_date']);
          DateTime now = DateTime.now();
          if (eventDate.year == now.year && eventDate.month == now.month && eventDate.day == now.day) {
             _nextEvent = next;
          } else {
             _nextEvent = null; // not today
          }
        } else {
          _nextEvent = null;
        }

        _recentAttendances = result['data']['recent_attendances'] ?? [];
      } else {
        _errorMsg = result['message'] ?? 'Terjadi kesalahan';
      }
    });
  }

  Future<void> _handleAbsensi() async {
    if (_nextEvent == null) return;

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
        _nextEvent!['id'],
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (result['success']) {
        _showFeedbackDialog(true, result['message'], result['data']['distance']);
        // Refresh data
        _fetchData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Absensi',
          style: TextStyle(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: brandDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: brandPrimary))
          : _errorMsg.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMsg, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchData, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  color: brandPrimary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildActiveEventCard(),
                        const SizedBox(height: 48),
                        
                        // Main Action Button
                        Center(
                          child: _buildAbsenButton(),
                        ),
                        
                        const SizedBox(height: 48),
                        const Text(
                          'Riwayat Terbaru',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: brandDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildHistoryList(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildActiveEventCard() {
    if (_nextEvent == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandSecondary.withOpacity(0.12)),
        ),
        child: const Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: brandSecondary),
            SizedBox(height: 16),
            Text(
              'Tidak ada kegiatan hari ini',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: brandSecondary,
              ),
            ),
          ],
        ),
      );
    }

    String timeStr = '${_nextEvent!['start_time'].substring(0, 5)} - ${_nextEvent!['end_time'] != null ? _nextEvent!['end_time'].substring(0, 5) : 'Selesai'}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [brandPrimary, Color(0xFF5A75EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: brandPrimary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _nextEvent!['status'] == 'pending' ? const Color(0xFFFBBF24) :
                               _nextEvent!['status'] == 'ongoing' ? const Color(0xFF4ADE80) : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _nextEvent!['status'] == 'pending' ? 'Belum Mulai' :
                      _nextEvent!['status'] == 'ongoing' ? 'Sedang Berlangsung' : 'Selesai',
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
              const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _nextEvent!['title'],
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white.withOpacity(0.7), size: 14),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbsenButton() {
    bool hasEvent = _nextEvent != null;
    return GestureDetector(
      onTap: hasEvent && !_isAttending ? _handleAbsensi : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: hasEvent
                ? [brandPrimary, const Color(0xFF5A75EB)]
                : [brandSecondary.withOpacity(0.3), brandSecondary.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: hasEvent
              ? [
                  BoxShadow(
                    color: brandPrimary.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                    offset: const Offset(0, 10),
                  )
                ]
              : [],
        ),
        child: Center(
          child: _isAttending
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 64,
                      color: hasEvent ? Colors.white : brandSecondary.withOpacity(0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasEvent ? 'Absen\nSekarang' : 'Tidak Ada\nKegiatan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: hasEvent ? Colors.white : brandSecondary.withOpacity(0.6),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_recentAttendances.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Belum ada riwayat absensi.', style: TextStyle(color: brandSecondary)),
        ),
      );
    }

    return Column(
      children: _recentAttendances.map((att) {
        Color stColor;
        if (att['status'] == 'Hadir') stColor = const Color(0xFF059669);
        else if (att['status'] == 'Izin') stColor = const Color(0xFFD97706);
        else stColor = const Color(0xFFDC2626);

        DateTime date = DateTime.parse(att['event_date']);
        String formattedDate = DateFormat('dd MMM yyyy').format(date);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHistoryItem(
            status: att['status'],
            kegiatan: att['event_title'],
            tanggal: formattedDate,
            jam: '-', // backend didn't return attended_at in recent_attendances, can show '-' for now
            color: stColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItem({
    required String status,
    required String kegiatan,
    required String tanggal,
    required String jam,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandSecondary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: brandDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              status == 'Hadir' ? Icons.check_circle_outline : Icons.info_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kegiatan,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: brandDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: brandSecondary.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      tanggal,
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        color: brandSecondary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_outlined, size: 12, color: brandSecondary.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      jam,
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        color: brandSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
