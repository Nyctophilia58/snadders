import 'package:flutter/material.dart';
import '../services/iap_services.dart';

class AdRemovalSelectionDialog extends StatefulWidget {
  final IAPService iapService;

  const AdRemovalSelectionDialog({super.key, required this.iapService});

  @override
  State<AdRemovalSelectionDialog> createState() => _AdRemovalSelectionDialogState();
}

class _AdRemovalSelectionDialogState extends State<AdRemovalSelectionDialog> {
  bool allAdsRemoved = false;
  bool rewardedAdsRemoved = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    allAdsRemoved = widget.iapService.allAdsRemovedNotifier.value;
    rewardedAdsRemoved = widget.iapService.rewardedAdsRemovedNotifier.value;
  }

  Future<void> _buyProduct(String productId) async {
    setState(() => isProcessing = true);

    // Listen for purchase completion
    void listener() {
      if ((productId == IAPService.removeAllAdsId && widget.iapService.allAdsRemovedNotifier.value) ||
          (productId == IAPService.removeRewardedAdsId && widget.iapService.rewardedAdsRemovedNotifier.value)) {
        setState(() => isProcessing = false);
        Navigator.of(context).pop(); // close if both purchased
        if (productId == IAPService.removeAllAdsId) {
          widget.iapService.allAdsRemovedNotifier.removeListener(listener);
        } else {
          widget.iapService.rewardedAdsRemovedNotifier.removeListener(listener);
        }
      }
    }

    if (productId == IAPService.removeAllAdsId) {
      widget.iapService.allAdsRemovedNotifier.addListener(listener);
    } else {
      widget.iapService.rewardedAdsRemovedNotifier.addListener(listener);
    }

    // Trigger purchase
    await widget.iapService.purchaseConsumable(productId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'Remove Ads',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCard(
            title: 'Remove All Ads',
            icon: Icons.ad_units_rounded,
            enabled: !allAdsRemoved,
            onTap: () => _buyProduct(IAPService.removeAllAdsId),
          ),
          const SizedBox(height: 16),
          _buildCard(
            title: 'Remove Rewarded Ads',
            icon: Icons.currency_bitcoin,
            enabled: !rewardedAdsRemoved,
            onTap: () => _buyProduct(IAPService.removeRewardedAdsId),
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
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: ListTile(
        enabled: enabled && !isProcessing,
        leading: Icon(icon, color: enabled ? Colors.green : Colors.grey),
        title: Text(
          enabled ? title : '$title (Purchased)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: enabled ? Colors.deepPurpleAccent : Colors.grey,
          ),
        ),
        onTap: enabled && !isProcessing ? onTap : null,
      ),
    );
  }
}

// Helper function to show the dialog
Future<void> showAdRemovalSelectionDialog(BuildContext context, IAPService iapService) {
  return showDialog(
    context: context,
    builder: (context) => AdRemovalSelectionDialog(iapService: iapService),
  );
}
