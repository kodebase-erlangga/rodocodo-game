// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:rodocodo_game/game/Level.dart';
import 'package:rodocodo_game/game/game_widget.dart';
import 'package:rodocodo_game/game/mainPage.dart';

enum TileType {
  start,
  finish,
  normal,
  normal_landscape,
  belok_noltiga,
  belok_sembilannol,
  belok_enamsembilan,
  belok_tigaenam
}

class FloorTile extends SpriteComponent with HasGameRef<MyGame> {
  final String id;
  TileType _type;
  TileType get type => _type;
  set type(TileType newType) {
    if (newType != _type) {
      _type = newType;
      _updateSprite();
    }
  }

  FloorTile({
    required this.id,
    required TileType type,
    required Vector2 position,
  })  : _type = type,
        super(position: position, size: Vector2.all(150));

  @override
  Future<void> onLoad() async {
    try {
      await super.onLoad();
    } catch (e) {
      print('Error loading : $e');
    }

    updateSize(gameRef.size.x);

    try {
      await _updateSprite();
    } catch (e) {
      print('Error loading sprite: $e');
    }
    // await super.onLoad();
    // updateSize(gameRef.size.x);
    // await _updateSprite();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    updateSize(size.x);
  }

  void updateSize(double screenWidth) {
    double tileSize = screenWidth >= 806 ? 150 : 75;
    size = Vector2.all(tileSize);
  }

  Future<void> _updateSprite() async {
    switch (_type) {
      case TileType.start:
        sprite = await gameRef.loadSprite('start.png');
        break;
      case TileType.normal:
        sprite = await gameRef.loadSprite('lantai.png');
        break;
      case TileType.belok_noltiga:
        sprite = await gameRef.loadSprite('belok_noltiga.png');
        break;
      case TileType.belok_tigaenam:
        sprite = await gameRef.loadSprite('belok_tigaenam.png');
        break;
      case TileType.belok_enamsembilan:
        sprite = await gameRef.loadSprite('belok_enamsembilan.png');
        break;
      case TileType.belok_sembilannol:
        sprite = await gameRef.loadSprite('belok_sembilannol.png');
        break;
      case TileType.normal_landscape:
        sprite = await gameRef.loadSprite('lantai_landscape.png');
        break;
      case TileType.finish:
        sprite = await gameRef.loadSprite('finish.png');
        break;
    }
  }
}

class MyGame extends FlameGame {
  late Character _character;
  bool isExecuting = false;
  bool _isExecutingCommands = false;
  List<List<TileType?>> tileGrid = [];
  late double startX;
  late double startY;
  late Vector2 startTileCenter;
  bool isGameOver = false;
  Function()? naikLevel;
  int Function()? getMoveCount;
  bool isTargetReached = false;
  int currentLevel = 1;
  Function(int)? onLevelCompleted;
  AudioPlayer? _startEnginePlayer;
  AudioPlayer? _gasPlayer;
  bool _isFirstCommand = true;
  Function()? clearCommands;
  double tileSize = 150.0;

  MyGame({int initialLevel = 1, this.onLevelCompleted})
      : currentLevel = initialLevel;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onRemove() async {
    _gasPlayer?.stop();
    _startEnginePlayer?.stop();
    FlameAudio.bgm.stop();
    FlameAudio.audioCache.clearAll();
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    // _startEnginePlayer = await FlameAudio.play('startEngine.mp3');

    updateTileSize(size.x);

    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    updateTileSize(size.x);
  }

  void updateTileSize(double screenWidth) {
    tileSize = screenWidth >= 806 ? 150.0 : 75.0;
  }

  int getOptimalSteps() {
    switch (currentLevel) {
      case 1:
        return 2;
      case 2:
        return 6;
      case 3:
        return 6;
      case 4:
        return 8;
      case 5:
        return 9;
      case 6:
        return 14;
      default:
        return 0;
    }
  }

  int calculateStars() {
    int optimal = getOptimalSteps();
    int currentMoveCount = getMoveCount?.call() ?? 0;
    int difference = (currentMoveCount - optimal).abs();

    if (difference == 0) return 3;
    if (difference <= 2) return 2;
    if (difference <= 5) return 1;
    return 1;
  }

