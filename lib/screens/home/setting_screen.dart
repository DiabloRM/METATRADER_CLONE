import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool advancedMode = true;
  bool orderSounds = true;
  bool oneClickTrading = false;
  bool enableNews = true;
  bool lockScreen = false;
  bool tabletInterface = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181C23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C23),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        children: [
          _sectionHeader('QUOTES'),
          _checkboxTile(
            title: 'Advanced mode',
            subtitle:
                'In the advanced mode, the quotes window contains spreads, time data, as well as High and Low prices.',
            value: advancedMode,
            onChanged: (v) => setState(() => advancedMode = v!),
          ),
          _checkboxTile(
            title: 'Order sounds',
            subtitle: 'Play sounds for orders',
            value: orderSounds,
            onChanged: (v) => setState(() => orderSounds = v!),
          ),
          _checkboxTile(
            title: 'One Click Trading',
            subtitle:
                'Allows performing trade operations with a single tap without additional confirmation from the trader',
            value: oneClickTrading,
            onChanged: (v) => setState(() => oneClickTrading = v!),
          ),
          _sectionHeader('MESSAGES'),
          ListTile(
            title: const Text('MetaQuotes ID',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Use this ID to send messages to this device via notify service.',
                style: TextStyle(color: Colors.white54)),
            trailing: Text('39487338',
                style: TextStyle(
                    color: Colors.blue[300], fontWeight: FontWeight.bold)),
            onTap: () {},
          ),
          _infoTile('Vibration', 'Always'),
          _infoTile('Notification ringtone', 'Default (Spaceline)'),
          _infoTile('Content auto-download', 'Always'),
          _sectionHeader('SECURITY'),
          _navTile('OTP', 'One-time Password Generator'),
          _checkboxTile(
            title: 'Lock Screen',
            subtitle:
                'Lock screen when the app is hidden and request pin or biometrics on start',
            value: lockScreen,
            onChanged: (v) => setState(() => lockScreen = v!),
          ),
          _sectionHeader('NEWS'),
          _checkboxTile(
            title: 'Enable News',
            subtitle: 'Receive news updates',
            value: enableNews,
            onChanged: (v) => setState(() => enableNews = v!),
          ),
          _sectionHeader('INTERFACE'),
          _infoTile('Language', 'System language'),
          _checkboxTile(
            title: 'Tablet Interface',
            subtitle: 'Enable tablet interface',
            value: tabletInterface,
            onChanged: (v) => setState(() => tabletInterface = v!),
          ),
          _infoTile('Choose theme', 'System default'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _checkboxTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 13))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue[300],
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _infoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54)),
      onTap: () {},
    );
  }

  Widget _navTile(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }
}
