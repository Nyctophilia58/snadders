import 'package:flutter/material.dart';
import 'package:snadders/pages/page_controllers/settings_controller.dart';
import '../widgets/exit_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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

              // Audio toggle
              _buildToggle("Audio", controller.soundEnabled, (val) {
                setState(() {
                  controller.toggleSound(val);
                });
              }),
              const SizedBox(height: 20),

              // Language selection
              _buildDropdown("Language", controller.selectedLanguage, controller.languages, (val) {
                setState(() {
                  controller.selectLanguage(val);
                });
              }),
              const SizedBox(height: 20),

              // Board theme selection
              _buildDropdown("Board Theme", controller.selectedBoard, controller.boardThemes, (val) {
                setState(() {
                  controller.selectBoard(val);
                });
              }),
              const Divider(color: Colors.white54, height: 30),

              // Other options
              _buildOption("Store", () {
                controller.openStore();
              }),
              _buildOption("Notifications", () {
                controller.openNotifications();
              }),
              _buildOption("Troubleshoot", () {
                controller.troubleshoot();
              }),
              _buildOption("Request Account Deletion", () {
                controller.requestAccountDeletion();
              }),
              _buildOption("Rate Us", () {
                controller.rateUs();
              }),
              _buildOption("Share", () {
                controller.shareApp();
              }),
              _buildOption("Version: 1.0.0", null, showArrow: false),
              const SizedBox(height: 20),

              // Exit button
              ExitButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label, String selected, List<String> options, ValueChanged<String> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        DropdownButton<String>(
          value: selected,
          dropdownColor: Colors.blueAccent,
          items: options
              .map((val) => DropdownMenuItem(
            value: val,
            child: Text(val, style: const TextStyle(color: Colors.white)),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          iconEnabledColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildOption(String label, VoidCallback? onTap, {bool showArrow = true}) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16) : null,
      onTap: onTap,
    );
  }
}
