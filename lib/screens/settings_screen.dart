import 'package:flutter/material.dart';
import 'package:chatter/widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎯 **Title visible here** - NO extendBodyBehindAppBar
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF001E3C),
        elevation: 0,
      ),

      // 🔻 **Content below AppBar** - grids visible but title intact
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000814), Color(0xFF001E3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 📊 Grid overlay (non-interactive)
            Expanded(
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _GridPainter(),
                    size: Size.infinite,
                  ),
                  
                  // 📱 Scrollable content
                  ListView(
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
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Column(
                          children: [
                            SwitchListTile(
                            title: const Text('Dark Mode'),
                            value: Theme.of(context).brightness == Brightness.dark,
                            onChanged: (_) {}, // TODO: connect to provider
                            secondary: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                              activeColor: Theme.of(context).colorScheme.primary,
                            ),
                            _tile(Icons.lock_outline, 'App lock'),
                            _tile(Icons.notifications_none, 'Notifications'),
                            _tile(Icons.info_outline, 'About'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Log out', style: TextStyle(color: Color(0xFFFF5252))),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {},
      );
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