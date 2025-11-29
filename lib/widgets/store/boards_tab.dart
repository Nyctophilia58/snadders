import 'package:flutter/material.dart';
import '../../constants/board_constants.dart';
import '../../widgets/store/board_card.dart';
import '../../widgets/store/boards_bundle_card.dart';
import '../../services/iap_services.dart';

class BoardsTab extends StatelessWidget {
  final IAPService iapService;
  const BoardsTab({super.key, required this.iapService});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: iapService.unlockedBoardsNotifier,
      builder: (context, unlockedBoardsSet, _) {
        // Create a list to check which boards are unlocked
        List<bool> unlockedBoards = List.generate(
          boardImages.length,
              (index) => unlockedBoardsSet.contains(index),
        );

        // Build the board cards
        List<Widget> boardCards = List.generate(boardImages.length, (index) {
          return BoardCard(
            price: "BDT 50",
            imagePath: boardImages[index],
            isLocked: !unlockedBoards[index],
            iapService: iapService,
            productId: 'board.$index',
          );
        });

        int totalUnlocked = unlockedBoards.where((isUnlocked) => isUnlocked).length;
        int remainingBoards = boardImages.length - totalUnlocked;
        int bundlePriceValue = 40 * remainingBoards;
        String bundlePrice = "BDT $bundlePriceValue";

        // Show the bundle card only if not all boards are unlocked
        if (!unlockedBoardsSet.containsAll(List.generate(8, (i) => i))) {
          boardCards.add(
            BundleBoardCard(
              price: bundlePrice,
              iapService: iapService,
              productId: iapService.getBoardsBundleProductId(remainingBoards),
            ),
          );
        }

        return GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(8.0),
          childAspectRatio: 0.75,
          children: boardCards,
        );
      },
    );
  }
}
