import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/api_service.dart';

class NotifikasiPage extends StatefulWidget {
  final List<dynamic> notifications;

  const NotifikasiPage({super.key, required this.notifications});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notifications;
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    if (_notifications.isEmpty) {
      setState(() => _isLoading = true);
    }
    final result = await ApiService.getNotifications();
    if (result['success']) {
      setState(() {
        _notifications = result['data']['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
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
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        color: brandPrimary,
        child: _isLoading && _notifications.isEmpty
            ? const Center(child: CircularProgressIndicator(color: brandPrimary))
            : _notifications.isEmpty
                ? Stack(
                    children: [
                      ListView(), // Dibutuhkan agar RefreshIndicator bekerja saat kosong
                      const Center(
                        child: Text(
                          'Belum ada notifikasi.',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            color: brandSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final judul = notif['title'] ?? 'Notifikasi';
                      final deskripsi = notif['message'] ?? '';
                final isBaru = true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isBaru
                          ? brandPrimary.withOpacity(0.2)
                          : brandSecondary.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: brandDark.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isBaru
                              ? brandPrimary.withOpacity(0.08)
                              : brandSecondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isBaru ? Icons.notifications_active : Icons.notifications_none,
                          size: 20,
                          color: isBaru ? brandPrimary : brandSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: brandDark,
                                    ),
                                  ),
                                ),
                                if (isBaru) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
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
                            if (deskripsi.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                deskripsi,
                                style: const TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 13,
                                  color: brandSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Baru saja',
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 11,
                                color: brandSecondary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
