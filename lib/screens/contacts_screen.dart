import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: const Text('Contacts')),
      backgroundColor: Colors.transparent, // Required
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000814), Color(0xFF001E3C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Grid overlay
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),
          
          ListView.separated(
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
        ],
      ),
    );
  }
}
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.08)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}