import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('LYChat'),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('Loading...'),
      ),
    );
  }
}
