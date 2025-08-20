import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'themes/app_theme.dart';
import 'screens/chat_list_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ChatterApp());
}

class ChatterApp extends StatelessWidget {
  const ChatterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatter',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => _NeonWrapper(child: const LoginScreen()),
        '/home': (_) => _NeonWrapper(child: const _HomeShell()),
      },
    );
  }
}

class _NeonWrapper extends StatelessWidget {
  final Widget child;
  const _NeonWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000814), Color(0xFF001E3C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();
  @override State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;
  final _pages = const [
    ChatListScreen(),
    ContactsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: _pages[_index],
      bottomNavigationBar: _OceanNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// 🌊 Ocean helpers
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.1)
      ..strokeWidth = 0.5;
    
    // Wave grid pattern
    const spacing = 50.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _Bubble extends StatefulWidget {
  final int index;
  const _Bubble({required this.index});
  @override State<_Bubble> createState() => _BubbleState();
}

class _BubbleState extends State<_Bubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4 + widget.index),
    )..repeat();
  }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final x = math.sin(_controller.value * 2 * math.pi) * 120;
        final y = math.cos(_controller.value * 2 * math.pi) * 80;
        return Positioned(
          left: MediaQuery.of(context).size.width/2 + x,
          top: MediaQuery.of(context).size.height/2 + y,
          child: Container(
            width: 4 + widget.index % 3,
            height: 4 + widget.index % 3,
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

// 🌊 Ocean navigation
class _OceanNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _OceanNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001E3C).withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withOpacity(0.2),
            blurRadius: 15,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.white70),
                selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF00D9FF)),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline, color: Colors.white70),
                selectedIcon: Icon(Icons.people, color: Color(0xFF00D9FF)),
                label: 'Contacts',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: Colors.white70),
                selectedIcon: Icon(Icons.settings, color: Color(0xFF00D9FF)),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}