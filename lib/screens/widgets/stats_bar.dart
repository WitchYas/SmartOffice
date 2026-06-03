import 'package:flutter/material.dart';
import 'stats_bar_item.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color.fromARGB(192, 199, 203, 212),
              blurRadius: 15.0,
              offset: Offset(0.0, 0.75),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatsBarItem(
              title: "Motion",
              firestoreDocId: "motion",
              unit: "%",
              icon: Icons.sensors,
              color: Color(0xFF3FA6FE),
            ),
            VerticalDivider(),
            StatsBarItem(
              title: "Energy",
              firestoreDocId: "energy",
              unit: "kWh",
              icon: Icons.electric_bolt,
              color: Color(0xFF3038FE),
            ),
            VerticalDivider(),
            StatsBarItem(
              title: "Temp",
              firestoreDocId: "temp",
              unit: "°C",
              icon: Icons.thermostat,
              color: Color(0xFFFE8331),
            ),
          ],
        ),
      ),
    );
  }
}
