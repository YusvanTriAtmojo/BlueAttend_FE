import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:blueattend/presentation/presensi/presensi_screen.dart';
import 'package:blueattend/presentation/presensi/riwayat_presensi.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int pilihIndex;

  @override
  void initState() {
    super.initState();
    pilihIndex = widget.initialIndex;
  }
  
  void pilihHalaman(int index) {
    setState(() {
      pilihIndex = index;
    });
  }

  // navigasi menu
  @override
  Widget build(BuildContext context) {
    final pages = [
      PresensiScreen(),
      RiwayatPresensi(),
    ];

    final icons = [Icons.home_filled, Icons.fact_check_rounded];
    final labels = ["Home", "Riwayat"];

    final items = List.generate(icons.length, (index) {
      return _NavItem(
        icon: icons[index],
        label: labels[index],
        isSelected: pilihIndex == index,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: pages[pilihIndex], 
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.white,
        height: 50,
        index: pilihIndex,
        onTap: pilihHalaman,
        items: items,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Color(0xFF002F87);
    final inactiveColor = Colors.grey;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? activeColor : inactiveColor),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: isSelected ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}
