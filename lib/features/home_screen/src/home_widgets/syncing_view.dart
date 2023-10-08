import 'package:flutter/material.dart';

class SyncingView extends StatelessWidget {
  const SyncingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(
                'assets/mining.gif',
              ),
              fit: BoxFit.cover,
            ),
            Text('Bijli is syncing your node...')
          ],
        ),
      ),
    );
  }
}
