import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../constants/ad_unit_ids.dart';
import '../banner_ad_placement.dart';

class AdBannerService {
  static BannerAd? _bannerAd;
  static bool _isLoading = false;

  /// Loads a banner ad
  static void loadBannerAd({AdSize size = AdSize.banner}) {
    if (_isLoading || _bannerAd != null) return; // Prevent multiple loads
    _isLoading = true;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoading = false;
          print("Banner Ad Loaded");
        },
        onAdFailedToLoad: (ad, error) {
          _isLoading = false;
          print("Banner Ad Failed to Load: ${error.message}");
          ad.dispose();
          _bannerAd = null;
          // Retry after a delay
          Future.delayed(const Duration(seconds: 5), () => loadBannerAd(size: size));
        },
        onAdOpened: (ad) => print("Banner Ad Opened"),
        onAdClosed: (ad) => print("Banner Ad Closed"),
      ),
    );

    _bannerAd!.load();
  }

  /// Returns the loaded BannerAd widget for display
  static BannerAdWidget? getBannerWidget() {
    if (_bannerAd != null) {
      return BannerAdWidget(ad: _bannerAd!);
    }
    return null;
  }

  /// Dispose banner ad when no longer needed
  static void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoading = false;
  }
}
