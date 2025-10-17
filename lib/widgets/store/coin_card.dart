import 'package:flutter/material.dart';

import '../../services/iap_services.dart';

class CoinCard extends StatelessWidget {
  final String amount;
  final String price;
  final String productId;

  const CoinCard({super.key, required this.amount, required this.price, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, size: 40, color: Colors.yellow),
          Text(amount, style: TextStyle(color: Colors.white)),
          ElevatedButton(
            onPressed: () {
              IAPService.instance.purchaseConsumable(productId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(80, 30)),
            child: Text(price, style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
