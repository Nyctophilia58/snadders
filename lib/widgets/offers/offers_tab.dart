import 'package:flutter/material.dart';
import 'offer_card.dart';

class OffersTab extends StatelessWidget {
  const OffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8.0),
      children: [
        OfferCard(
          title: 'Super Sale',
          subtitle: 'Flat 25% OFF',
          item: '2,000,000',
          price: 'BDT 5,859.89',
          icon: Icons.storage, // Placeholder for gold bars
          endTime: 'Ends in 01d:00h:43m:44s',
        ),
        OfferCard(
          title: 'Super Sale',
          subtitle: 'Flat 25% OFF',
          item: '6,400',
          price: 'BDT 2,278.39',
          icon: Icons.diamond,
          endTime: 'Ends in 01d:00h:43m:44s',
        ),
        OfferCard(
          title: 'Combo Offer',
          subtitle: 'Save 30%',
          item: '6,400 + 2,000,000',
          price: 'BDT 6,901.79',
          icon: Icons.diamond, // Combined icons needed
          endTime: 'Ends in 01d:00h:43m:44s',
        ),
      ],
    );
  }
}