import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatelessWidget {
  final BannerAd ad;
  const BannerAdWidget({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: AdWidget(ad: ad),
    );
  }
}
