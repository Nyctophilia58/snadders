import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:snadders/constants/ad_unit_ids.dart';

class AdRewardService {
  static RewardedAd? _rewardedAd;
  static bool _isRewardedLoading = false;

  static void loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _setRewardedCallbacks(ad);
          print("Rewarded Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          print("Rewarded Ad Failed to Load: code=${error.code}, message=${error.message}");
          _isRewardedLoading = false;
          Future.delayed(Duration(seconds: 5), loadRewardedAd);
        },
      ),
    );
  }

  static void _setRewardedCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print("Rewarded Ad Failed to Show: $error");
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdShowedFullScreenContent: (ad) {
        print("Rewarded Ad Showing");
      },
    );
  }

  static Future<bool> showRewardedAd() async {
    print("Attempting to show rewarded ad: _rewardedAd is ${_rewardedAd != null ? 'not null' : 'null'}, _isRewardedLoading is $_isRewardedLoading");
    if (_rewardedAd != null) {
      final completer = Completer<bool>();
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        print("User earned reward: ${reward.amount} ${reward.type}");
        completer.complete(true);
      });
      _rewardedAd = null;
      return completer.future;
    } else {
      if (!_isRewardedLoading) loadRewardedAd();
      return false;
    }
  }
}
