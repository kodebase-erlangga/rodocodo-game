import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum TileType { normal, coin, obstacle, finish, start }

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
    await super.onLoad();
    await _updateSprite();
  }

  Future<void> _updateSprite() async {
    switch (_type) {
      case TileType.start:
        sprite = await gameRef.loadSprite('start.jpg');
        break;
      case TileType.normal:
        sprite = await gameRef.loadSprite('lantai.jpg');
        break;
      case TileType.coin:
        sprite = await gameRef.loadSprite('koin.jpg');
        break;
      case TileType.obstacle:
        sprite = await gameRef.loadSprite('granat.jpg');
        break;
      case TileType.finish:
        sprite = await gameRef.loadSprite('finish.jpg');
        break;
    }
  }
}

class MyGame extends FlameGame {
  late Character _character;
  bool isExecuting = false;
  bool isTargetReached = false;
  List<List<TileType?>> tileGrid = [];
  late double startX;
  late double startY;
  late Vector2 startTileCenter;

  int currentLevel = 1;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);
  }

  @override
  void onAttach() {
    overlays.addEntry('gameOver', (context, game) {
      return Center(
        child: AlertDialog(
          title: const Text("Game Over!"),
          content: const Text("Karakter keluar dari jalur!"),
          actions: [
            TextButton(
              onPressed: () {
                overlays.remove('gameOver');
                resetGame();
              },
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    });

    overlays.addEntry('congrats', (context, game) {
      return Center(
        child: AlertDialog(
          title: const Text("Selamat!"),
          content: const Text("Anda berhasil mencapai finish!"),
          actions: [
            TextButton(
              onPressed: () {
                overlays.remove('congrats');
                currentLevel++;
                resetGame();
              },
              child: const Text("Level Selanjutnya"),
            ),
          ],
        ),
      );
    });
    super.onAttach();
  }

  void _generateFloorTiles() {
    const tileSize = 150.0;
    removeWhere((component) => component is FloorTile);

    if (currentLevel == 1) {
      const rows = 1;
      const columns = 4;
      startX = (size.x - columns * tileSize) / 2;
      startY = (size.y - tileSize) / 2;

      tileGrid =
          List.generate(rows, (row) => List.filled(columns, TileType.normal));

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
                  : TileType.normal;

          tileGrid[row][col] = type;
          final tile = FloorTile(id: id, type: type, position: position);
          add(tile);

          if (type == TileType.start) {
            startTileCenter = position + Vector2(tileSize / 2, tileSize / 2);
          }
        }
      }
    } else if (currentLevel == 2) {
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
    } else if (currentLevel == 3) {
      const rows = 3;
      const columns = 5;
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
          } else if (row == 1 && (col == 2)) {
            type = TileType.normal;
          } else if (row == 2 && (col == 2 || col == 3 || col == 4)){
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
    }
  }

  void showGameOver() {
    overlays.add('gameOver');
  }

  Future<void> executeCommands(List<String> commands) async {
    if (isExecuting) return;
    isExecuting = true;

    for (final command in commands) {
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
        default:
          print("Perintah tidak dikenali: $command");
      }
      checkTargetReached(_character.position);
    }
    isExecuting = false;
  }

  void checkTargetReached(Vector2 position) {
    if (isTargetReached) return;

    final tileX = ((position.x - startX) ~/ 150);
    final tileY = ((position.y - startY) ~/ 150);

    if (tileY < 0 ||
        tileY >= tileGrid.length ||
        tileX < 0 ||
        tileX >= tileGrid[tileY].length) return;

    if (tileGrid[tileY][tileX] == TileType.finish) {
      isTargetReached = true;
      showCongratsPopup();
    }
  }

  void showCongratsPopup() {
    overlays.add('congrats');
  }

  void resetGame() {
    overlays.remove('gameOver');
    overlays.remove('congrats');
    isTargetReached = false;
    isExecuting = false;

    removeAll(children);

    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);
  }
}

class Character extends SpriteComponent with HasGameRef<MyGame> {
  static const double moveDistance = 150;
  static const double speed = 100;
  static const double rotationSpeed = 1.5;
  Vector2? targetPosition;
  double targetAngle = 0;
  Completer<void>? _movementCompleter;
  Completer<void>? _rotationCompleter;

  Character() : super(size: Vector2.all(100), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    try {
      sprite = await gameRef.loadSprite('character.png');
    } catch (e) {
      print("Gagal memuat gambar karakter: $e");
    }
  }

  Future<void> moveForward() async {
    final game = gameRef;
    final direction = Vector2(cos(angle), sin(angle));
    final nextPosition = position + direction * moveDistance;

    final tileX = ((nextPosition.x - game.startX) ~/ 150);
    final tileY = ((nextPosition.y - game.startY) ~/ 150);

    if (tileY < 0 ||
        tileY >= game.tileGrid.length ||
        tileX < 0 ||
        tileX >= game.tileGrid[tileY].length) {
      game.showGameOver();
      return;
    }

    TileType? tileType = game.tileGrid[tileY][tileX];
    if (tileType == null || tileType == TileType.obstacle) {
      game.showGameOver();
      return;
    }

    // Proceed dengan pergerakan
    _movementCompleter?.completeError("Interrupted");
    targetPosition = nextPosition;
    _movementCompleter = Completer();
    return _movementCompleter!.future;
  }

  Future<void> turnRight() {
    _rotationCompleter?.completeError("Interrupted");
    targetAngle = angle + 1.5708;
    _rotationCompleter = Completer();
    return _rotationCompleter!.future;
  }

  Future<void> turnLeft() {
    _rotationCompleter?.completeError("Interrupted");
    targetAngle = angle - 1.5708;
    _rotationCompleter = Completer();
    return _rotationCompleter!.future;
  }

  @override
  void update(double dt) {
    super.update(dt);

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
