import 'package:flutter/material.dart';
import 'package:snadders/widgets/exit_button.dart';
import 'package:snadders/widgets/profile/profile_avatar.dart';

import '../services/shared_prefs_service.dart';

class StatisticsPage extends StatefulWidget {
  final String username;
  final bool isGuest;
  final String imagePath;

  const StatisticsPage({
    super.key,
    required this.username,
    required this.isGuest,
    required this.imagePath,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late String _selectedProfileImage = widget.imagePath;
  late TextEditingController _usernameController;
  final SharedPrefsService _sharedPrefsService = SharedPrefsService();

  final List<String> _profileImages = [
    'assets/images/persons/01.png',
    'assets/images/tokens/black.png',
    'assets/images/tokens/green.png',
    'assets/images/tokens/red.png',
    'assets/images/tokens/yellow.png',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _showProfileImageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Profile Image"),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _profileImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      _selectedProfileImage = _profileImages[index];
                    });
                    await _sharedPrefsService.saveProfileImage(_selectedProfileImage);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: _selectedProfileImage == _profileImages[index]
                          ? Border.all(color: Colors.deepPurple, width: 3)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ProfileAvatar(
                      imagePath: _profileImages[index],
                      size: 60,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.white],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Statistics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showProfileImageSelector,
              child: Column(
                children: [
                  ProfileAvatar(
                    imagePath: _selectedProfileImage,
                    size: 80,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap to change",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.isGuest
                    ? SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _usernameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        await _sharedPrefsService.saveUsername(value, isGuest: true);
                        setState(() {});
                      }
                    },
                  ),
                )
                    : Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isGuest)
                  const Icon(
                    Icons.edit,
                    color: Colors.deepPurple,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.isGuest ? "Guest Player" : "Google Player",
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12.0),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Game Statistics",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Games Played:", style: TextStyle(fontSize: 14)),
                      Text("0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Games Won:", style: TextStyle(fontSize: 14)),
                      Text("0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Win Rate:", style: TextStyle(fontSize: 14)),
                      Text("0%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ExitButton(onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
