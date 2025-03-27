// ignore: file_names
import 'package:flutter/material.dart';
import 'package:rodocodo_game/opsiLevel.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ukuranLayar = MediaQuery.of(context).size;
    final isSmallScreen = ukuranLayar.width >= 806;

    debugPrint("Screen Width: $ukuranLayar, isTablet: $isSmallScreen");

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
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
                      MaterialPageRoute(builder: (context) => OpsiLevel()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 45 : 25,
                        vertical: isSmallScreen ? 20 : 15),
                    textStyle: TextStyle(fontSize: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Color(0xFF36D206),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.black, width: 4),
                    elevation: 6,
                  ),
                  child: Text(
                    "MULAI",
                    style: GoogleFonts.carterOne(
                      fontSize: isSmallScreen ? 24 : 18,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(3, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OpsiLevel()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 45 : 25,
                        vertical: isSmallScreen ? 20 : 15),
                    textStyle: TextStyle(fontSize: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.black, width: 4),
                    elevation: 3,
                  ),
                  child: Text(
                    "Keluar",
                    style: GoogleFonts.carterOne(
                      fontSize: isSmallScreen ? 24 : 18,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5), // Shadow color
                          offset: Offset(3, 3), // Shadow position (X, Y)
                          blurRadius: 5, // How much to blur the shadow
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}
