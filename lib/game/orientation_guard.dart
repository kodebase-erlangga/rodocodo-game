import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:html' as html;

/// OrientationGuard: Widget yang mengecek orientasi dan fullscreen.
/// Game hanya dapat dimainkan dalam keadaan fullscreen dan landscape.
class OrientationGuard extends StatefulWidget {
  final Widget child;
  const OrientationGuard({required this.child, super.key});

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard>
    with SingleTickerProviderStateMixin {
  static bool hasUnlockedFullScreenGlobal = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward(); // Jalankan animasi fade saat build pertama

    if (kIsWeb) {
      html.document.addEventListener('fullscreenchange', _onFullScreenChange);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (kIsWeb) {
      html.document
          .removeEventListener('fullscreenchange', _onFullScreenChange);
    }
    super.dispose();
  }

  void _onFullScreenChange(html.Event event) {
    if (html.document.fullscreenElement == null) {
      setState(() {
        hasUnlockedFullScreenGlobal = false;
      });
    }
  }

  void _enterFullScreen() {
    if (kIsWeb) {
      final docElm = html.document.documentElement;
      if (docElm != null) {
        docElm.requestFullscreen();
      }
    }
    setState(() {
      hasUnlockedFullScreenGlobal = true;
    });
  }

  Widget _buildOverlay({
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onTap,
    bool showButton = false,
    Color iconColor = Colors.yellow,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gunakan iconColor daripada Colors.white
                  Icon(icon, size: 80, color: iconColor),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  if (showButton) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _enterFullScreen,
                      icon: const Icon(Icons.fullscreen),
                      label: const Text("Masuk Full Screen"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool isLandscape = media.size.width > media.size.height;

    final bool isFullScreen = kIsWeb
        ? (html.document.fullscreenElement != null ||
            hasUnlockedFullScreenGlobal)
        : true;

    // ✅ Tampilkan konten utama jika fullscreen dan landscape
    if (isLandscape && isFullScreen) {
      return widget.child;
    }

    // ⚠️ Sudah fullscreen, tapi belum landscape
    if (!isLandscape && isFullScreen) {
      return _buildOverlay(
        icon: Icons.screen_rotation,
        title: "Putar Perangkat",
        message:
            "Harap putar perangkatmu ke posisi landscape untuk melanjutkan permainan.",
      );
    }

    // ⚠️ Sudah landscape, tapi belum fullscreen
    if (isLandscape && !isFullScreen) {
      return _buildOverlay(
        icon: Icons.fullscreen,
        title: "Aktifkan Fullscreen",
        message:
            "Sentuh layar atau tekan tombol di bawah untuk masuk ke mode full screen dan mulai permainan.",
        onTap: _enterFullScreen,
        showButton: true,
      );
    }

    // ❌ Belum landscape dan fullscreen
    return _buildOverlay(
      icon: Icons.warning,
      iconColor: Colors.yellow,
      title: "Aktifkan Fullscreen & Putar Perangkat",
      message:
          "Sentuh layar untuk masuk ke mode full screen dan putar perangkatmu ke posisi landscape.",
      onTap: _enterFullScreen,
      showButton: true,
    );
  }
}
