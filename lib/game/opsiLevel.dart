// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:rodocodo_game/game/Level.dart';
import 'package:rodocodo_game/game/mainPage.dart';
import 'package:rodocodo_game/game/orientation_guard.dart' as og;

/// Untuk memastikan orientasi landscape di web
class OrientationGuard extends StatefulWidget {
  final Widget child;
  const OrientationGuard({required this.child, super.key});

  @override
  State<OrientationGuard> createState() => _OrientationGuardState();
}

class _OrientationGuardState extends State<OrientationGuard> {
  static bool hasUnlockedFullScreenGlobal = false;

  @override
  Widget build(BuildContext context) {
    return og.OrientationGuard(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenuScreen(),
            ),
          );
          return false;
        },
        child: widget.child, // Tambahkan baris ini untuk menyelesaikan error!
      ),
    );
  }
}

class OpsiLevel extends StatelessWidget {
  const OpsiLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 806;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return OrientationGuard(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainMenuScreen()),
          );
          return false;
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_kota.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.05,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenuScreen(),
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/back.svg',
                      width: isSmallScreen ? 40 : 60,
                      height: isSmallScreen ? 40 : 60,
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                isSmallScreen ? screenSize.width * 0.9 : 1200,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: isSmallScreen ? 10 : 20,
                            runSpacing: isSmallScreen ? 15 : 20,
                            children: [
                              _buildLevelCard("Tutorial",
                                  "assets/images/tutorial.png", context),
                              _buildLevelCard("Fast Track",
                                  "assets/images/panik.jpg", context),
                              _buildLevelCard("Get Money",
                                  "assets/images/getMoney.jpg", context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(String title, String imagePath, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 1024;
    double cardWidth = isSmallScreen ? screenSize.width * 0.23 : 300;
    double cardHeight = cardWidth * 1.3;
    final titleFontSize = isSmallScreen ? 16.0 : 40.0;
    final lockIconSize = isSmallScreen ? 35.0 : 90.0;
    final bool isLocked = title != "Tutorial" && title != "Fast Track";

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: isSmallScreen ? 235 : 335,
                height: isSmallScreen ? 221 : 321,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF0CEAB)],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: const Color(0xFF4E2400),
                    width: isSmallScreen ? 2 : 4,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 7 : 14,
                  isSmallScreen ? 11 : 25,
                  isSmallScreen ? 7 : 14,
                  isSmallScreen ? 11 : 25,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/building.png',
                          height: isSmallScreen ? 97 : 137,
                          width: isSmallScreen ? 160 : 210,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 5 : 19),
                    Container(
                      width: isSmallScreen ? 200 : 232,
                      height: isSmallScreen ? 37 : 54,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 7 : 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(isSmallScreen ? 5 : 10),
                        border: Border.all(width: 2, color: Colors.black12),
                      ),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Days One',
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 8 : 12,
                              height: isSmallScreen ? 10 / 12 : 20 / 12,
                              color: const Color(0xFF6A6464),
                            ),
                            children: const [
                              TextSpan(
                                text: 'Maaf fitur sedang dalam pengembangan',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 5 : 19),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE7B0A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 82 : 90,
                          vertical: isSmallScreen ? 0.1 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isSmallScreen ? 30 : 30),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 78, 36, 0),
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Kembali',
                        style: TextStyle(
                          fontFamily: 'Carter One',
                          fontSize: isSmallScreen ? 8 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Level()),
          );
        }
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.all(isSmallScreen ? 5.0 : 10.0),
        child: Stack(
          children: [
            Container(
              decoration: !isLocked
                  ? BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (isLocked)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/gembok.svg',
                      width: lockIconSize,
                      height: lockIconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
