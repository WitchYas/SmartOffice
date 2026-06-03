import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsBarItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String firestoreDocId;
  final String unit;

  const StatsBarItem({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.firestoreDocId,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('status')
          .doc(firestoreDocId)
          .snapshots(),
      builder: (context, snapshot) {
        String value = "...";
        if (snapshot.hasData && snapshot.data!.exists) {
          value = "${snapshot.data!['value']} $unit";
          print("✅ Firestore read: $firestoreDocId = $value");
          if (firestoreDocId == "temp") {
                  print("🔥 TEMP VALUE FROM FIRESTORE = $value");
  }
          
        }

        return Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Color.fromARGB(255, 128, 140, 152)),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
