import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class AdminOrderDetailScreen extends StatelessWidget {
  final String orderId;
  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TbColors.bg,
      appBar: AppBar(backgroundColor: TbColors.ink, foregroundColor: TbColors.cream),
      body: Center(child: Text('Admin — Order $orderId')),
    );
  }
}
