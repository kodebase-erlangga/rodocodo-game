import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rodocodo_game/game/mainPage.dart';
import 'package:rodocodo_game/levelSelection.dart';

class OpsiLevel extends StatelessWidget {
  const OpsiLevel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_kota.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Atur opasitas sesuai kebutuhan
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LevelSelectionScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: 350,
                            height: 400,
                            child: Image.asset(
                              "assets/images/tutorial.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Center(
                              child: Text(
                                "Tutorial",
                                style: GoogleFonts.carterOne(
                                  fontSize: 40,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.black.withOpacity(1.0),
                                      offset: Offset(3, 3),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LevelSelectionScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: 350,
                            height: 400,
                            child: Image.asset(
                              "assets/images/panik.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Center(
                              child: Text(
                                "Fast Track",
                                style: GoogleFonts.carterOne(
                                  fontSize: 40,
                                  color: Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LevelSelectionScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: 350,
                            height: 400,
                            child: Image.asset(
                              "assets/images/getMoney.jpg",
                              fit: BoxFit.cover, // Membuat gambar memenuhi Card
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Center(
                              child: Text(
                                "Get Money",
                                style: GoogleFonts.carterOne(
                                  fontSize: 40,
                                  color: Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenuScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 45, vertical: 20),
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
                      "Menu Utama",
                      style: GoogleFonts.carterOne(
                        fontSize: 24,
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
