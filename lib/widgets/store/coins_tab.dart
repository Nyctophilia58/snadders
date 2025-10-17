import 'package:flutter/material.dart';
import 'package:snadders/services/iap_services.dart';
import 'bundle_offer_card.dart';
import 'coin_card.dart';

class CoinsTab extends StatelessWidget {
  const CoinsTab({super.key});

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
            CoinCard(amount: '10,000', price: 'BDT 99.99', productId: IAPService.coins10kId),
            CoinCard(amount: '30,000', price: 'BDT 299.99', productId: IAPService.coins30kId),
            CoinCard(amount: '100,000', price: 'BDT 999.99', productId: IAPService.coins100kId),
            CoinCard(amount: '250,000', price: 'BDT 2499.99', productId: IAPService.coins250kId),
            CoinCard(amount: '1,000,000', price: 'BDT 9999.99', productId: IAPService.coins1MId),
            CoinCard(amount: '2,000,000', price: 'BDT 19999.99', productId: IAPService.coins2MId),
          ],
        ),
      ],
    );
  }
}
