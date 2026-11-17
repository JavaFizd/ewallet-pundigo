import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================================
/// NOTIFIKASI PUSH NATIVE DALAM FRAME SMARTPHONE (DYNAMIC BANNER NOTIFIKASI)
/// ============================================================================
/// Menggantikan SnackBar hijau eksternal yang melayang keluar:
/// - 100% Berada di dalam frame smartphone di bagian atas (di bawah status bar).
/// - Tampilan layaknya notifikasi push iOS Dynamic Island / Android Heads-up.
/// - Lengkap dengan logo PundiGo, judul, pesan transaksi, badge status, dan
///   animasi slide down yang mulus.
/// ============================================================================
class InAppNotification {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? subtitle,
    IconData icon = Icons.notifications_active_rounded,
    Color iconColor = const Color(0xFF00A887),
    Color iconBg = const Color(0xFFE6F8F5),
    String? badgeText,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    // Tutup notifikasi sebelumnya jika ada
    hide();

    final overlay = Overlay.of(context, rootOverlay: false);

    _currentEntry = OverlayEntry(
      builder: (ctx) => _InAppNotificationWidget(
        title: title,
        message: message,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        iconBg: iconBg,
        badgeText: badgeText,
        onTap: () {
          hide();
          if (onTap != null) onTap();
        },
        onDismiss: hide,
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer = Timer(duration, () {
      hide();
    });
  }

  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? badgeText;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.message,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.badgeText,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissWithAnimation() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                  _dismissWithAnimation();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ikon Notifikasi PundiGo Bulat
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.iconBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.iconColor.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),

                    // Teks Notifikasi (Judul & Pesan)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'PundiGo!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF00A887),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '• baru saja',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              if (widget.badgeText != null) ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F8F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.badgeText!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF007A63),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Tombol Tutup Kecil
                    InkWell(
                      onTap: _dismissWithAnimation,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade400),
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
}

