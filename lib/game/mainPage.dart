import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rodocodo_game/widgets/orientation_guard.dart' as og;
import 'package:rodocodo_game/game/opsiLevel.dart' as ol;

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return og.OrientationGuard(
      child: const _MainMenuContent(),
    );
  }
}

class _MainMenuContent extends StatelessWidget {
  const _MainMenuContent();

  @override
  Widget build(BuildContext context) {
    final ukuranLayar = MediaQuery.of(context).size;
    final isSmallScreen = ukuranLayar.width >= 1024;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ol.OpsiLevel()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 45 : 25,
                      vertical: isSmallScreen ? 20 : 15,
                    ),
                    textStyle: const TextStyle(fontSize: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xFF36D206),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black, width: 4),
                    elevation: 6,
                  ),
                  child: Text(
                    "MULAI",
                    style: GoogleFonts.carterOne(
                      fontSize: isSmallScreen ? 24 : 18,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(3, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
