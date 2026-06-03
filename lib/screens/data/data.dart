  import 'package:flutter/material.dart';

 List chipList = [
    [
      "Notifications",
      true,
    ],
    [
      "History",
      false,
    ],
    [
      "Devices",
      false,
    ],
    [
      "about",
      false,
    ],
  ];

   List gridList = [
    [
      "Smart lighting", // type or name
      " ", // room
      Icons.light, // first icon
      Icons.wifi, // second icon
      const Color(0xFF00CCD3), // background color
      false, // switch value
      Colors.white, // first icon color
      Colors.white, // second icon color
      Colors.white, // first text color
      Colors.white, // other text color
    ],
    [
      "Air Condition",
      " ",
      Icons.air_rounded,
      Icons.bluetooth,
      Colors.white,
      true,
      const Color(0xFF08CEC2),
      const Color(0xFFC7D5E0),
      const Color(0xFF061E31),
      const Color(0xFFB7BDC3),
    ],
    [
      "Motion Sensor",
      " ",
      Icons.sensors,
      Icons.bluetooth,
      Colors.white,
      false,
      const Color(0xFFFE8430),
      const Color(0xFFC7D5E0),
      const Color(0xFF061E31),
      const Color(0xFFB7BDC3),
    ],
    [
      "Desk Lamp",
      " ",
      Icons.lightbulb_circle_outlined,
      Icons.bluetooth,
      const Color(0xFF6D3EBE),
      true,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ],
  ];