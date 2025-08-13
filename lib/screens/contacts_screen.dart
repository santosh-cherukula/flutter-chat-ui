import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) => GlassCard(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Contact ${i + 1}'),
            subtitle: const Text('Tap to start a chat'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}