import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatefulWidget {
  const VersionText({super.key});

  @override
  State<VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    final formattedVersion = "${info.version}.${info.buildNumber}";
    if (mounted) {
      setState(() {
        version = formattedVersion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      version.isEmpty ? 'Loading...' : 'V$version',
      style: const TextStyle(color: Colors.white, fontSize: 6),
    );
  }
}
