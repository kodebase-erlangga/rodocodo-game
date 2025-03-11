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
  int moveCount = 0;

  void addCommand(String command) {
    setState(() {
      commands.add(command);
      moveCount++;
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
                        _buildImageButton(
                            'assets/images/maju.png', () => addCommand('MAJU')),
                        _buildImageButton(
                            'assets/images/kiri.png', () => addCommand('KIRI')),
                        _buildImageButton('assets/images/kanan.png',
                            () => addCommand('KANAN')),
                        _buildIconButton(Icons.play_arrow, runCommands,
                            isRunButton: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: commands.map((command) {
                        IconData icon;
                        switch (command) {
                          case 'MAJU':
                            icon = Icons.arrow_upward;
                            break;
                          case 'KIRI':
                            icon = Icons.arrow_back;
                            break;
                          case 'KANAN':
                            icon = Icons.arrow_forward;
                            break;
                          default:
                            icon = Icons.error;
                        }
                        return Icon(
                          icon,
                          color: Colors.black,
                          size: 24,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total Langkah: $moveCount",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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
                        moveCount = 0;
                      });
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
          if (_game.isTargetReached)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    commands = [];
                    _game.resetGame();
                    moveCount = 0;
                  });
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.replay),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageButton(String assetPath, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white, width: 1),
        ),
      ),
      child: Image.asset(
        assetPath,
        width: 24,
        height: 24,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed,
      {bool isRunButton = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isRunButton ? Colors.green : Colors.blueGrey[700],
        padding: const EdgeInsets.all(12),
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
