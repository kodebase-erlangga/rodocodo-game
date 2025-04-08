import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rodocodo_game/game/Level.dart';
import 'package:rodocodo_game/game/mainPage.dart';

class OpsiLevel extends StatelessWidget {
  const OpsiLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 806;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    debugPrint("Screen Width: $screenSize, isTablet: $isSmallScreen");

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenuScreen(),
          ),
        );
        return false; // mencegah pop default
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
                    width: isSmallScreen ? 40 : 30,
                    height: isSmallScreen ? 40 : 30,
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
    );
  }

  Widget _buildLevelCard(String title, String imagePath, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 806;

    double cardWidth = isSmallScreen ? screenSize.width * 0.23 : 300;
    double cardHeight = cardWidth * 1.3;

    final titleFontSize = isSmallScreen ? 16.0 : 40.0;
    final lockIconSize = isSmallScreen ? 35.0 : 90.0;
    final bool isLocked = title != "Tutorial";

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("Maaf!"),
              content: Text("Permainan sedang dalam pengembangan!"),
              actions: [
                TextButton(
                  child: Text("Kembali"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
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
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/gembok.svg',
                      width: lockIconSize,
                      height: lockIconSize,
                      // ignore: deprecated_member_use
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: isSmallScreen ? 8.0 : 15.0,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.carterOne(
                    fontSize: titleFontSize,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
