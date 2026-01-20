import 'package:flutter/material.dart';

class EndUserDashboard extends StatefulWidget {
  const EndUserDashboard({super.key});

  @override
  State<EndUserDashboard> createState() => _EndUserDashboardState();
}

class _EndUserDashboardState extends State<EndUserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('End User Dashboard')),
      body: const Center(child: Text('Welcome to the End User Dashboard!')),
    );
  }
}
