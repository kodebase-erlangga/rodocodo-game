import 'dart:html' as html;

class OrientationGuardWeb {
  static void requestFullScreen() {
    html.document.documentElement?.requestFullscreen();
  }

  static void addFullScreenListener(void Function() listener) {
    html.document.addEventListener('fullscreenchange', (_) => listener());
  }

  static void removeFullScreenListener(void Function() listener) {
    html.document.removeEventListener('fullscreenchange', (_) => listener());
  }

  static bool get isFullScreen =>
      html.document.fullscreenElement != null;
}
