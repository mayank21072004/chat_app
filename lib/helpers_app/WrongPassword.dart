import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Wrongpassword extends StatelessWidget {
  const Wrongpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/wrongpassword.png',
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'HOLD ON !!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 152, 63, 57),
                ),
              ),
              SizedBox(height: 5),
              Text(
                'UserCredential is wrong, please try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 152, 63, 57),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('CLOSE'),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
