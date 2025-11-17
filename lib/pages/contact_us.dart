import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:http/http.dart' as http;

import '../constants/api_key.dart';
import '../widgets/buttons/exit_button.dart';
// import 'package:cloud_functions/cloud_functions.dart';

class ContactUs extends StatefulWidget {
  final String username;
  const ContactUs({super.key, required this.username});

  @override
  ContactUsState createState() => ContactUsState();
}

class ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _captchaController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedIssue;
  bool _isCaptchaValid = false;

  int _captchaAnswer = 0;
  String _captchaQuestion = '';

  final List<String> _issues = [
    'General Inquiry',
    'Bug Report',
    'Feature Request',
    'Account Issue',
    'Purchase Issue',
    'Suggestions',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _captchaController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    final rand = Random();
    final num1 = rand.nextInt(10) + 1;
    final num2 = rand.nextInt(10) + 1;
    final operators = ['+', '-', '*'];
    final op = operators[rand.nextInt(operators.length)];

    switch (op) {
      case '+':
        _captchaAnswer = num1 + num2;
        break;
      case '-':
        _captchaAnswer = num1 - num2;
        break;
      case '*':
        _captchaAnswer = num1 * num2;
        break;
    }

    _captchaQuestion = '$num1 $op $num2 = ?';
  }

  void _validateCaptcha() {
    final answer = int.tryParse(_captchaController.text) ?? 0;
    setState(() {
      _isCaptchaValid = answer == _captchaAnswer;
    });
  }


  // Future<void> _sendMessage() async {
  //   _validateCaptcha();
  //   if (_formKey.currentState!.validate() && _isCaptchaValid) {
  //     try {
  //       final result = await FirebaseFunctions.instance
  //           .httpsCallable('sendContactEmail')
  //           .call({
  //         'username': widget.username,
  //         'email': _emailController.text,
  //         'issue': _selectedIssue,
  //         'message': _messageController.text,
  //       });
  //
  //       if (result.data['success']) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Message sent successfully!')),
  //         );
  //         Navigator.of(context).pop();
  //       } else {
  //         throw Exception(result.data['error']);
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to send message: $e')),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill all fields and solve CAPTCHA correctly.')),
  //     );
  //   }
  // }


  Future<void> _sendMessage() async {
    _validateCaptcha();
    if (_formKey.currentState!.validate() && _isCaptchaValid) {
      try {
        // Replace with your Resend API key
        final apiKey = resendApiKey;

        final response = await http.post(
          Uri.parse('https://api.resend.com/emails'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            "from": "Acme <onboarding@resend.dev>",
            "to": "nowtechdev@gmail.com",
            "subject": "New Contact Us Message: $_selectedIssue",
            "text": "Username: ${widget.username}\n"
                "Email: ${_emailController.text}\n"
                "Issue: $_selectedIssue\n"
                "Message: ${_messageController.text}",
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 202) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully!')),
          );
          Navigator.of(context).pop();
        } else {
          throw Exception(
              'Failed to send message: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Please fill all fields and solve CAPTCHA correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueGrey[700],
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Colors.tealAccent.shade100,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Username (read-only)
                    TextFormField(
                      initialValue: widget.username,
                      enabled: false,
                      decoration: _buildInputDecoration('Username'),
                      style: TextStyle(color: Colors.orangeAccent.shade200, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Email with validators package
                    _buildTextField(
                      _emailController,
                      'Your E-Mail...',
                      TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!isEmail(value)) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // CAPTCHA
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _captchaQuestion,
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            _captchaController,
                            'Answer',
                            TextInputType.number,
                            onChanged: (_) => _validateCaptcha(),
                            validator: (_) => _isCaptchaValid ? null : 'Incorrect answer',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Issue Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedIssue,
                      dropdownColor: Colors.black87,
                      decoration: _buildInputDecoration('Select Your Issue...'),
                      items: _issues
                          .map((issue) => DropdownMenuItem(
                        value: issue,
                        child: Text(issue, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedIssue = value),
                      validator: (value) => value == null ? 'Please select an issue' : null,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    // Message
                    // Message
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',  // <-- use hintText
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.tealAccent.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.tealAccent.shade200, width: 2),
                        ),
                        alignLabelWithHint: true, // important for multi-line alignment
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter a message' : null,
                    ),
                    const SizedBox(height: 16),

                    // Send button
                    ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade400,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Send',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ExitButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.tealAccent.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.tealAccent.shade200, width: 2),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType type,
      {int maxLines = 1, void Function(String)? onChanged, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) return 'Please enter $label';
            return null;
          },
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(label),
    );
  }
}
