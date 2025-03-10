// import 'dart:math';
// import 'package:flame/components.dart';
// import 'package:flame/game.dart';
// import 'package:flutter/material.dart';

// class MyGame extends FlameGame {
//   late Character _character;
//   late SpriteComponent _target;
//   bool isExecuting = false;
//   bool isTargetReached = false;

//   @override
//   Color backgroundColor() => Colors.greenAccent;

//   @override
//   Future<void> onLoad() async {
//     _character = Character();
//     add(_character);

//     _target = SpriteComponent()
//       ..sprite = await loadSprite('target.png')
//       ..size = Vector2(50, 50)
//       ..position = Vector2(400, 500);
//     add(_target);
//   }

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     _drawGrid(canvas);
//   }

//   void _drawGrid(Canvas canvas) {
//     final gridPaint = Paint()
//       ..color = Colors.white.withOpacity(0.2)
//       ..strokeWidth = 1;

//     const gridSize = 50;
//     final screenWidth = size.x;
//     final screenHeight = size.y;

//     for (double x = 0; x <= screenWidth; x += gridSize) {
//       canvas.drawLine(Offset(x, 0), Offset(x, screenHeight), gridPaint);
//     }

//     for (double y = 0; y <= screenHeight; y += gridSize) {
//       canvas.drawLine(Offset(0, y), Offset(screenWidth, y), gridPaint);
//     }
//   }

//   Future<void> executeCommands(List<String> commands) async {
//     if (isExecuting) return;
//     isExecuting = true;

//     for (final command in commands) {
//       switch (command) {
//         case 'MAJU':
//           await _character.moveForward();
//           break;
//         case 'BELOK_KANAN':
//           _character.turnRight();
//           break;
//         case 'BELOK_KIRI':
//           _character.turnLeft();
//           break;
//         default:
//           print("Perintah tidak dikenali: $command");
//       }
//     }
//     isExecuting = false;
//   }

//   void checkTargetReached() {
//     if (_character.position.distanceTo(_target.position) < 25 &&
//         !isTargetReached) {
//       isTargetReached = true;
//       showCongratsPopup();
//     }
//   }

//   void showCongratsPopup() {
//     overlays.add('congrats');
//   }
// }

// class Character extends SpriteComponent with HasGameRef<MyGame> {
//   static const double moveDistance = 50;
//   static const double speed = 100;
//   static const double rotationSpeed = 1.5;
//   Vector2? targetPosition;
//   double targetAngle = 0;

//   Character() : super(size: Vector2.all(50));

//   @override
//   Future<void> onLoad() async {
//     try {
//       sprite = await gameRef.loadSprite('character.png');
//       print("Gambar karakter berhasil dimuat!");
//     } catch (e) {
//       print("Gagal memuat gambar karakter: $e");
//     }
//     position = Vector2(100, 300);
//     angle = 0;
//   }

//   Future<void> moveForward() async {
//     final direction = Vector2(cos(angle), sin(angle));
//     targetPosition = position + direction * moveDistance;

//     while (targetPosition != null && position.distanceTo(targetPosition!) > 1) {
//       await Future.delayed(const Duration(milliseconds: 16));
//       gameRef.checkTargetReached();
//     }
//   }

//   void turnRight() {
//     targetAngle = angle + 1.5708;
//   }

//   void turnLeft() {
//     targetAngle = angle - 1.5708;
//   }

//   void turnAround() {
//     targetAngle = angle + 3.1416;
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     if (targetPosition != null) {
//       final direction = (targetPosition! - position).normalized();
//       position += direction * speed * dt;

//       if (position.distanceTo(targetPosition!) < 1) {
//         position = targetPosition!;
//         targetPosition = null;
//       }
//     }

//     if (angle != targetAngle) {
//       final angleDifference = targetAngle - angle;
//       final rotationStep = rotationSpeed * dt;

//       if (angleDifference.abs() <= rotationStep) {
//         angle = targetAngle;
//       } else {
//         angle += rotationStep * angleDifference.sign;
//       }
//     }
//   }
// }