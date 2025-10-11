import 'package:flutter/material.dart';

class BundleOfferCard extends StatelessWidget {
  const BundleOfferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[800],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Bundle Offer', style: TextStyle(color: Colors.yellow, fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: Colors.yellow),
                Text('100,000 Coins + 100 Diamonds'),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('BDT 1,098.09'),
            ),
          ],
        ),
      ),
    );
  }
}
