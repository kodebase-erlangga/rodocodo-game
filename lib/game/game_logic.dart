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
  List<List<TileType>> tileGrid = [];
  late double startX;
  late Vector2 startTileCenter;

  @override
  Color backgroundColor() => Colors.white;

  @override
  Future<void> onLoad() async {
    _generateFloorTiles();
    _character = Character();
    _character.position = startTileCenter;
    add(_character);
  }

  void _generateFloorTiles() {
    const tileSize = 150.0;
    const rows = 1;
    const columns = 4;

    startX = (size.x - columns * tileSize) / 2;
    final startY = (size.y - tileSize) / 2;

    tileGrid =
        List.generate(rows, (row) => List.filled(columns, TileType.normal));

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final id = 'row${row}_col$col';
        final position = Vector2(
          startX + col * tileSize,
          startY + row * tileSize,
        );

        // Atur urutan tile
        final type = col == 0
            ? TileType.start
            : col == columns - 1
                ? TileType.finish
                : TileType.normal;

        tileGrid[row][col] = type;
        final tile = FloorTile(id: id, type: type, position: position);
        add(tile);

        if (type == TileType.start) {
          startTileCenter = position + Vector2(0, tileSize / 4);
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
        case 'BELOK_KANAN':
          _character.turnRight();
          break;
        case 'BELOK_KIRI':
          _character.turnLeft();
          break;
        default:
          print("Perintah tidak dikenali: $command");
      }
    }
    isExecuting = false;
  }

  void checkTargetReached(Vector2 position) {
    if (isTargetReached) return;

    final tileX =
        ((position.x - startX) ~/ 150).clamp(0, tileGrid[0].length - 1);
    final tileY = 0; // Karena hanya 1 baris

    if (tileGrid[tileY][tileX] == TileType.finish) {
      isTargetReached = true;
      showCongratsPopup();
    }
  }

  void showCongratsPopup() {
    overlays.add('congrats');
  }

  void resetGame() {
    isTargetReached = false;
    isExecuting = false;

    removeAll(children);

    _generateFloorTiles();
    _character = Character();
    _character.position =
        startTileCenter;
    add(_character);
  }
}

class Character extends SpriteComponent with HasGameRef<MyGame> {
  static const double moveDistance = 150;
  static const double speed = 100;
  static const double rotationSpeed = 1.5;
  Vector2? targetPosition;
  double targetAngle = 0;

  Character() : super(size: Vector2.all(100));

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

    // Hitung batas berdasarkan jumlah tile
    final allowedXStart = game.startX;
    final allowedXEnd = allowedXStart + (game.tileGrid[0].length - 1) * 150;
    final allowedY = game.startTileCenter.y;

    // Cek posisi valid dalam area lantai
    if (nextPosition.x < allowedXStart - 75 ||
        nextPosition.x > allowedXEnd + 75 ||
        (nextPosition.y - allowedY).abs() > 75) {
      game.showGameOver();
      return;
    }

    // Cek obstacle
    final tileX = ((nextPosition.x - game.startX) ~/ 150)
        .clamp(0, game.tileGrid[0].length - 1);
    if (game.tileGrid[0][tileX] == TileType.obstacle) {
      print("Cannot move forward, obstacle detected");
      return;
    }

    targetPosition = nextPosition;

    while (targetPosition != null && position.distanceTo(targetPosition!) > 1) {
      await Future.delayed(const Duration(milliseconds: 16));
      game.checkTargetReached(position);
    }
  }

  void turnRight() {
    targetAngle = angle + 1.5708;
  }

  void turnLeft() {
    targetAngle = angle - 1.5708;
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
      }
    }

    if (angle != targetAngle) {
      final angleDifference = targetAngle - angle;
      final rotationStep = rotationSpeed * dt;

      if (angleDifference.abs() <= rotationStep) {
        angle = targetAngle;
      } else {
        angle += rotationStep * angleDifference.sign;
      }
    }
  }
}
