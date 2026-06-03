import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back",
                style: TextStyle(
                    fontSize: 17.0, color: Color.fromARGB(255, 128, 140, 152)),
              ),
              RichText(
                text: const TextSpan(
                  text: 'Manage  ' ,
                  style: TextStyle(color: Color(0xFF14293C), fontSize: 25),
                  children: [
                    TextSpan(
                        text: 'everything 👋',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14293C),
                            fontSize: 25)),
                  ],
                ),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 28,
            foregroundImage: AssetImage('assets/images/profile.png'),
          )
        ],
      ),
    );
  }
}
