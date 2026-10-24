import 'package:flutter/material.dart';

class VipPrivilege {
  const VipPrivilege({
    required this.id,
    required this.title,
    required this.minLevel,
    required this.icon,
  });

  final String id;
  final String title;
  final int minLevel; // is level se unlock
  final IconData icon;
}
