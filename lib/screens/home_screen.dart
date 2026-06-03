import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modern_smart_home_ui_practical_01/screens/data/data.dart';
import 'package:modern_smart_home_ui_practical_01/screens/widgets/bottom_container.dart';
import 'package:modern_smart_home_ui_practical_01/screens/widgets/chip_items.dart';
import 'package:modern_smart_home_ui_practical_01/screens/widgets/custom_app_bar.dart';
import 'package:modern_smart_home_ui_practical_01/screens/widgets/stats_bar.dart';
import 'package:appbot/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBar(),
              const SizedBox(height: 30),
              const StatsBar(),
              const SizedBox(height: 30),
              ChipItems(chipList: chipList),
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: gridItems(),
              ),
              const SizedBox(height: 30),
              const BottomContainer(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget gridItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GridView.builder(
        itemCount: gridList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1 / 1.3, // <- Adjusted to give more vertical space
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: gridList[index][4],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(gridList[index][2], size: 26, color: gridList[index][6]),
                      Icon(gridList[index][3], size: 26, color: gridList[index][7]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gridList[index][0],
                        style: TextStyle(
                          color: gridList[index][8],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        gridList[index][1],
                        style: TextStyle(color: gridList[index][9]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gridList[index][5] ? "On" : "Off",
                        style: TextStyle(
                          color: gridList[index][9],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoSwitch(
                        thumbColor: Colors.white,
                        activeTrackColor: const Color(0xFFC7D4E0),
                        value: gridList[index][5],
                        onChanged: (value) {
                          setState(() {
                            gridList[index][5] = value;
                          });
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
