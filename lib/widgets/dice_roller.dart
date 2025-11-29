import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'audio_manager.dart';

final randomizer = Random();

class DiceRoller extends StatefulWidget {
  final void Function(int) onRolled;
  final bool autoRoll;
  final Duration? delay;
  final bool isInteractive;
  final String? diceRollTrigger;
  final int? forcedDiceValue;

  const DiceRoller({
    super.key,
    required this.onRolled,
    this.autoRoll = false,
    this.delay,
    this.isInteractive = true,
    this.diceRollTrigger,
    this.forcedDiceValue,
  });

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
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

  Future<void> rollDice({bool isForced = false, int? forcedValue}) async {
    if (isRolling) return;

    setState(() => isRolling = true);

    try {
      await AudioManager.instance.playSFX('audios/dice-142528.mp3');
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
          diceNum = (isForced && forcedValue != null) ? forcedValue! : randomizer.nextInt(6) + 1;
        });

        // Give the UI a moment to display the final frame, but only call onRolled if not forced
        if (!isForced) {
          Future.delayed(const Duration(seconds: 1), () {
            widget.onRolled(diceNum);
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant DiceRoller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoRoll && !oldWidget.autoRoll && !isRolling) {
      Future.delayed(widget.delay ?? const Duration(milliseconds: 500), () {
        rollDice();
      });
    }
    // NEW: Handle remote dice roll trigger
    if (widget.diceRollTrigger != oldWidget.diceRollTrigger &&
        widget.diceRollTrigger != null &&
        !isRolling) {
      rollDice(isForced: true, forcedValue: widget.forcedDiceValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.isInteractive && !widget.autoRoll) ? rollDice : null,
      child: Image.asset(
        'assets/images/dice/$diceNum.png',
        fit: BoxFit.cover,
      ),
    );
  }
}