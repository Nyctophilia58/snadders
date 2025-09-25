import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snadders/services/google_play_services.dart';
import 'package:snadders/widgets/exit_button.dart';
import 'package:snadders/widgets/profile/profile_avatar.dart';

class StatisticsPage extends StatefulWidget {
  final String username;
  final bool isGuest;

  const StatisticsPage({super.key, required this.username, required this.isGuest});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedProfileImage = 'assets/images/persons/person.jpg';
  final TextEditingController _nameController = TextEditingController();
  late bool _isGuest;
  late String _username;

  final List<String> _profileImages = [
    'assets/images/persons/person.jpg',
    'assets/images/tokens/token_blue.png',
    'assets/images/tokens/token_green.png',
    'assets/images/tokens/token_red.png',
    'assets/images/tokens/token_yellow.png',
  ];

  @override
  void initState() {
    super.initState();
    _isGuest = widget.isGuest;
    _username = widget.username;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var isGuest = prefs.getBool('guestSignedIn') ?? true;

    String username;
    if (isGuest) {
      username = prefs.getString('guestUsername') ?? "Player";
    } else {
      username = await GooglePlayServices.getUsername();
    }

    final profileImage = prefs.getString('profileImage') ?? _profileImages[0];

    setState(() {
      _isGuest = isGuest;
      _username = username;
      _selectedProfileImage = profileImage;
      _nameController.text = username;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (_isGuest) {
      await prefs.setString('guestUsername', _nameController.text);
    }

    await prefs.setString('profileImage', _selectedProfileImage);

    setState(() {
      _username = _nameController.text;
    });
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
                  onTap: () {
                    setState(() {
                      _selectedProfileImage = _profileImages[index];
                    });
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showNameEditor() {
    if (_isGuest) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit Your Name"),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Enter your name",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveUserData();
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Google Account"),
            content: const Text("You are signed in with Google. Would you like to sign in with a different Google account?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  GooglePlayServices.signIn();
                  Navigator.pop(context);
                  _loadUserData();
                },
                child: const Text("Sign In"),
              ),
            ],
          );
        },
      );
    }
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              GestureDetector(
                onTap: _showNameEditor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isGuest ? "Guest Player" : "Google Player",
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
                  ExitButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveUserData();
                      Navigator.pop(context);
                    },
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
      ),
    );
  }
}
