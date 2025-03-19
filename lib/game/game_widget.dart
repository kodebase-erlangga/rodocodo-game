import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game_logic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flame_audio/flame_audio.dart';

class GameScreen extends StatefulWidget {
  final int initialLevel;
  final Function(int)? onLevelCompleted;

  const GameScreen({
    super.key,
    required this.initialLevel,
    this.onLevelCompleted,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> commands = [];
  int moveCount = 0;
  int _currentStep = -1;
  bool _isExecuting = false;
  final bool _isGameOver = false;
  int _lastExecutedIndex = 0;
  late MyGame _game;
  bool isRunning = true;

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    // FlameAudio.stopAll();
    super.dispose();
  }

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
    if (_isExecuting || _isGameOver || commands.length >= 28) return;

    FlameAudio.play('command.mp3');

    setState(() {
      commands.add(command);
      moveCount = commands.length;
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
      });

      await _game.executeCommands([commands[i]]);
      await Future.delayed(const Duration(milliseconds: 500));

      if (_game.isGameOver) {
        setState(() {
          _isExecuting = false;
          commands.clear();
          moveCount = 0;
          _lastExecutedIndex = 0;
        });
        return;
      }

      setState(() {
        // moveCount++;
        _lastExecutedIndex = i + 1;
      });
    }

    setState(() {
      _currentStep = -1;
      _isExecuting = false;
    });
  }

  void clearCommands() {
    if (_isExecuting || _isGameOver || commands.isEmpty) return;

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
    _game = MyGame(initialLevel: widget.initialLevel);
    _game.onLevelCompleted = widget.onLevelCompleted;
    _game.clearCommands = clearCommands;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GameWidget(game: _game),
                        ),
                      ),
                    ],
                  ),
                ),
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
      onPressed: _isExecuting ? null : onPressed,
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
      onPressed: _isExecuting ? null : onPressed,
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
