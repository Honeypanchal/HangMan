import 'package:flutter/material.dart';

class Dashboeard extends StatefulWidget {
  const Dashboeard({super.key});

  @override
  State<Dashboeard> createState() => _DashboeardState();
}

class _DashboeardState extends State<Dashboeard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
        image: DecorationImage(
        image: AssetImage("assets/images/hangman_bg.png"),
    fit: BoxFit.cover,
    ),
    ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset('assets/images/wordscue.png'),
            SizedBox(height: 40,),
            Container(
              height: 522,
              width: 353,
              decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.35)),

            )

          ],
        )

      ),
    );
  }
}
