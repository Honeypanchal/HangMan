import 'package:flutter/material.dart';

class CongratsDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          // insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Main dialog image
              Container(

                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Rectangle 71 (1).png'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 350,
                width: 280,
                child:Center(child:Image.asset('assets/images/Group 107.png',height:281,width:260))
              ),

              // Close button
              Positioned(
                top: 1,
                right:  1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/Group (4).png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GameOverDialog {
  static void show(
      BuildContext context, {
        required VoidCallback onRetry,
        required VoidCallback onExit,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // Background container with brown box
              Container(
                height: 330,
                width: 280,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Group 106.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji
                    Image.asset(
                      'assets/images/smiley.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 12),

                    // Retry button image
                    GestureDetector(
                      onTap: onRetry,
                      child: Image.asset(
                        'assets/images/Retry.png',
                        width: 140,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Exit button image
                    GestureDetector(
                      onTap: onExit,
                      child: Image.asset(
                        'assets/images/Exit (1).png',
                        width: 100,
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),

              // Close (X) icon
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/Group (4).png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}