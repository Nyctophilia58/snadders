import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool soundEnabled = true;
  bool aiEnabled = false;
  String selectedBoard = 'Classic';
  final List<String> boardThemes = ['Classic', 'Ocean', 'Forest', 'Candy'];
  String player1Token = 'Red';
  String player2Token = 'Blue';
  final List<String> tokenOptions = ['Red', 'Green', 'Blue', 'Yellow', 'Purple'];

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

              // Player tokens
              _buildPlayerSetting("Player 1", player1Token, (val) {
                setState(() {
                  player1Token = val;
                });
              }),
              const SizedBox(height: 10),
              _buildPlayerSetting("Player 2", player2Token, (val) {
                setState(() {
                  player2Token = val;
                });
              }),
              const Divider(color: Colors.white54, height: 30),

              // Board theme
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Board Theme",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: boardThemes.map((theme) {
                  bool selected = theme == selectedBoard;
                  return ChoiceChip(
                    label: Text(theme),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedBoard = theme;
                      });
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    labelStyle: TextStyle(color: selected ? Colors.blueAccent : Colors.white),
                  );
                }).toList(),
              ),
              const Divider(color: Colors.white54, height: 30),

              // Toggles
              _buildToggle("Sound Effects", soundEnabled, (val) {
                setState(() {
                  soundEnabled = val;
                });
              }),
              const SizedBox(height: 10),
              _buildToggle("Enable AI (2nd Player)", aiEnabled, (val) {
                setState(() {
                  aiEnabled = val;
                });
              }),
              const Divider(color: Colors.white54, height: 30),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Reset settings
                        soundEnabled = true;
                        aiEnabled = false;
                        selectedBoard = 'Classic';
                        player1Token = 'Red';
                        player2Token = 'Blue';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close modal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSetting(String label, String selectedToken, ValueChanged<String> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        DropdownButton<String>(
          value: selectedToken,
          dropdownColor: Colors.blueAccent,
          items: tokenOptions
              .map((token) => DropdownMenuItem(
            value: token,
            child: Text(token, style: const TextStyle(color: Colors.white)),
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

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Switch(
          value: value,
          activeColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
