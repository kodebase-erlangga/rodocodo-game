import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game_logic.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final MyGame _game = MyGame();
  List<String> commands = [];
  int moveCount = 0;
  int _currentStep = -1;
  bool _isExecuting = false;
  bool _isGameOver = false;
  int _lastExecutedIndex = 0; // Tambahkan variabel ini

  void resetMoveCount() {
    setState(() {
      moveCount = 0;
    });
  }

  void onLevelUp() {
    setState(() {
      moveCount = 0;
      commands.clear();
      _lastExecutedIndex = 0;
    });
  }

  void addCommand(String command) {
    if (_isExecuting || _isGameOver) return;

    setState(() {
      commands.add(command);
    });
  }

  Future<void> runCommands() async {
    if (_isExecuting || _isGameOver) return;

    _isExecuting = true;

    int start = _lastExecutedIndex;
    int end = commands.length;

    for (int i = start; i < end; i++) {
      setState(() {
        _currentStep = i;
        moveCount++;
      });

      await _game.executeCommands([commands[i]]);
      await Future.delayed(const Duration(milliseconds: 500));

      if (_game.isGameOver) {
        setState(() {
          _isExecuting = false;
          commands.clear();
          _lastExecutedIndex = 0;
        });
        return;
      }

      setState(() {
        _currentStep = -1;
        _isExecuting = false;
      });
    }

    setState(() {
      _lastExecutedIndex = end;
      _currentStep = -1;
      _isExecuting = false;
    });
  }

  void clearCommands() {
    if (_isExecuting || _isGameOver) return;

    setState(() {
      commands.clear();
      moveCount = 0;
      _currentStep = -1;
      _lastExecutedIndex = 0;
    });
  }

  @override
  void initState() {
    super.initState();

    _game.naikLevel = () {
      setState(() {
        moveCount = 0;
        commands.clear();
        _lastExecutedIndex = 0;
      });
    };

    _game.getMoveCount = () => moveCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Level ${_game.currentLevel}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Total Langkah: $moveCount",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.white,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton('assets/icons/run.svg', runCommands,
                            isRunButton: true),
                        Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            width: 800,
                            height: commands.length > 15
                                ? 60 + ((commands.length / 15).ceil() - 1) * 50
                                : 60,
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      commands.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final command = entry.value;
                                    final isActive = index == _currentStep;

                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/${_getCommandAsset(command)}_${isActive ? 'on' : 'off'}.svg',
                                        width: 35,
                                        height: 35,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildImageButton(
                            'assets/icons/trash.svg', clearCommands),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildImageButton('assets/icons/walk_off.svg',
                            () => addCommand('MAJU')),
                        _buildImageButton('assets/icons/left_off.svg',
                            () => addCommand('KIRI')),
                        _buildImageButton('assets/icons/right_off.svg',
                            () => addCommand('KANAN')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCommandAsset(String command) {
    switch (command) {
      case 'MAJU':
        return 'walk';
      case 'KIRI':
        return 'left';
      case 'KANAN':
        return 'right';
      default:
        return 'walk';
    }
  }

  Widget _buildImageButton(String assetPath, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        assetPath,
        width: 50,
        height: 50,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildIconButton(String assetPath, VoidCallback onPressed,
      {bool isRunButton = false}) {
    return IconButton(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        assetPath,
        width: 50,
        height: 50,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
