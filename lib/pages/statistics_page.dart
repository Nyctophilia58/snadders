import 'package:flutter/material.dart';
import 'package:snadders/pages/page_controllers/statistics_page_controller.dart';
import 'package:snadders/services/username_validator.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/buttons/exit_button.dart';

class StatisticsPage extends StatefulWidget {
  final String username;
  final bool isGuest;

  const StatisticsPage({
    super.key,
    required this.username,
    required this.isGuest,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsPageController _controller = StatisticsPageController();
  late TextEditingController _usernameController;
  late FocusNode _usernameFocusNode;
  late String _selectedProfileImage = '';
  bool _isEditing = false;

  final List<String> _profileImages = List.generate(
    56,
    (index) => 'assets/images/persons/${(index + 1).toString().padLeft(2, '0')}.png',
  );

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _usernameFocusNode = FocusNode();
    _initProfileImage();
  }

  void _initProfileImage() async {
    final image = await _controller.loadProfileImage(_profileImages);
    setState(() {
      _selectedProfileImage = image;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
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
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ],
        );
      },
    );
  }

  void _saveUsername(String value) async {
    final error = UsernameValidator.validate(value);

    if (error != null) {
      _showError(error);
      return;
    }

    await _controller.saveUsername(value, widget.isGuest);
    setState(() {});
  }

  void _saveProfile() async {
    FocusScope.of(context).unfocus(); // close keyboard

    final username = _usernameController.text.trim();
    final error = UsernameValidator.validate(username);

    if (error != null) {
      _showError(error);
      return; // stop if invalid
    }

    await _controller.saveProfileImage(_selectedProfileImage);
    await _controller.saveUsername(username, widget.isGuest);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.greenAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Statistics",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showProfileImageSelector,
                child: Column(
                  children: [
                    ProfileAvatar(imagePath: _selectedProfileImage, size: 80),
                    const SizedBox(height: 8),
                    const Text("Tap to change", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      readOnly: !_isEditing,
                      textAlign: TextAlign.center,
                      maxLength: 20,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                      onSubmitted: (value) {
                        final error = UsernameValidator.validate(value);
                        if (error != null) {
                          _showError(error);
                          return;
                        }
                        _saveUsername(value);
                        setState(() => _isEditing = false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.isGuest)
                    GestureDetector(
                      child: const Icon(Icons.edit, color: Colors.deepPurple, size: 18),
                      onTap: () {
                        setState(() => _isEditing = true);
                        _usernameFocusNode.requestFocus();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.isGuest ? "Guest Player" : "Google Player",
                style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Game Statistics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Games Played:", style: TextStyle(fontSize: 14, color: Colors.deepPurpleAccent)),
                        Text("0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Games Won:", style: TextStyle(fontSize: 14, color: Colors.deepPurpleAccent)),
                        Text("0", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Win Rate:", style: TextStyle(fontSize: 14, color: Colors.deepPurpleAccent)),
                        Text("0%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
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
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
