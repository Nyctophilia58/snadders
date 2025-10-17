import 'package:flutter/material.dart';
import '../../services/iap_services.dart';

class BundleOfferCard extends StatelessWidget {
  final String title;
  final String price;
  final VoidCallback? onBuy;
  final IAPService iapService;

  const BundleOfferCard({
    super.key,
    this.title = 'Bundle Offer',
    this.price = 'BDT 999.99',
    this.onBuy,
    required this.iapService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.monetization_on, color: Colors.yellow),
                SizedBox(width: 4),
                Text(
                  '100,000 ',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.diamond, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  '100 ',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onBuy ??
                () async{
                  await iapService.purchaseNonConsumable(IAPService.bundleOfferId);
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                price,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
