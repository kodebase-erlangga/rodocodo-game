import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'orientation_guard_web.dart'
    if (dart.library.html) 'orientation_guard_web_impl.dart';

class OrientationGuard extends StatefulWidget {
  final Widget child;
  const OrientationGuard({super.key, required this.child});

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    if (kIsWeb) {
      OrientationGuardWeb.addFullScreenListener(_onFullScreenChange);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (kIsWeb) {
      OrientationGuardWeb.removeFullScreenListener(_onFullScreenChange);
    }
    super.dispose();
  }

  void _onFullScreenChange() {
    setState(() {});
  }

  void _enterFullScreen() {
    if (kIsWeb) {
      OrientationGuardWeb.requestFullScreen();
    }
  }

  bool get _isFullScreen {
    if (!kIsWeb) return true;
    return OrientationGuardWeb.isFullScreen;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bool isLandscape = media.orientation == Orientation.landscape;

    if (isLandscape && _isFullScreen) {
      return widget.child;
    }

    IconData icon;
    String title;
    String message;
    VoidCallback? onTap;
    bool showButton = false;

    if (!isLandscape && !_isFullScreen) {
      icon = Icons.warning;
      title = "Aktifkan Fullscreen & Putar Perangkat";
      message =
          "Sentuh layar untuk masuk ke mode full screen dan putar perangkatmu ke posisi landscape.";
      onTap = _enterFullScreen;
      showButton = true;
    } else if (!isLandscape) {
      icon = Icons.screen_rotation;
      title = "Putar Perangkat";
      message =
          "Harap putar perangkatmu ke posisi landscape untuk melanjutkan permainan.";
    } else {
      icon = Icons.fullscreen;
      title = "Aktifkan Fullscreen";
      message =
          "Sentuh layar atau tekan tombol di bawah untuk masuk ke mode full screen dan mulai permainan.";
      onTap = _enterFullScreen;
      showButton = true;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 80, color: Colors.yellow),
                  const SizedBox(height: 24),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 16),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, color: Colors.white70)),
                  if (showButton)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.fullscreen),
                        label: const Text("Masuk Full Screen"),
                        onPressed: _enterFullScreen,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
