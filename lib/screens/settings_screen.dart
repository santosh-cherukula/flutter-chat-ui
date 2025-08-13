import 'package:chatter/main.dart';
import 'package:flutter/material.dart';
import 'package:chatter/themes/app_theme.dart';
import 'package:chatter/widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Santosh'),
              subtitle: const Text('Edit profile'),
              trailing: const Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark mode'),
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (v) {
                    // Theme switching would typically be handled by a state management solution
                    // or by rebuilding the MaterialApp with the new theme
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('App lock'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text('Notifications'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Log out',
                  style: TextStyle(color: Color(0xFFFF5252))),
            ),
          ),
        ],
      ),
    );
  }
}