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
  var diceNum = 1;
  bool isRolling = false;

  Future<void> rollDice() async {
    if (isRolling) return;

    setState(() => isRolling = true);

    await _audioPlayer.play(AssetSource('audios/dice-142528.mp3'));

    const rollDuration = Duration(seconds: 1);
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        diceNum = randomizer.nextInt(6) + 1;
      });

      if (timer.tick * 100 >= rollDuration.inMilliseconds) {
        timer.cancel();
        setState(() => isRolling = false);
        diceNum = randomizer.nextInt(6) + 1;
        widget.onRolled(diceNum);
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.autoRoll ? null : rollDice,
          child: Image.asset(
            'assets/images/dice/$diceNum.png',
            width: 60,
            height: 60,
          ),
        ),
      ],
    );
  }
}