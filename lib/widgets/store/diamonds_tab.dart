import 'package:flutter/material.dart';

import 'bundle_offer_card.dart';
import 'diamond_card.dart';

class DiamondsTab extends StatelessWidget {
  const DiamondsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        BundleOfferCard(),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            DiamondCard(amount: '200', price: 'BDT 99.99'),
            DiamondCard(amount: '400', price: 'BDT 199.99'),
            DiamondCard(amount: '800', price: 'BDT 399.99'),
            DiamondCard(amount: '1,600', price: 'BDT 799.99'),
            DiamondCard(amount: '3,200', price: 'BDT 1,599.99'),
            DiamondCard(amount: '6,400', price: 'BDT 3,199.99'),
          ],
        ),
      ],
    );
  }
}
