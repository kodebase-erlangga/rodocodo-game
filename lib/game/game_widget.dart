import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game_logic.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final MyGame _game = MyGame();
  List<String> commands = [];

  void addCommand(String command) {
    setState(() {
      commands.add(command);
    });
  }

  void runCommands() {
    _game.executeCommands(commands);
    setState(() {
      commands = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: GameWidget(game: _game)),
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildIconButton(Icons.arrow_upward, () => addCommand('MAJU')),
                        _buildIconButton(Icons.arrow_forward, () => addCommand('BELOK_KANAN')),
                        _buildIconButton(Icons.arrow_back, () => addCommand('BELOK_KIRI')),
                        _buildIconButton(Icons.rotate_left, () => addCommand('PUTAR_BALIK')),
                        _buildIconButton(Icons.play_arrow, runCommands, isRunButton: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Perintah: ${commands.join(', ')}",
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_game.isTargetReached)
            Center(
              child: AlertDialog(
                title: const Text("Congrats!"),
                content: const Text("Anda berhasil mencapai target!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _game.isTargetReached = false;
                      });
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed, {bool isRunButton = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunButton ? Colors.green : Colors.blueGrey[700],
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}