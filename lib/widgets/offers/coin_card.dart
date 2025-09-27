import 'package:flutter/material.dart';

class CoinCard extends StatelessWidget {
  final String amount;
  final String price;

  const CoinCard({super.key, required this.amount, required this.price});

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
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(80, 30)),
            child: Text(price),
          ),
        ],
      ),
    );
  }
}
