import 'package:flutter/material.dart';
import 'package:flutter_hangman/utilities/constants.dart';

class WordButton extends StatelessWidget {
  const WordButton({
    super.key,
    required this.buttonTitle,
    this.onPress,
    this.isEnabled = true,
  });

  final VoidCallback? onPress;
  final String buttonTitle;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3.0,
        backgroundColor: isEnabled ? const Color(0xFF1C5E72) : Colors.grey[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4.0),
        minimumSize: const Size(40, 40), // Ensure consistent size
      ),
      onPressed: isEnabled ? onPress : null, // Disable clicks when not enabled
      child: Text(
        buttonTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'SFProText',
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );
  }
}