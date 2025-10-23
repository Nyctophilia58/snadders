import 'package:flutter/material.dart';
import 'package:snadders/widgets/exit_button.dart';
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
      setState(() {
        currentIndex++;
      });
    }
  }

  void _decrementValues() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- Main Card ---
          Card(
            color: Colors.greenAccent.withAlpha(250),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'SELECT LOBBY',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Coins container row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      if (currentIndex > 0)
                        IconButton(
                          onPressed: _decrementValues,
                          icon: Icon(
                            Icons.indeterminate_check_box_outlined,
                            color: Colors.red.shade700,
                            size: 35,
                          ),
                        )
                      else
                        const SizedBox(width: 48),

                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade500.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.deepOrange.shade700,
                                size: 24,
                              ),
                              const SizedBox(height: 10),
                              // Diamonds with FittedBox
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$displayedDiamonds',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade900,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Entry fee
                              Text(
                                'Entry: $displayedCoins',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Add button
                      if (currentIndex < LobbyCoinValues.entryFees.length - 1)
                        IconButton(
                          onPressed: _incrementValues,
                          icon: Icon(
                            Icons.add_box_outlined,
                            color: Colors.red.shade700,
                            size: 35,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- Play button ---
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, displayedCoins);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor: Colors.purple,
                      ),
                      child: const Text(
                        'PLAY',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Coins + Diamonds floating bar ---
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.yellow),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              offset: Offset(0, 0),
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.diamond, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.diamonds}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              offset: Offset(0, 0),
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: 0,
            right: 0,
            // exit button
            child: Center(
              child: ExitButton(
                onPressed: () {
                  Navigator.pop(context);
                }
              )
            ),
          )
        ],
      ),
    );
  }
}
