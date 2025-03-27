// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rodocodo_game/Level.dart';
import 'package:rodocodo_game/game/mainPage.dart';

enum TileType {
  normal,
  finish,
  start,
  normal_landscape,
  belok_noltiga,
  belok_sembilannol,
  belok_tigasembilan,
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

  Future<void> onLoad() async {
    await super.onLoad();
    updateSize(gameRef.size.x);
    await _updateSprite();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    updateSize(newSize.x);
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
      case TileType.belok_sembilannol:
        sprite = await gameRef.loadSprite('belok_sembilannol.png');
        break;
      case TileType.belok_tigasembilan:
        sprite = await gameRef.loadSprite('belok_tigasembilan.png');
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
  bool _isFirstCommand = true;
  Function()? clearCommands;

  double tileSize = 150.0;

  MyGame({int initialLevel = 1, this.onLevelCompleted})
      : currentLevel = initialLevel;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    _startEnginePlayer = await FlameAudio.play('startEngine.mp3');

    updateTileSize(size.x);

    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    updateTileSize(newSize.x);
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

      return Center(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Center(
            child: Text(
              stars == 3 ? "Selamat! 🎉" : "Yahh! 😞",
              style: TextStyle(
                  fontSize: 24,
                  color: stars == 3 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  stars == 3
                      ? "Kamu menemukan solusi optimal!"
                      : "Kamu belum menemukan solusi optimal!",
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 15),
              Text(
                stars == 3
                    ? "Menggunakan $moveCount perintah"
                    : stars == 2
                        ? "Kamu menggunakan $moveCount perintah"
                        : "Ayo Coba Lagi! Kamu menggunakan $moveCount perintah",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: stars == 3 ? Colors.green : Colors.orange),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (index) => Icon(
                          Icons.star,
                          color:
                              index < stars ? Colors.amber : Colors.grey[300],
                          size: 40,
                        )),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            // Padding(
            // padding: const EdgeInsets.symmetric(horizontal: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    myGame.overlays.remove('congrats');
                    myGame.resetGame();
                    if (myGame.naikLevel != null) myGame.naikLevel!();
                  },
                  child: SvgPicture.asset(
                    'assets/icons/restart.svg',
                    width: 50,
                    height: 50,
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    myGame.overlays.remove('congrats');
                    myGame.currentLevel++;
                    myGame.resetGame();
                    if (myGame.naikLevel != null) myGame.naikLevel!();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Level(),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/next.svg',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
            // ),
          ],
        ),
      );
    });

    overlays.addEntry('gameOver', (context, game) {
      return Center(
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(255, 251, 97, 148),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "GAME OVER!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: const Text(
            "Ohh noo! Keluar dari jalur!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    overlays.remove('gameOver');
                    resetGame();
                  },
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/restart.svg',
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenuScreen()),
                      (route) => false, // Menghapus semua halaman sebelumnya
                    );
                  },
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/home.svg',
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });

    overlays.addEntry('gameFinished', (context, game) {
      final myGame = game as MyGame;
      final stars = myGame.calculateStars();

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  Icons.star,
                  color: index < stars ? Colors.amber : Colors.grey[300],
                  size: 40,
                ),
              ),
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Center(
                child: Text(
                  "LUAR BIASA! 🏆",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Anda telah menamatkan semua level!",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Kamu menemukan solusi optimal, menggunakan ${myGame.getMoveCount?.call() ?? 0} perintah",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainMenuScreen()),
                      );
                    },
                    child: const Text(
                      "MENU UTAMA",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
              type = TileType.belok_tigasembilan;
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
              type = TileType.belok_tigasembilan;
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
              type = TileType.belok_tigasembilan;
            } else {
              type = null;
            }
          } else if (row == 1 && (col == 2 || col == 3)) {
            type = TileType.normal;
          } else if (row == 1 && (col == 1)) {
            type = TileType.belok_noltiga;
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
            if (col == 3) {
              type = null;
            } else {
              type = col == 0
                  ? TileType.start
                  : col == columns - 1
                      ? TileType.finish
                      : TileType.normal;
            }
          } else if (row == 1 && (col == 2 || col == 3 || col == 4)) {
            type = TileType.normal;
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
            } else {
              type = col == 0
                  ? TileType.start
                  : col == columns - 1
                      ? TileType.finish
                      : TileType.normal;
            }
          } else if (row == 1 && (col == 2 || col == 4 || col == 5)) {
            type = TileType.normal;
          } else if (row == 2 && (col == 2 || col == 3 || col == 4)) {
            type = TileType.normal;
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
    FlameAudio.bgm.stop();
    FlameAudio.play('gameOver.mp3');

    isGameOver = true;
    overlays.add('gameOver');
  }

  Future<void> executeCommands(List<String> commands) async {
    if (isExecuting || isGameOver) return;
    isExecuting = true;
    _isExecutingCommands = true;

    for (final command in commands) {
      if (isGameOver || isTargetReached) break;

      if (_isFirstCommand) {
        _startEnginePlayer?.stop();
        _isFirstCommand = false;
      }

      AudioPlayer? gasPlayer;
      try {
        gasPlayer = await FlameAudio.loop('gas.mp3');

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
        gasPlayer?.stop();
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
    FlameAudio.play('success.mp3');

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

    removeAll(children);

    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);

    FlameAudio.bgm.stop();
    FlameAudio.play('startEngine.mp3');
    _isFirstCommand = true;
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
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    updateSize(newSize.x);
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
