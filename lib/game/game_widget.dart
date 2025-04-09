import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:rodocodo_game/game/Level.dart';
import 'game_logic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flame_audio/flame_audio.dart';

bool disableButtons = false;

class GameScreen extends StatefulWidget {
  final int initialLevel;
  final Function(int)? onLevelCompleted;
  // final Function(bool)? onTargetReached;

  const GameScreen({
    super.key,
    required this.initialLevel,
    this.onLevelCompleted,
    // this.onTargetReached,
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

  @override
  void dispose() {
    FlameAudio.bgm.stop();
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
    if (_isExecuting || _isGameOver || commands.length >= 24) return;

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

      // if (_game.isGameOver || _game.isTargetReached) {
      if (_game.isGameOver || _game.isTargetReached) {
        setState(() {
          commands.clear();
          _currentStep = -1;
          _isExecuting = false;
          _lastExecutedIndex = 0;
          disableButtons = true;
        });
        return;
      }
      // } else if (_game.showGameOver()) {
      //   setState(() {
      //     _isExecuting = false;
      //   });
      // }

      setState(() {
        _lastExecutedIndex = i + 1;
      });
    }

    setState(() {
      _currentStep = -1;
      _isExecuting = false;
    });
  }

  void clearCommands() {
    if (_isExecuting ||
        _isGameOver ||
        commands.isEmpty ||
        _game.isTargetReached) {
      return;
    }

    setState(() {
      commands.clear();
      moveCount = 0;
      _currentStep = -1;
      _lastExecutedIndex = 0;
      disableButtons = false;
    });

    if (!_game.isTargetReached) {
      _game.resetGame();
    }
  }

  int _calculateLines(
      int itemCount, double maxWidth, double itemWidth, double spacing) {
    int itemsPerLine = maxWidth ~/ (itemWidth + spacing);
    return (itemCount / itemsPerLine).ceil();
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
    final ukuranLayar = MediaQuery.of(context).size;
    final isSmallScreen = ukuranLayar.width >= 806;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final commandCount = commands.length;

    final iconSize = isSmallScreen ? 35.0 : 30.0;
    final spacing = isSmallScreen ? 8.0 : 6.0;
    final maxWrapWidth = isSmallScreen ? screenWidth * 0.6 : 500.0;

    final numLines =
        _calculateLines(commandCount, maxWrapWidth, iconSize, spacing);

    final gameHeight = screenHeight *
        (isSmallScreen
            ? (numLines > 1 ? 0.46 : 0.52965)
            : (numLines > 1 ? 0.5 : 0.6));

    debugPrint("Screen Width: $ukuranLayar, isTablet: $isSmallScreen");

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isSmallScreen ? 60 : 40,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Level ${_game.currentLevel}",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 18 : 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              "Total Langkah: $moveCount",
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 18 : 17,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xffFE7B0A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Level(),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 5),
              Row(
                children: [
                  if (!isSmallScreen)
                    Column(
                      spacing: 8,
                      children: [
                        _buildControlButton(
                          'assets/icons/walk_off.svg',
                          () => addCommand('MAJU'),
                          size: isSmallScreen ? 50 : 30,
                        ),
                        _buildControlButton(
                          'assets/icons/left_off.svg',
                          () => addCommand('KIRI'),
                          size: isSmallScreen ? 50 : 30,
                        ),
                        _buildControlButton(
                          'assets/icons/right_off.svg',
                          () => addCommand('KANAN'),
                          size: isSmallScreen ? 50 : 30,
                        ),
                      ],
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 60 : 25),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            (isSmallScreen ? 0.5 : 0.7),
                        height: gameHeight,
                        child: GameWidget(game: _game),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 0),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          'assets/icons/run.svg',
                          runCommands,
                          size: isSmallScreen ? 40 : 30,
                        ),
                        Card(
                          margin: EdgeInsets.all(isSmallScreen ? 10 : 3),
                          elevation: 5,
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 8 : 8),
                            width:
                                isSmallScreen ? ukuranLayar.width * 0.6 : 500,
                            constraints: BoxConstraints(
                              minHeight: isSmallScreen ? 50 : 40,
                              maxHeight: isSmallScreen ? 150 : 100,
                            ),
                            child: SingleChildScrollView(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final iconSize = isSmallScreen ? 35.0 : 30.0;
                                  final spacing = isSmallScreen ? 8.0 : 6.0;

                                  return Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children:
                                        commands.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final command = entry.value;
                                      final isActive = index == _currentStep;

                                      return SvgPicture.asset(
                                        'assets/icons/${_getCommandAsset(command)}_${isActive ? 'on' : 'off'}.svg',
                                        width: iconSize,
                                        height: iconSize,
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        _buildControlButton(
                          'assets/icons/trash.svg',
                          clearCommands,
                          size: isSmallScreen ? 40 : 40,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 0),
                    if (isSmallScreen)
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildControlButton(
                            'assets/icons/walk_off.svg',
                            () => addCommand('MAJU'),
                            size: isSmallScreen ? 50 : 30,
                          ),
                          _buildControlButton(
                            'assets/icons/left_off.svg',
                            () => addCommand('KIRI'),
                            size: isSmallScreen ? 50 : 30,
                          ),
                          _buildControlButton(
                            'assets/icons/right_off.svg',
                            () => addCommand('KANAN'),
                            size: isSmallScreen ? 50 : 30,
                          ),
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

  Widget _buildControlButton(String assetPath, VoidCallback onPressed,
      {required double size}) {
    return IconButton(
      onPressed: disableButtons || _isExecuting ? null : onPressed,
      icon: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
