import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snadders/widgets/exit_button.dart';
import '../../services/shared_prefs_service.dart';
import 'spin_choice_card.dart';


class Wheel extends StatefulWidget {
  final VoidCallback? onSpinCompleted;

  const Wheel({super.key, this.onSpinCompleted});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> with SingleTickerProviderStateMixin {
  final List<int> _coins = [200, 300, 400, 450, 50, 20, 250, 150, 350, 500, 100];
  final List<int> _diamonds = [20, 35, 40, 45, 50, 2, 25, 15, 30, 5, 10];

  int randomSectorIndex = -1;
  List<double> sectorRadians = [];
  double angle = 0;

  bool spinning = false;
  bool showChoiceCard = true;
  bool spinForCoins = true;
  bool canSpinNow = false;

  double earnedValue = 0;

  math.Random random = math.Random();
  late AnimationController _controller;
  late Animation<double> _animation;
  final SharedPrefsService _prefs = SharedPrefsService();

  @override
  void initState() {
    super.initState();
    generateSectorRadians();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onSpinFinished();
      }
    });

    _checkSpinCooldown();
  }

  Future<void> _checkSpinCooldown() async {
    canSpinNow = await _prefs.canSpin();
    setState(() {});
  }

  void generateSectorRadians() {
    double slice = 2 * math.pi / _coins.length;
    for (int i = 0; i < _coins.length; i++) {
      sectorRadians.add((i + 1) * slice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!spinning && !showChoiceCard) {
          if (canSpinNow) {
            spin();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You can spin only once every hour."),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWheel(),
              const SizedBox(height: 12),
              ExitButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          if (showChoiceCard)
            SpinChoiceCard(
              onCoinsSelected: () {
                setState(() {
                  spinForCoins = true;
                  showChoiceCard = false;
                });
              },
              onDiamondsSelected: () {
                setState(() {
                  spinForCoins = false;
                  showChoiceCard = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.width * 0.8,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/spinWheel/belt.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * angle,
                  child: SvgPicture.asset(
                    spinForCoins
                        ? 'assets/images/spinWheel/coin.svg'
                        : 'assets/images/spinWheel/diamond.svg',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  void spin() {
    if (!canSpinNow) return;

    randomSectorIndex = random.nextInt(_coins.length);
    angle = (2 * math.pi * _coins.length) + sectorRadians[randomSectorIndex];
    spinning = true;
    _controller.reset();
    _controller.forward();
  }

  void onSpinFinished() async {
    setState(() {
      spinning = false;
      earnedValue = spinForCoins
          ? _coins[_coins.length - 1 - randomSectorIndex].toDouble()
          : _diamonds[_diamonds.length - 1 - randomSectorIndex].toDouble();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            spinForCoins
                ? "You earned ${earnedValue.toInt()} coins!"
                : "You earned ${earnedValue.toInt()} diamonds!",
          ),          duration: const Duration(seconds: 2),
        ),
      );
    });

    await _prefs.saveLastSpinTimestamp(DateTime.now().millisecondsSinceEpoch);

    if (spinForCoins) {
      int oldCoins = await _prefs.loadCoins();
      await _prefs.saveCoins(oldCoins + earnedValue.toInt());
    } else {
      int oldDiamonds = await _prefs.loadDiamonds();
      await _prefs.saveDiamonds(oldDiamonds + earnedValue.toInt());
    }

    if (widget.onSpinCompleted != null) {
      widget.onSpinCompleted!();
    }

    canSpinNow = false;
    setState(() {});
  }

}
