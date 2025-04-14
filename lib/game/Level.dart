// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rodocodo_game/game/game_widget.dart';
import 'package:rodocodo_game/main.dart';
import 'package:rodocodo_game/game/orientation_guard.dart' as og;
import 'package:rodocodo_game/game/opsiLevel.dart' as ol;
import 'package:shared_preferences/shared_preferences.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LevelState createState() => _LevelState();
}

class _LevelState extends State<Level> with RouteAware {
  late Future<Map<int, int>> _starsFuture;

  @override
  void initState() {
    super.initState();
    _starsFuture = _loadStars();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() => _starsFuture = _loadStars());
  }

  Future<void> _updateStars(int level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level$level', stars);
    setState(() => _starsFuture = _loadStars());
  }

  Future<Map<int, int>> _loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    return {for (int i = 1; i <= 6; i++) i: prefs.getInt('level$i') ?? 0};
  }

  String _getStarImage(int stars, bool isUnlocked) {
    if (!isUnlocked) return 'assets/images/nonaktif.png';
    switch (stars) {
      case 0:
        return 'assets/images/bintangnol.png';
      case 1:
        return 'assets/images/bintangsatu.png';
      case 2:
        return 'assets/images/bintangdua.png';
      case 3:
        return 'assets/images/bintangtiga.png';
      default:
        return 'assets/images/nonaktif.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width <= 806;

    return og.OrientationGuard(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ol.OpsiLevel(),
            ),
          );
          return false;
        },
        child: Stack(
          children: [
            SizedBox.expand(
              child: Container(
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
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.05,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ol.OpsiLevel(),
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
              child: FutureBuilder<Map<int, int>>(
                future: _starsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final stars = snapshot.data!;
                  // Tentukan ukuran layar dan mode tablet
                  final screenSize = MediaQuery.of(context).size;
                  final isTablet = screenSize.width >= 1024;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLevelRow(1, 3, stars, isTablet, screenSize.width,
                          screenSize.height),
                      SizedBox(height: isTablet ? 30 : 10),
                      _buildLevelRow(4, 6, stars, isTablet, screenSize.width,
                          screenSize.height),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(int start, int end, Map<int, int> stars, bool isTablet,
      double screenWidth, double screenHeight) {
    double itemSize = isTablet ? screenWidth * 0.10 : screenWidth * 0.17;
    double fontSize = isTablet ? 50 : 35;
    double padding = isTablet ? 40 : 10;
    double spacing = isTablet ? 20 : 8;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start + 1, (index) {
        final level = start + index;
        final isUnlocked = level == 1 || (level > 1 && stars[level - 1]! > 0);
        return _buildLevelItem(
            level, stars, isUnlocked, itemSize, fontSize, padding, isTablet);
      }).expand((widget) => [widget, SizedBox(width: spacing)]).toList()
        ..removeLast(),
    );
  }

  Widget _buildLevelItem(int level, Map<int, int> stars, bool isUnlocked,
      double itemSize, double fontSize, double padding, bool isTablet) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    initialLevel: level,
                    onLevelCompleted: (stars) => _updateStars(level, stars),
                  ),
                ),
              );
            }
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: SizedBox(
              width: itemSize,
              height: itemSize,
              child: Image.asset(
                _getStarImage(stars[level]!, isUnlocked),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, 25),
            child: Text(
              '$level',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
