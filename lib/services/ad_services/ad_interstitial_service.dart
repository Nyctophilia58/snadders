import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snadders/constants/ad_unit_ids.dart';

class AdInterstitialService {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  static void loadInterstitialAd() {
    if (_isLoading || _interstitialAd != null) return; // Prevent multiple load attempts
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          _setInterstitialCallbacks(ad);
          print("Interstitial Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          print("Interstitial Ad Failed to Load: code=${error.code}, message=${error.message}");
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 5), loadInterstitialAd);
        },
      ),
    );
  }

  static void _setInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print("Interstitial Ad Failed to Show: $error");
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdShowedFullScreenContent: (ad) {
        print("Interstitial Ad Showing");
      },
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print("Interstitial not ready yet, loading...");
      loadInterstitialAd();
      Future.delayed(const Duration(seconds: 2), () {
        if (_interstitialAd != null) {
          showInterstitialAd();
        }
      });
    }
  }
}