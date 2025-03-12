import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game_logic.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  int _currentStep = -1;
  bool _isExecuting = false;

  void addCommand(String command) {
    if (_isExecuting) return;

    setState(() {
      commands.add(command);
      moveCount++;
    });
  }

  Future<void> runCommands() async {
    if (_isExecuting) return;

    _isExecuting = true;
    for (int i = 0; i < commands.length; i++) {
      setState(() => _currentStep = i);
      await _game.executeCommands([commands[i]]);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() {
      commands = [];
      _currentStep = -1;
      _isExecuting = false;
    });
  }

  String _getButtonAsset(String commandType) {
    if (_currentStep == -1) {
      return 'assets/icons/${commandType.toLowerCase()}_off.svg';
    }

    final currentCommand =
        _currentStep < commands.length ? commands[_currentStep] : '';
    return 'assets/icons/${commandType.toLowerCase()}_${currentCommand == commandType ? 'on' : 'off'}.svg';
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
                        _buildImageButton('assets/icons/walk_off.svg',
                            () => addCommand('MAJU')),
                        _buildImageButton('assets/icons/left_off.svg',
                            () => addCommand('KIRI')),
                        _buildImageButton('assets/icons/right_off.svg',
                            () => addCommand('KANAN')),
                        _buildIconButton('assets/icons/run.svg', runCommands,
                            isRunButton: true),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: commands.asMap().entries.map((entry) {
                        final index = entry.key;
                        final command = entry.value;
                        final isActive = index == _currentStep;

                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            'assets/icons/${_getCommandAsset(command)}_${isActive ? 'on' : 'off'}.svg',
                            width: 24,
                            height: 24,
                          ),
                        );
                      }).toList(),
                    ),
                    // Wrap(
                    //   spacing: 8,
                    //   children: commands.map((command) {
                    //     Widget iconWidget;
                    //     switch (command) {
                    //       case 'MAJU':
                    //         iconWidget = SvgPicture.asset(
                    //             'assets/icons/walk_off.svg',
                    //             width: 24,
                    //             height: 24);
                    //         break;
                    //       case 'KIRI':
                    //         iconWidget = SvgPicture.asset(
                    //             'assets/icons/left_off.svg',
                    //             width: 24,
                    //             height: 24);
                    //         break;
                    //       case 'KANAN':
                    //         iconWidget = SvgPicture.asset(
                    //             'assets/icons/right_off.svg',
                    //             width: 24,
                    //             height: 24);
                    //         break;
                    //       default:
                    //         iconWidget = const Icon(Icons.error,
                    //             color: Colors.black, size: 24);
                    //     }
                    //     return Padding(
                    //       padding: const EdgeInsets.all(4.0),
                    //       child: iconWidget,
                    //     );
                    //   }).toList(),
                    // ),
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

  String _getAssetPath(String command) {
    switch (command) {
      case 'MAJU':
        return 'assets/icons/walk_${_currentStep != -1 ? 'on' : 'off'}.svg';
      case 'KIRI':
        return 'assets/icons/left_${_currentStep != -1 ? 'on' : 'off'}.svg';
      case 'KANAN':
        return 'assets/icons/right_${_currentStep != -1 ? 'on' : 'off'}.svg';
      default:
        return 'assets/icons/walk_off.svg';
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
