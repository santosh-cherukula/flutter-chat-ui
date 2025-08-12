import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Santosh'),
            subtitle: Text('Edit profile'),
            trailing: Icon(Icons.edit),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode (system follows by default)'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) {
              // We’ll wire theme switching in Phase 7
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('We’ll add theme toggle in a later phase.'), backgroundColor: cs.primary),
              );
            },
          ),
          const ListTile(leading: Icon(Icons.notifications), title: Text('Notifications')),
          const ListTile(leading: Icon(Icons.lock), title: Text('Privacy')),
          const ListTile(leading: Icon(Icons.info_outline), title: Text('About')),
        ],
      ),
    );
  }
}
