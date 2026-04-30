import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TbColors.bg,
      body: Center(child: Text('Admin — Orders')),
    );
  }
}
