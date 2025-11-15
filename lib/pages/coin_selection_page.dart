import 'package:flutter/material.dart';
import 'package:snadders/widgets/buttons/exit_button.dart';
import '../constants/lobby_coin_values.dart';

class CoinSelectionPage extends StatefulWidget {
  final int coins;
  final int diamonds;

  const CoinSelectionPage({
    super.key,
    required this.coins,
    required this.diamonds,
  });

  @override
  State<CoinSelectionPage> createState() => _CoinSelectionPageState();
}

class _CoinSelectionPageState extends State<CoinSelectionPage> {
  int currentIndex = 0;

  int get displayedCoins => LobbyCoinValues.entryFees[currentIndex];
  int get displayedDiamonds => LobbyCoinValues.diamonds[currentIndex];

  void _incrementValues() {
    if (currentIndex < LobbyCoinValues.entryFees.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void _decrementValues() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.transparent,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.greenAccent.shade700.withOpacity(0.9),
                    Colors.greenAccent.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'SELECT LOBBY',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      decoration: TextDecoration.none,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(1, 2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 💰 Coins container row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentIndex > 0)
                        IconButton(
                          onPressed: _decrementValues,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.redAccent.shade700,
                            size: 38,
                          ),
                        )
                      else
                        const SizedBox(width: 48),

                      // 🪙 Central Card
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.shade600.withOpacity(0.9),
                                Colors.orange.shade400.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.monetization_on_rounded,
                                color: Colors.deepOrange.shade900,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.85),
                                      Colors.grey.shade300.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$displayedDiamonds',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.purple.shade900,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Entry: $displayedCoins',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent.shade100,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (currentIndex < LobbyCoinValues.entryFees.length - 1)
                        IconButton(
                          onPressed: _incrementValues,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.green.shade700,
                            size: 38,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // ▶ Play Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, displayedCoins);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent.shade400,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 10,
                        shadowColor: Colors.pinkAccent,
                      ),
                      child: const Text(
                        'PLAY',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: -35,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.yellowAccent),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.diamond, color: Colors.cyanAccent),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.diamonds}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ❌ Exit Button at Bottom
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            child: Center(
              child: ExitButton(
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
