import 'package:flutter/material.dart';
import 'package:flutter_hangman/components/Settings_screen.dart';
import 'package:flutter_hangman/screens/LevalScreen.dart';

class CongratsDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Rectangle 71 (1).png'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 350,
                width: 280,
                child: Center(child: Image.asset('assets/images/Group 107.png', height: 281, width: 260)),
              ),
              Positioned(
                top: 1,
                right: 1,
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
                    Image.asset(
                      'assets/images/smiley.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onRetry,
                      child: Image.asset(
                        'assets/images/Retry.png',
                        width: 140,
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 8),
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

class WinnerDialog {
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
              Container(
                height: 330,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color.fromRGBO(255, 255, 255, 0.25),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stack to overlay text with stroke and fill
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Text with stroke (border)
                        Text(
                          'Victory!!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 50,
                            fontFamily: 'Fredoka',
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1
                              ..color = Color.fromRGBO(255, 188, 0, 1), // Yellow border
                            shadows: const [
                              Shadow(
                                color: Color.fromRGBO(255, 188, 0, 0.1),
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Text with fill color (white)
                        const Text(
                          'Victory!!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 50,
                            fontFamily: 'Fredoka',
                            color: Colors.white, // White fill
                            shadows: const [
                              Shadow(
                                color: Color.fromRGBO(255, 188, 0, 0.1),
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Emoji
                    Image.asset(
                      'assets/images/happy.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 12),
                    // Next Level button (text)
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>WordscueLevelScreen()));
                      },
                      child: const Text(
                        'NEXT LEVEL',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w600,
                          fontSize: 33,
                          color: Color.fromRGBO(254, 204, 92, 1),
                          shadows: [
                            Shadow(
                              color: Color.fromRGBO(233, 170, 142, 0.49),
                              offset: Offset(1.73, 2.59),
                              blurRadius: 3.46,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Home button (text)
                    GestureDetector(
                      onTap: onExit,
                      child: const Text(
                        'HOME',
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Fredoka',
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color.fromRGBO(255, 255, 255, 0.3),
                              offset: Offset(1.73, 2.59),
                              blurRadius: 3.46,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}


class PauseDialog
{
  static void show(
      BuildContext context, {
        required VoidCallback onResume,
        required VoidCallback onRetry,
        required VoidCallback onExit,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                height: 390,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromRGBO(0, 0, 0, 0.35),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("DEBUG: Resume pressed from PauseDialog");
                        onResume();
                        Navigator.pop(dialogContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/Resume_button.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('DEBUG: Error loading Resume_button.png');
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("DEBUG: Retry pressed from PauseDialog");
                        onRetry();
                        Navigator.pop(dialogContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/Reply_Button.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('DEBUG: Error loading Reply_Button.png');
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("DEBUG: Settings pressed from PauseDialog");
                        Navigator.pop(dialogContext);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/Settings.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('DEBUG: Error loading Settings.png');
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("DEBUG: Quit pressed from PauseDialog");
                        Navigator.pop(dialogContext);
                        try {
                          onExit();
                          print("DEBUG: onExit executed successfully");
                        } catch (e) {
                          print("DEBUG: Error in onExit: $e");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/Quit_button.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('DEBUG: Error loading Quit_button.png');
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}