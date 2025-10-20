import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'shared_prefs_service.dart';

class InAppReviewService {
  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<void> requestReview() async {
    final inAppReview = InAppReview.instance;

    // Check if the user has already rated
    bool alreadyRated = await _prefsService.getRated() ?? false;
    if (alreadyRated) return;

    // Only show if store review is available
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      await _prefsService.setRated(true);
    }
  }
}
