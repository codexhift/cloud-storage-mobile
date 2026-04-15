import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/CLD.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) => 
                 const Icon(Icons.cloud, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