  @override
  void onAttach() {
    overlays.addEntry('congrats', (context, game) {
      final myGame = game as MyGame;
      final stars = myGame.calculateStars();
      final moveCount = myGame.getMoveCount?.call() ?? 0;

      final screenSize = MediaQuery.of(context).size;
      final isSmallScreen = screenSize.width <= 806;

      return Stack(
        children: [
          Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: isSmallScreen ? 100 : 150,
                height: isSmallScreen ? 223 : 470,
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
                          'assets/images/pita.png',
                          height: isSmallScreen ? 50 : 80,
                          width: isSmallScreen ? 250 : 300,
                          fit: BoxFit.cover,
                        ),
                        Transform.translate(
                          offset: Offset(0, isSmallScreen ? -10 : -15),
                          child: Text(
                            'B E R H A S I L',
                            style: TextStyle(
                              fontFamily: 'Days One',
                              fontWeight: isSmallScreen
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: isSmallScreen ? 15 : 25,
                              color: Colors.white,
                              height: isSmallScreen ? 0.5 : 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        double offsetY;
                        if (index == 1) {
                          offsetY = isSmallScreen ? -10 : -20;
                        } else {
                          offsetY = isSmallScreen ? -2.5 : -5;
                        }
                        return Transform.translate(
                          offset: Offset(0, offsetY),
                          child: Transform.rotate(
                            angle: -25 * pi / 180,
                            child: Container(
                              width: isSmallScreen ? 60 : 70,
                              height: isSmallScreen ? 50 : 65,
                              margin: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 2.5 : 5,
                              ),
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: isSmallScreen ? 53 + 6 : 75 + 6,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: index < stars
                                        ? const Color(0xFFFFE30E)
                                        : Colors.grey[300],
                                    size: isSmallScreen ? 50 : 75,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 18),
                    Container(
                      width: isSmallScreen ? 200 : 232,
                      height: isSmallScreen ? 37 : 56,
                      padding: EdgeInsets.only(
                        top: isSmallScreen ? 7 : 5,
                        bottom: isSmallScreen ? 7 : 5,
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
                            children: [
                              const TextSpan(
                                  text: 'kamu berhasil menyelesaikan dengan '),
                              TextSpan(
                                text: '$moveCount',
                                style:
                                    const TextStyle(color: Color(0xFFFE7B0A)),
                              ),
                              const TextSpan(text: ' langkah'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 5 : 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFE7B0A),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 20,
                              vertical: isSmallScreen ? 3 : 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  isSmallScreen ? 10 : 10),
                              side: const BorderSide(
                                color: Color(0xFF4E2400),
                                width: 2,
                              ),
                            ),
                          ),
                          onPressed: () {
                            myGame.overlays.remove('congrats');
                            myGame.resetGame();
                            if (myGame.naikLevel != null) myGame.naikLevel!();
                          },
                          child: Text(
                            'Ulangi',
                            style: TextStyle(
                              fontFamily: 'Carter One',
                              fontSize: isSmallScreen ? 8 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 50 : 22),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFE7B0A),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 20,
                              vertical: isSmallScreen ? 3 : 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(isSmallScreen ? 8 : 10),
                              side: const BorderSide(
                                color: Color(0xFF4E2400),
                                width: 2,
                              ),
                            ),
                          ),
                          onPressed: () {
                            disableButtons = false;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Level(),
                              ),
                            );
                          },
                          child: Text(
                            'Selanjutnya',
                            style: TextStyle(
                              fontFamily: 'Carter One',
                              fontSize: isSmallScreen ? 8 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });

    overlays.addEntry('gameOver', (context, game) {
      final screenSize = MediaQuery.of(context).size;
      final isSmallScreen = screenSize.width <= 806;

      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: isSmallScreen ? 100 : 150,
            height: isSmallScreen ? 223 : 400,
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
                isSmallScreen ? 11 : 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pita_gagal.png',
                      height: isSmallScreen ? 50 : 80,
                      width: isSmallScreen ? 250 : 300,
                      fit: BoxFit.cover,
                    ),
                    Transform.translate(
                      offset: Offset(0, isSmallScreen ? -10 : -15),
                      child: Text(
                        'G A G A L',
                        style: TextStyle(
                          fontFamily: 'Days One',
                          fontWeight:
                              isSmallScreen ? FontWeight.w800 : FontWeight.w600,
                          fontSize: isSmallScreen ? 15 : 25,
                          color: Colors.white,
                          height: isSmallScreen ? 0.5 : 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 2 : 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    double offsetY;
                    if (index == 1) {
                      offsetY = isSmallScreen ? -10 : -20;
                    } else {
                      offsetY = isSmallScreen ? -2.5 : -5;
                    }
                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: Transform.rotate(
                        angle: -25 * pi / 180,
                        child: Container(
                          width: isSmallScreen ? 60 : 70,
                          height: isSmallScreen ? 50 : 65,
                          margin: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 2.5 : 5),
                          child: Stack(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: isSmallScreen ? 53 + 6 : 75 + 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: isSmallScreen ? 2 : 18),
                Container(
                  width: isSmallScreen ? 200 : 232,
                  height: isSmallScreen ? 37 : 56,
                  padding: EdgeInsets.only(
                      top: isSmallScreen ? 7 : 5,
                      bottom: isSmallScreen ? 7 : 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 5 : 10),
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
                        children: [
                          const TextSpan(
                              text:
                                  'Yah .. kamu keluar dari jalur! Ayo coba lagi'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 5 : 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE7B0A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 35 : 80,
                            vertical: isSmallScreen ? 3 : 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isSmallScreen ? 10 : 10),
                          side: const BorderSide(
                            color: Color(0xFF4E2400),
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () {
                        overlays.remove('gameOver');
                        resetGame();
                        if (naikLevel != null) naikLevel!();
                      },
                      child: Text(
                        'Ulangi',
                        style: TextStyle(
                          fontFamily: 'Carter One',
                          fontSize: isSmallScreen ? 8 : 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });

    overlays.addEntry('gameFinished', (context, game) {
      final myGame = game as MyGame;
      final stars = myGame.calculateStars();

      final screenSize = MediaQuery.of(context).size;
      final isSmallScreen = screenSize.width <= 806;

      return Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: isSmallScreen ? 100 : 150,
            height: isSmallScreen ? 223 : 400,
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
                isSmallScreen ? 11 : 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pita.png',
                      height: isSmallScreen ? 50 : 80,
                      width: isSmallScreen ? 250 : 300,
                      fit: BoxFit.cover,
                    ),
                    Transform.translate(
                      offset: Offset(0, isSmallScreen ? -10 : -15),
                      child: Text(
                        'LUAR BIASA 🏆',
                        style: TextStyle(
                          fontFamily: 'Days One',
                          fontWeight:
                              isSmallScreen ? FontWeight.w800 : FontWeight.w600,
                          fontSize: isSmallScreen ? 15 : 25,
                          color: Colors.white,
                          height: isSmallScreen ? 0.5 : 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 2 : 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    double offsetY;
                    if (index == 1) {
                      offsetY = isSmallScreen ? -10 : -20;
                    } else {
                      offsetY = isSmallScreen ? -2.5 : -5;
                    }
                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: Transform.rotate(
                        angle: -25 * pi / 180,
                        child: Container(
                          width: isSmallScreen ? 60 : 70,
                          height: isSmallScreen ? 50 : 65,
                          margin: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 2.5 : 5),
                          child: Stack(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: isSmallScreen ? 53 + 6 : 75 + 6,
                              ),
                              Icon(
                                Icons.star,
                                color: index < stars
                                    ? const Color(0xFFFFE30E)
                                    : Colors.grey[300],
                                size: isSmallScreen ? 50 : 75,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: isSmallScreen ? 2 : 18),
                Container(
                  width: isSmallScreen ? 200 : 232,
                  height: isSmallScreen ? 37 : 56,
                  padding: EdgeInsets.only(
                      top: isSmallScreen ? 7 : 5,
                      bottom: isSmallScreen ? 7 : 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 5 : 10),
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
                        children: [
                          const TextSpan(
                              text: 'Anda telah menamatkan semua level!'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 5 : 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFE7B0A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 20,
                            vertical: isSmallScreen ? 3 : 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(isSmallScreen ? 10 : 10),
                          side: const BorderSide(
                            color: Color(0xFF4E2400),
                            width: 2,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainMenuScreen()),
                        );
                      },
                      child: Text(
                        'Beranda',
                        style: TextStyle(
                          fontFamily: 'Carter One',
                          fontSize: isSmallScreen ? 8 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
    super.onAttach();
  }

  void _generateFloorTiles() {
    removeWhere((component) => component is FloorTile);

    if (currentLevel == 1) {
      const rows = 1;
      const columns = 3;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - tileSize) / 2;

      tileGrid = List.generate(
          rows, (row) => List.filled(columns, TileType.normal_landscape));

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          final id = 'row${row}_col$col';
          final position = Vector2(
            startX + col * tileSize,
            startY + row * tileSize,
          );

          final type = col == 0
              ? TileType.start
              : col == columns - 1
                  ? TileType.finish
                  : TileType.normal_landscape;

          tileGrid[row][col] = type;
          final tile = FloorTile(id: id, type: type, position: position);
          add(tile);

          if (type == TileType.start) {
            startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
          }
        }
      }
    } else if (currentLevel == 2) {
      const rows = 3;
      const columns = 2;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - rows * tileSize) / 2;

      tileGrid = List.generate(rows, (row) => List.filled(columns, null));

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          TileType? type;

          if (row == 0) {
            if (col == 0) {
              type = TileType.start;
            } else {
              type = TileType.belok_enamsembilan;
            }
          } else if (row == 1 && col == 1) {
            type = TileType.normal;
          } else if (row == 2 && col == 1) {
            type = TileType.belok_sembilannol;
          } else if (row == 2 && col == 0) {
            type = TileType.finish;
          }

          if (type != null) {
            final id = 'row${row}_col$col';
            final position = Vector2(
              startX + col * tileSize,
              startY + row * tileSize,
            );

            tileGrid[row][col] = type;
            final tile = FloorTile(id: id, type: type, position: position);
            add(tile);

            if (type == TileType.start) {
              startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
            }
          }
        }
      }
    } else if (currentLevel == 3) {
      const rows = 3;
      const columns = 3;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - rows * tileSize) / 2;

      tileGrid = List.generate(rows, (row) => List.filled(columns, null));

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          TileType? type;

          if (row == 0) {
            if (col == 0) {
              type = TileType.start;
            } else if (row == 0 && col == 1) {
              type = TileType.belok_enamsembilan;
            } else {
              type = null;
            }
          } else if (row == 1 && col == 1) {
            type = TileType.normal;
          } else if (row == 2 && col == 1) {
            type = TileType.belok_noltiga;
          } else if (row == 2 && col == 2) {
            type = TileType.finish;
          }

          if (type != null) {
            final id = 'row${row}_col$col';
            final position = Vector2(
              startX + col * tileSize,
              startY + row * tileSize,
            );

            tileGrid[row][col] = type;
            final tile = FloorTile(id: id, type: type, position: position);
            add(tile);

            if (type == TileType.start) {
              startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
            }
          }
        }
      }
    } else if (currentLevel == 4) {
      const rows = 3;
      const columns = 4;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - rows * tileSize) / 2;

      tileGrid = List.generate(rows, (row) => List.filled(columns, null));

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          TileType? type;

          if (row == 0) {
            if (col == 0) {
              type = TileType.start;
            } else if (row == 0 && col == 1) {
              type = TileType.belok_enamsembilan;
            } else {
              type = null;
            }
          } else if (row == 1 && (col == 1)) {
            type = TileType.belok_noltiga;
          } else if (row == 1 && (col == 2)) {
            type = TileType.normal_landscape;
          } else if (row == 1 && (col == 3)) {
            type = TileType.belok_enamsembilan;
          } else if (row == 2 && (col == 0 || col == 1 || col == 2)) {
            type = null;
          } else if (row == 2 && col == 3) {
            type = TileType.finish;
          }

          if (type != null) {
            final id = 'row${row}_col$col';
            final position = Vector2(
              startX + col * tileSize,
              startY + row * tileSize,
            );

            tileGrid[row][col] = type;
            final tile = FloorTile(id: id, type: type, position: position);
            add(tile);

            if (type == TileType.start) {
              startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
            }
          }
        }
      }
    } else if (currentLevel == 5) {
      const rows = 2;
      const columns = 5;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - rows * tileSize) / 2;

      tileGrid = List.generate(rows, (row) => List.filled(columns, null));

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          TileType? type;
          if (row == 0) {
            if (row == 0 && col == 0) {
              type = TileType.start;
            } else if (row == 0 && col == 1) {
              type = TileType.normal_landscape;
            } else if (row == 0 && col == 2) {
              type = TileType.belok_enamsembilan;
            } else if (row == 0 && col == 3) {
              type = null;
            } else {
              type = TileType.finish;
            }
          } else if (row == 1 && col == 2) {
            type = TileType.belok_noltiga;
          } else if (row == 1 && col == 3) {
            type = TileType.normal_landscape;
          } else if (row == 1 && col == 4) {
            type = TileType.belok_sembilannol;
          } else {
            type = null;
          }

          if (type != null) {
            final id = 'row${row}_col$col';
            final position = Vector2(
              startX + col * tileSize,
              startY + row * tileSize,
            );
            tileGrid[row][col] = type;
            final tile = FloorTile(id: id, type: type, position: position);
            add(tile);

            if (type == TileType.start) {
              startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
            }
          }
        }
      }
    } else if (currentLevel == 6) {
      const rows = 3;
      const columns = 6;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - rows * tileSize) / 2;

      tileGrid = List.generate(rows, (row) => List.filled(columns, null));

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < columns; col++) {
          TileType? type;
          if (row == 0) {
            if (col == 3 || col == 4) {
              type = null;
            } else if (col == 0) {
              type = TileType.start;
            } else if (col == 1) {
              type = TileType.normal_landscape;
            } else if (col == 2) {
              type = TileType.belok_enamsembilan;
            } else {
              type = TileType.finish;
            }
          } else if (row == 1 && col == 2) {
            type = TileType.normal;
          } else if (row == 1 && col == 4) {
            type = TileType.belok_tigaenam;
          } else if (row == 1 && col == 5) {
            type = TileType.belok_sembilannol;
          } else if (row == 2 && col == 2) {
            type = TileType.belok_noltiga;
          } else if (row == 2 && col == 3) {
            type = TileType.normal_landscape;
          } else if (row == 2 && col == 4) {
            type = TileType.belok_sembilannol;
          }

          if (type != null) {
            final id = 'row${row}_col$col';
            final position = Vector2(
              startX + col * tileSize,
              startY + row * tileSize,
            );
            tileGrid[row][col] = type;
            final tile = FloorTile(id: id, type: type, position: position);
            add(tile);

            if (type == TileType.start) {
              startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
            }
          }
        }
      }
    }
  }

  void showGameOver() {
    _gasPlayer?.stop();
    _startEnginePlayer?.stop();
    FlameAudio.bgm.stop();
    // FlameAudio.play('gameOver.mp3');

    isGameOver = true;
    overlays.add('gameOver');
  }

  Future<void> executeCommands(List<String> commands) async {
    if (isExecuting || isGameOver) return;
    isExecuting = true;
    _isExecutingCommands = true;

    if (_isFirstCommand) {
      _startEnginePlayer?.stop();
      _isFirstCommand = false;
    }

    // try {
    //   _gasPlayer = await FlameAudio.loop('gas.mp3');
    // } catch (e) {
    //   print('Gagal memulai audio: $e');
    // }

    for (final command in commands) {
      if (isGameOver || isTargetReached) break;
      try {
        switch (command) {
          case 'MAJU':
            await _character.moveForward();
            break;
          case 'KANAN':
            await _character.turnRight();
            break;
          case 'KIRI':
            await _character.turnLeft();
            break;
        }
      } finally {
        _gasPlayer?.stop();
        _gasPlayer = null;
      }
    }
    _isExecutingCommands = false;
    checkTargetReached(_character.position);
    isExecuting = false;
  }

  void checkTargetReached(Vector2 position) {
    if (isTargetReached || _isExecutingCommands) return;

    final tileX = ((position.x - startX) ~/ tileSize);
    final tileY = ((position.y - startY) ~/ tileSize);

    if (tileY < 0 ||
        tileY >= tileGrid.length ||
        tileX < 0 ||
        tileX >= tileGrid[tileY].length) {
      return;
    }

    if (tileGrid[tileY][tileX] == TileType.finish) {
      isTargetReached = true;
      showCongratsPopup();
    }
  }

  void showCongratsPopup() {
    FlameAudio.bgm.stop();
    // FlameAudio.play('success.mp3');

    if (currentLevel == 6) {
      overlays.add('gameFinished');
    } else {
      overlays.add('congrats');
    }
    if (onLevelCompleted != null) {
      onLevelCompleted!(calculateStars());
    }
  }

  void resetGame() {
    isGameOver = false;
    overlays.remove('gameOver');
    overlays.remove('congrats');
    isTargetReached = false;
    isExecuting = false;
    disableButtons = false;

    removeAll(children);

    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);

    FlameAudio.bgm.stop();
    // FlameAudio.play('startEngine.mp3');
    _isFirstCommand = true;

    _gasPlayer?.stop();
    _gasPlayer = null;

    FlameAudio.bgm.stop();
    // FlameAudio.play('success.mp3');
  }
}

