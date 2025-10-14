import 'package:flutter/material.dart';

Future<String?> showAdRemovalSelectionDialog(
    BuildContext context, {
      required bool allAdsRemoved,
      required bool rewardedAdsRemoved,
    }) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Remove ADs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                enabled: !allAdsRemoved, // disables if already purchased
                leading: Icon(
                  Icons.ad_units_rounded,
                  color: allAdsRemoved ? Colors.grey : Colors.green,
                ),
                title: Text(
                  allAdsRemoved ? 'All Ads Removed' : 'Remove All Ads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: allAdsRemoved
                        ? Colors.grey
                        : Colors.deepPurpleAccent,
                  ),
                ),
                onTap: allAdsRemoved
                    ? null
                    : () {
                  Navigator.of(context).pop('remove_all_ads');
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                enabled: !rewardedAdsRemoved, // disables if already purchased
                leading: Icon(
                  Icons.currency_bitcoin,
                  color: rewardedAdsRemoved ? Colors.grey : Colors.green,
                ),
                title: Text(
                  rewardedAdsRemoved
                      ? 'Rewarded Ads Removed'
                      : 'Remove Rewarded Ads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: rewardedAdsRemoved
                        ? Colors.grey
                        : Colors.deepPurpleAccent,
                  ),
                ),
                onTap: rewardedAdsRemoved
                    ? null
                    : () {
                  Navigator.of(context).pop('remove_rewarded_ads');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
