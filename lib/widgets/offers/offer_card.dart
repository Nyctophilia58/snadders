import 'package:flutter/material.dart';

class OfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String item;
  final String price;
  final IconData icon;
  final String endTime;

  const OfferCard({super.key,
    required this.title,
    required this.subtitle,
    required this.item,
    required this.price,
    required this.icon,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(endTime, style: TextStyle(color: Colors.white)),
            Icon(icon, size: 50, color: Colors.yellow),
            Text(subtitle, style: TextStyle(color: Colors.white, fontSize: 18)),
            Text(item, style: TextStyle(color: Colors.white, fontSize: 24)),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(price),
            ),
          ],
        ),
      ),
    );
  }
}