class Character extends SpriteComponent with HasGameRef<MyGame> {
  // static const double moveDistance = 150;
  late double moveDistance;
  static const double speed = 100;
  static const double rotationSpeed = 1.5;
  Vector2? targetPosition;
  double targetAngle = 0;
  Completer<void>? _movementCompleter;
  Completer<void>? _rotationCompleter;

  Character() : super(size: Vector2.all(80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('character.png');
    updateSize(gameRef.size.x);
    moveDistance = (gameRef.size.x >= 806) ? 150 : 75;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    updateSize(size.x);
  }

  void updateSize(double screenWidth) {
    double characterSize = screenWidth >= 806 ? 80 : 40;
    size = Vector2.all(characterSize);
  }

  Future<void> moveForward() async {
    if (gameRef.isGameOver) return;
    final game = gameRef;

    final direction = Vector2(cos(angle), sin(angle));
    final nextPosition = position + direction * moveDistance;

    final tileX = ((nextPosition.x - game.startX) / moveDistance).floor();
    final tileY = ((nextPosition.y - game.startY) / moveDistance).floor();

    if (tileY < 0 ||
        tileY >= game.tileGrid.length ||
        tileX < 0 ||
        tileX >= game.tileGrid[tileY].length ||
        game.tileGrid[tileY][tileX] == null) {
      game.showGameOver();
      return;
    }

    final snappedX = game.startX + (tileX * moveDistance) + 75;
    final snappedY = game.startY + (tileY * moveDistance) + 75;
    targetPosition = Vector2(snappedX, snappedY);

    _movementCompleter?.completeError("Interrupted");
    targetPosition = nextPosition;
    _movementCompleter = Completer();
    return _movementCompleter!.future;
  }

  Future<void> turnRight() {
    if (gameRef.isGameOver) return Future.value();
    _rotationCompleter?.completeError("Interrupted");
    targetAngle = angle + 1.5708;
    _rotationCompleter = Completer();
    return _rotationCompleter!.future;
  }

  Future<void> turnLeft() {
    if (gameRef.isGameOver) return Future.value();
    _rotationCompleter?.completeError("Interrupted");
    targetAngle = angle - 1.5708;
    _rotationCompleter = Completer();
    return _rotationCompleter!.future;
  }

  void checkCurrentPosition() {
    final game = gameRef;

    final tileX = ((position.x - game.startX) / moveDistance).floor();
    final tileY = ((position.y - game.startY) / moveDistance).floor();

    bool isOutOfBounds = tileY < 0 ||
        tileY >= game.tileGrid.length ||
        tileX < 0 ||
        tileX >= game.tileGrid[tileY].length;

    bool isOnInvalidTile =
        !isOutOfBounds && (game.tileGrid[tileY][tileX] == null);

    if (isOutOfBounds || isOnInvalidTile) {
      game.showGameOver();
      return;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    checkCurrentPosition();

    if (targetPosition != null) {
      final direction = (targetPosition! - position).normalized();
      position += direction * speed * dt;

      if (position.distanceTo(targetPosition!) < 1) {
        position = targetPosition!;
        targetPosition = null;
        _movementCompleter?.complete();
        _movementCompleter = null;
      }
    }

    if ((targetAngle - angle).abs() > 1e-3) {
      final angleDifference = targetAngle - angle;
      final rotationStep = rotationSpeed * dt;

      if (angleDifference.abs() <= rotationStep) {
        angle = targetAngle;
      } else {
        angle += rotationStep * angleDifference.sign;
      }
    } else {
      _rotationCompleter?.complete();
      _rotationCompleter = null;
    }
  }
}
