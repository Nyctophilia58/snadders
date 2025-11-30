import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snadders/pages/page_controllers/settings_page_controller.dart';
import 'package:snadders/services/iap_services.dart';
import 'package:snadders/widgets/fetch_app_version.dart';
import '../game/board_selection.dart';
import '../providers/board_provider.dart';
import '../services/in_app_review_services.dart';
import '../widgets/audio_manager.dart';
import '../widgets/buttons/exit_button.dart';
import 'package:snadders/providers/audio_provider.dart';
import '../widgets/troubleshoot.dart';
import 'contact_us.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final String username;
  final IAPService iapService;
  final bool isGuest;
  const SettingsPage({super.key, required this.iapService, required this.username, required this.isGuest});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final SettingsPageController controller = SettingsPageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Audio toggle using Riverpod
                  _buildAudioToggle(),

                  // if not guest, show board selector
                  if (!widget.isGuest)
                    _buildBoardSelectorButton(),

                  // Store option
                  _buildOption("Store", () => controller.openStore(context, widget.iapService)),

                  // Help & Support option
                  _buildOption(
                    "Help & Support",
                    () {
                      showDialog(context: context, builder: (_) => ContactUs(username: widget.username));
                    }
                  ),

                  _buildOption(
                    "Troubleshoot",
                    () {
                      showDialog(context: context, builder: (_) => TroubleShoot(username: widget.username));
                    }
                  ),

                  _buildOption(
                    "Request Account Deletion",
                        () => controller.requestAccountDeletion(context, widget.iapService),
                  ),

                  const SizedBox(height: 20),
                  VersionText(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_alt),
                iconSize: 26,
                onPressed: () {
                  InAppReviewService().rateUs(context);
                },
              ),
              const SizedBox(width: 20),
              ExitButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.share),
                iconSize: 26,
                onPressed: () {
                  Share.share(
                    'I’m playing this awesome game! Download it now!\n\n'
                    'https://play.google.com/store/apps/details?id=com.nowshin.snadders',
                    subject: 'Check this out!',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioToggle() {
    final isAudioEnabled = ref.watch(audioProvider);
    final audioNotifier = ref.read(audioProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Audio", style: TextStyle(color: Colors.white, fontSize: 16)),
        CupertinoSwitch(
          value: isAudioEnabled,
          onChanged: (val) async {
            await audioNotifier.toggleAudio(val);
            AudioManager.instance.setEnabled(val);
          },
        ),
      ],
    );
  }

  Widget _buildBoardSelectorButton() {
    final selectedBoardIndex = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Board", style: TextStyle(color: Colors.white, fontSize: 16)),
        ElevatedButton(
          onPressed: () async {
            final selectedIndex = await showDialog<int>(
              context: context,
              builder: (_) => BoardSelector(iapService: widget.iapService),
            );

            if (selectedIndex != null) {
              await boardNotifier.selectBoard(selectedIndex);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            "Board ${selectedBoardIndex+1}",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String label, VoidCallback? onTap, {bool showArrow = true}) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing:
      showArrow ? const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16) : null,
      onTap: onTap,
    );
  }
}
