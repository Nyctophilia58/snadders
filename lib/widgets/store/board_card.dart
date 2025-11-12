import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:snadders/services/iap_services.dart';

class BoardCard extends StatelessWidget {
  final String price;
  final String imagePath;
  final bool isLocked;
  final String productId;
  final IAPService iapService;

  const BoardCard({
    super.key,
    required this.price,
    required this.imagePath,
    required this.isLocked,
    required this.productId,
    required this.iapService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          // Board image with black overlay if locked
          Container(
            decoration: BoxDecoration(
              color: isLocked ? Colors.black87 : Colors.transparent, // dark only if locked
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SvgPicture.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),

          // Lock icon overlay (does not block button)
          if (isLocked)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),
            ),

          // Buy button overlayed at bottom center
          if (isLocked)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await iapService.purchaseConsumable(productId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    price,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
