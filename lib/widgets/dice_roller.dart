import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

final randomizer = Random();

class DiceRoller extends StatefulWidget {
  final void Function(int) onRolled;
  final bool autoRoll;
  final Duration? delay;

  const DiceRoller({
    super.key,
    required this.onRolled,
    this.autoRoll = false,
    this.delay,
  });

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  final _audioPlayer = AudioPlayer();
  int diceNum = 1;
  bool isRolling = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoRoll) {
      Future.delayed(widget.delay ?? const Duration(milliseconds: 500), () {
        rollDice();
      });
    }
  }

  Future<void> rollDice() async {
    if (isRolling) return;

    setState(() => isRolling = true);

    try {
      await _audioPlayer.play(AssetSource('audios/dice-142528.mp3'));
    } catch (_) {}

    const rollDuration = Duration(seconds: 1);
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        diceNum = randomizer.nextInt(6) + 1;
      });

      if (timer.tick * 100 >= rollDuration.inMilliseconds) {
        timer.cancel();

        // Final dice face
        setState(() {
          isRolling = false;
          diceNum = randomizer.nextInt(6) + 1;
        });

        // Give the UI a moment to display the final frame
        Future.delayed(const Duration(seconds: 1), () {
          widget.onRolled(diceNum);
        });
      }

    });
  }

  @override
  void didUpdateWidget(covariant DiceRoller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoRoll && !isRolling) {
      Future.delayed(widget.delay ?? const Duration(milliseconds: 500), () {
        rollDice();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.autoRoll ? null : rollDice,
      child: Image.asset(
        'assets/images/dice/$diceNum.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
