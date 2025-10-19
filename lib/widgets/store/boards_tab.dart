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
        List<bool> unlockedBoards = List.generate(
          boardImages.length,
              (index) => unlockedBoardsSet.contains(index),
        );

        return GridView.count(
          crossAxisCount: 3,
          padding: const EdgeInsets.all(8.0),
          childAspectRatio: 0.75,
          children: [
            ...List.generate(boardImages.length, (index) {
              return BoardCard(
                price: "BDT 50",
                imagePath: boardImages[index],
                isLocked: !unlockedBoards[index],
                iapService: iapService,
                productId: 'board_$index',
              );
            }),

            // Bundle card
            BundleBoardCard(
              price: "BDT 200",
              iapService: iapService,
            ),
          ],
        );
      },
    );
  }
}
